import pandas as pd
import numpy as np
import findspark
findspark.init()
from pyspark.sql import SparkSession
from pyspark.sql.window import Window
from pyspark.sql.functions import lag, log, pow, sqrt, avg

def create_spark_session():

    return None


def create_df(spark):
    return spark.read.format('csv')\
                     .option('header', 'true')\
                     .load('/media/guolewen/research_data/compustats/*.csv')

def calculate_volatility(rolling_windows=20):
    spark = SparkSession.builder.master('local[*]').appName('Volatility').getOrCreate()
    df = spark.read.format('csv')\
                     .option('header', 'true')\
                     .load('/media/guolewen/research_data/compustats/*.csv')
    # adjust price with stock/dividend split ratio
    df = df.withColumn('adjprccd', df['prccd'] / df['ajexdi'])
    df = df.withColumn('adjprchd', df['prchd'] / df['ajexdi'])
    df = df.withColumn('adjprcld', df['prcld'] / df['ajexdi'])
    # create window
    win_spec = Window.partitionBy('isin').orderBy('datadate')
    # lag price
    df = df.withColumn('ladjprccd', lag('adjprccd').over(win_spec))
    # compute squared daily log returns as the square of natural logarithm of
    # the current closing price divided by previous closing price.
    df = df.withColumn('retsq', pow(log(df['adjprccd'] / df['ladjprccd']), 2))
    # construct a 20-trading-day rolling window
    win_rolling = Window.partitionBy('isin').orderBy('datadate').rowsBetween(-rolling_windows, -1)
    # traditional volatility approach: square root of the average squared daily log returns in a 20-rolling window
    df = df.withColumn('volatility', sqrt(avg('retsq').over(win_rolling)))
    # compute squared daily log high low as the square of natural logarithm
    # of daily high price divided by low price.
    # fill na values with 0 (this is for the case if no trading during the day)
    df = df.withColumn('loghlsq', pow(log(df['adjprchd'] / df['adjprcld']), 2)).fillna(0, subset=['loghlsq'])
    # Parkison's extreme value method: square root of 1/4*Ln2 times the average of squared daily log high low
    # in a 20-rolling window
    df = df.withColumn('Parkinsonvol', sqrt((1/(4*np.log(2))) * avg('loghlsq').over(win_rolling)))
    return df.selectExpr('datadate as Date', 'isin as ISIN', 'volatility', 'Parkinsonvol').toPandas()



if __name__=='__main__':
    df = calculate_volatility()
    import matplotlib.pyplot as plt
    # show a plot for a sample
    a = df.where(df['isin'] == 'JP3330800008').toPandas()
    a.plot(x='datadate', y=['volatility', 'Parkinsonvol'])
    plt.show()
