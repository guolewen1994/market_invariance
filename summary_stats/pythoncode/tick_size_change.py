import pandas as pd
import findspark
findspark.init()
from pyspark.sql import SparkSession
from pyspark.sql.functions import row_number, sum, col, when, count
from pyspark.sql.window import Window
import sys


def create_spark_session():
    spark = SparkSession.builder.master('local[*]').appName('tick size change').getOrCreate()
    return spark


def create_df(spark):
    return spark.read.format('csv') \
        .option('header', 'true') \
        .option('inferSchema', 'true') \
        .load('/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data_with_volg.csv')


def assign_ticksize_change(df):
    grouped = df.groupBy('Ticker', 'TickSize')
    # Get the list of stocks where there are two tick sizes in sample period
    twoticksize_df = grouped.count().groupby('Ticker').count().where('count==2').toPandas()
    twoticksize_ticker_list = twoticksize_df['Ticker'].astype(int).to_list()
    # Assign the small large tick size group indicator
    ticksize_count = grouped.count()
    twotick_assign = ticksize_count.filter(ticksize_count.Ticker.isin(twoticksize_ticker_list))
    twotick_assign = twotick_assign.withColumn('TickSizeGroupInd',
                                               row_number().over(Window.partitionBy('Ticker').orderBy('TickSize')))
    # delete stocks with one of the tick size group has observation smaller than 10
    smaller_than_10_stocks = ticksize_count.filter(ticksize_count.Ticker.isin(twoticksize_ticker_list))\
                                           .orderBy('Ticker', 'TickSize') \
                                           .where('count <= 10').toPandas()['Ticker'].to_list()
    twotick_selected = df.filter(df.Ticker.isin(twoticksize_ticker_list))\
                         .filter(~df.Ticker.isin(smaller_than_10_stocks))\
                         .join(twotick_assign.drop('count'), on=['Ticker', 'TickSize'], how='left')
    # get the first value of TicksizeGroupInd for each group and if it equals 1 then it is an "increase" group
    ticksize_inc_group = twotick_selected.withColumn('row', row_number().over(Window.partitionBy('Ticker').orderBy('Date')))\
                         .where('row == 1').drop('row')\
                         .where('TickSizeGroupInd == 1')\
                         .select('Ticker').toPandas()['Ticker'].to_list()
    # for increase group, select the stocks increase their ticksize only one time.
    ticksize_inc_df = twotick_selected.filter(twotick_selected.Ticker.isin(ticksize_inc_group))

    window_spec = Window.partitionBy('Ticker').orderBy('Date').rowsBetween(-sys.maxsize, 0)
    window_spec2 = Window.partitionBy('Ticker').orderBy('Date')
    ticksize_inc_df = ticksize_inc_df.withColumn('Cumsum', sum('TickSizeGroupInd').over(window_spec))
    ticksize_inc_df = ticksize_inc_df.withColumn('row', row_number().over(window_spec2))
    ticksize_inc_df = ticksize_inc_df.withColumn('Diff', col('Cumsum') - col('row'))
    ticksize_inc_df = ticksize_inc_df.withColumn('Diff', when(ticksize_inc_df['Diff'] > 1, 1)\
                                                        .otherwise(ticksize_inc_df['Diff']))
    ticksize_g = ticksize_inc_df.groupBy('Ticker', 'TickSizeGroupInd').count().alias('TickSizecount').where(
                                         'TickSizeGroupInd == 2')
    ticksize_g = ticksize_g.withColumnRenamed('count', 'Ticksizecount')
    diff_g = ticksize_inc_df.groupBy('Ticker', 'Diff').count().where('Diff == 1')
    merged = ticksize_g.join(diff_g, on='Ticker', how='left')
    monotonic_inc_list = merged.where("Ticksizecount == count").toPandas()['Ticker'].to_list()
    return twotick_selected.filter(twotick_selected.Ticker.isin(monotonic_inc_list)).orderBy('Ticker', 'Date').toPandas()


if __name__ == '__main__':
    spark = create_spark_session()
    df = create_df(spark)
    final = assign_ticksize_change(df)
    final.to_csv('/media/guolewen/intraday_data/needs/day_stock_computed_data/subsample_withticksizeind.csv', index=False)