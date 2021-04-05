import pandas as pd
import numpy as np
import findspark
from volatility import calculate_volatility

findspark.init()
from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType, ShortType, ByteType, StringType, DoubleType, LongType
from pyspark.sql.functions import udf, expr, col, sum, avg, when, row_number, percent_rank, concat, count
from pyspark.sql.window import Window
import sys


def create_spark_session():
    spark = SparkSession.builder.master('local[*]').appName('Summary Stats').getOrCreate()
    return spark


def create_df(spark):
    return spark.read.format('csv') \
        .option('header', 'true') \
        .load('/media/guolewen/intraday_data/needs/extracted_data/*.csv')


def filters(df, del_multiple_tick_stockdays=True):
    """

    :param df: all trade data for trading days in the extracted_data folder
    :return:
    """
    df = df.filter("TradePrice is not NULL")
    df = df.withColumn('RecordType', df['RecordType'].cast(ShortType()))
    df = df.withColumn('Date', df['Date'].cast(IntegerType()))
    df = df.withColumn('Section', df['Section'].cast(ByteType()))
    df = df.withColumn('Session', df['Session'].cast(ByteType()))
    df = df.withColumn('Ticker', df['Ticker'].cast(IntegerType()))
    df = df.withColumn('TradeTime', df['TradeTime'].cast(IntegerType()))
    df = df.withColumn('DetailedTime', df['DetailedTime'].cast(LongType()))
    df = df.withColumn('ControlNum', df['ControlNum'].cast(IntegerType()))
    df = df.withColumn('TradePrice', df['TradePrice'].cast(IntegerType()))
    df = df.withColumn('TradeTypeFlag', df['TradeTypeFlag'].cast(ShortType()))
    df = df.withColumn('TradingVolume', df['TradingVolume'].cast(LongType()))
    df = df.withColumn('TradingVolumeFlag', df['TradingVolumeFlag'].cast(ShortType()))
    df = df.withColumn('TickFlag', df['TickFlag'].cast(ShortType()))
    df = df.withColumn('ClosingQuoteFlag', df['ClosingQuoteFlag'].cast(ShortType()))
    df = df.withColumn('YenVolume', df['TradePrice'] * df['TradingVolume'])
    df = df.withColumn('YenVolume', df['YenVolume'].cast(LongType()))
    df = df.withColumn('AskQuote', df['AskQuote'].cast(IntegerType()))
    df = df.withColumn('AskSize', df['AskSize'].cast(IntegerType()))
    df = df.withColumn('AskFlag', df['AskFlag'].cast(ShortType()))
    df = df.withColumn('BidQuote', df['BidQuote'].cast(IntegerType()))
    df = df.withColumn('BidSize', df['BidSize'].cast(IntegerType()))
    df = df.withColumn('BidFlag', df['BidFlag'].cast(ShortType()))
    df = df.withColumn('Spread', df['Spread'].cast(IntegerType()))
    df = df.withColumn('PrcSpread', df['PrcSpread'].cast(DoubleType()))
    df = df.withColumn('TickerDay', concat(df['Ticker'], df['Date']))
    df = df.withColumn('TickerDay', df['TickerDay'].cast(LongType()))
    # only first section stocks are included
    # REITs and ETFs are dropped out
    # https://www2.tse.or.jp/tseHpFront/JJK010010Action.do?Show=Show  accessed on 2021/02/09
    etf_list = [1305, 1306, 1308, 1309, 1311, 1312, 1313, 1319, 1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327,
                1328, 1329, 1330, 1343, 1344, 1345, 1346, 1348, 1349, 1356, 1357, 1358, 1360, 1364, 1365, 1366,
                1367, 1368, 1369, 1385, 1386, 1387, 1388, 1389, 1390, 1391, 1392, 1393, 1394, 1397, 1398, 1399,
                1456, 1457, 1458, 1459, 1460, 1464, 1465, 1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473, 1474,
                1475, 1476, 1477, 1478, 1479, 1480, 1481, 1482, 1483, 1484, 1485, 1486, 1487, 1488, 1489, 1490,
                1492, 1493, 1494, 1495, 1496, 1497, 1498, 1499, 1540, 1541, 1542, 1543, 1545, 1546, 1547, 1550,
                1551, 1552, 1554, 1555, 1557, 1559, 1560, 1563, 1566, 1567, 1568, 1569, 1570, 1571, 1572, 1573,
                1574, 1575, 1576, 1577, 1578, 1579, 1580, 1584, 1585, 1586, 1591, 1592, 1593, 1595, 1596, 1597,
                1598, 1599, 1615, 1617, 1618, 1619, 1620, 1621, 1622, 1623, 1624, 1625, 1626, 1627, 1628, 1629,
                1630, 1631, 1632, 1633, 1651, 1652, 1653, 1654, 1655, 1656, 1657, 1658, 1659, 1660, 1670, 1671,
                1672, 1673, 1674, 1675, 1676, 1677, 1678, 1679, 1680, 1681, 1682, 1684, 1685, 1686, 1687, 1688,
                1689, 1690, 1691, 1692, 1693, 1694, 1695, 1696, 1697, 1698, 1699, 2510, 2511, 2512, 2513, 2514,
                2515, 2516, 2517, 2518, 2519, 2520, 2521, 2522, 2523, 2524, 2525, 2526, 2527, 2528, 2529, 2530,
                2552, 2553, 2554, 2555, 2556, 2557, 2558, 2559, 2560, 2561, 2562, 2563, 2564, 2565, 2566, 2567,
                2568, 2569, 2620, 2621, 2622, 2623, 2624, 2625, 2626, 2627]
    reit_list = [2971, 2972, 2979, 3226, 3227, 3234, 3249, 3269, 3278, 3279, 3281, 3282, 3283, 3287, 3290, 3292, 3295,
                 3296, 3298, 3309, 3451, 3453, 3455, 3459, 3462, 3463, 3466, 3468, 3470, 3471, 3472, 3476, 3478, 3481,
                 3487, 3488, 3492, 3493, 8951, 8952, 8953, 8954, 8955, 8956, 8957, 8958, 8960, 8961, 8963, 8964, 8966,
                 8967, 8968, 8972, 8975, 8976, 8977, 8979, 8984, 8985, 8986, 8987, 3473]
    delisted_etf = [1310, 1314, 1347, 1361, 1362, 1363, 1548, 1549, 1561, 1562, 1565, 1581, 1582, 1583, 1587, 1588,
                    1589, 1590, 1610, 1612, 1613, 1634, 1635, 1636, 1637, 1638, 1639, 1640, 1641, 1642, 1643, 1644,
                    1645, 1646, 1647, 1648, 1649, 1650, 1683]
    others = [9281, 9282, 9283, 9284, 9285, 9286, 9287, 3308]
    reit_etf_lists = etf_list + reit_list + delisted_etf + others
    # create minimum tick size indicator
    df = df.withColumn('TickSize', when(df['TradePrice'] <= 3000, 1)
                                  .when((df['TradePrice'] > 3000) & (df['TradePrice'] <= 5000), 5)
                                  .when((df['TradePrice'] > 5000) & (df['TradePrice'] <= 30000), 10)
                                  .when((df['TradePrice'] > 30000) & (df['TradePrice'] <= 50000), 50)
                                  .when((df['TradePrice'] > 50000) & (df['TradePrice'] <= 300000), 100)
                                  .when((df['TradePrice'] > 300000) & (df['TradePrice'] <= 500000), 500)
                                  .when((df['TradePrice'] > 500000) & (df['TradePrice'] <= 3000000), 1000)
                                  .when((df['TradePrice'] > 3000000) & (df['TradePrice'] <= 5000000), 5000)
                                  .when((df['TradePrice'] > 5000000) & (df['TradePrice'] <= 30000000), 10000)
                                  .when((df['TradePrice'] > 30000000) & (df['TradePrice'] <= 50000000), 50000)
                                  .otherwise(100000))
    # delete stocks with multiple minimum tick sizes within a trading day.
    if del_multiple_tick_stockdays:
        ticker_days = df.groupBy('Ticker', 'Date', 'TickSize').count()\
                      .groupBy('Ticker', 'Date').count().where('count > 1').toPandas()
        ticker_d_list = (ticker_days.Ticker.astype(str) + ticker_days.Date.astype(str)).astype(int).to_list()
        print("Stocks with multiple ticks in one trading day are deleted, "
              "it deletes {} stock-day observations".format(len(ticker_d_list)))
        df = df.filter(~df.TickerDay.isin(ticker_d_list))

    # even-lot shares, 100-lot shares, 1000-lot share indicator
    df = df.withColumn('Hundredlot', when(df['TradingVolume'] == 100, 1).otherwise(0))
    df = df.withColumn('Thousandlot', when(df['TradingVolume'] == 1000, 1).otherwise(0))
    df = df.withColumn('Evenlot', when(df['TradingVolume'] == 100, 1)
                                 .when(df['TradingVolume'] == 200, 1)
                                 .when(df['TradingVolume'] == 300, 1)
                                 .when(df['TradingVolume'] == 400, 1)
                                 .when(df['TradingVolume'] == 500, 1)
                                 .when(df['TradingVolume'] == 1000, 1)
                                 .when(df['TradingVolume'] == 2000, 1)
                                 .when(df['TradingVolume'] == 3000, 1)
                                 .when(df['TradingVolume'] == 4000, 1)
                                 .when(df['TradingVolume'] == 5000, 1)
                                 .when(df['TradingVolume'] == 10000, 1)
                                 .when(df['TradingVolume'] == 15000, 1)
                                 .when(df['TradingVolume'] == 20000, 1)
                                 .when(df['TradingVolume'] == 25000, 1)
                                 .when(df['TradingVolume'] == 30000, 1)
                                 .when(df['TradingVolume'] == 40000, 1)
                                 .when(df['TradingVolume'] == 50000, 1)
                                 .when(df['TradingVolume'] == 60000, 1)
                                 .when(df['TradingVolume'] == 70000, 1)
                                 .when(df['TradingVolume'] == 75000, 1)
                                 .when(df['TradingVolume'] == 80000, 1)
                                 .when(df['TradingVolume'] == 90000, 1)
                                 .when(df['TradingVolume'] == 100000, 1)
                                 .when(df['TradingVolume'] == 200000, 1)
                                 .when(df['TradingVolume'] == 300000, 1)
                                 .when(df['TradingVolume'] == 400000, 1)
                                 .when(df['TradingVolume'] == 500000, 1)
                                 .otherwise(0))
    df = df.withColumn('HundredlotVol', df['TradingVolume'] * df['Hundredlot'])
    df = df.withColumn('ThousandlotVol', df['TradingVolume'] * df['Thousandlot'])
    df = df.withColumn('EvenlotVol', df['TradingVolume'] * df['Evenlot'])
    return df.where("Exchange='11'").filter(~df.Ticker.isin(reit_etf_lists)).filter(df.Section.isin([1, 2]))


def sort_volume_stocks(df, n=10):
    # this function should be revised when using more than one trading day data.
    # return: a list of pyspark dataframe with stocks sorted
    window_spec1 = Window.partitionBy().orderBy('STOCKD_SUM_YENVOL')
    grouped = df.groupBy(df['Ticker']).agg(expr("sum(YenVolume) as STOCKD_SUM_YENVOL"))
    prc_rank = grouped.select('Ticker', percent_rank().over(window_spec1).alias('percent_rank')).toPandas()

    def sort_con(_n=n):
        # construct percentiles
        unit = 1 / _n
        first = unit
        last = unit * (_n - 1)
        conditions = []
        for i in np.arange(first, 1 + unit, unit):
            if i == first:
                conditions.append(prc_rank['percent_rank'] <= i)
            elif i == 1:
                conditions.append(prc_rank['percent_rank'] > i - unit)
            else:
                conditions.append((prc_rank['percent_rank'] <= i) & (prc_rank['percent_rank'] > i - unit))
        return conditions

    conds = sort_con(n)
    stock_lists = [prc_rank[cond]['Ticker'].tolist() for cond in conds]
    assert len(stock_lists) == n, "number of stock lists is not equal to n"
    return [df.filter(df.Ticker.isin(l)) for l in stock_lists]


def avg_daily(df):
    # groupby ticker and aggregate
    # return: trade_final stock-day observations Number of Prints
    grouped = df.groupBy(df['Ticker'], df['Date']).agg(count("Ticker").alias("NPRINTs"),
                                                       sum("YenVolume").alias("YENVOL"),
                                                       sum("TradingVolume").alias("VOL"),
                                                       avg("TradePrice").alias("AVG_PRICE"),
                                                       avg("TradingVolume").alias("AVG_PRINTSIZE"),
                                                       avg("TickSize").alias("TickSize"),
                                                       avg("Section").alias("Section"),
                                                       expr("percentile_approx(TradingVolume, 0.5) as D_MED_TW_SIZE"),
                                                       expr("percentile_approx(TradingVolume, 0.2) as D_20P_TW_SIZE"),
                                                       expr("percentile_approx(TradingVolume, 0.8) as D_80P_TW_SIZE"),
                                                       sum("Hundredlot").alias("HundredlotPrints"),
                                                       sum("Thousandlot").alias("ThousandlotPrints"),
                                                       sum('Evenlot').alias("EvenlotPrints"),
                                                       sum("HundredlotVol").alias("HundredlotDVol"),
                                                       sum("ThousandlotVol").alias("ThousandlotDVol"),
                                                       sum("EvenlotVol").alias("EvenlotDVol")
                                                       )
    # volume weighted median print size in Volume
    window_spec1 = Window.partitionBy('Ticker', 'Date')
    window_spec2 = Window.partitionBy('Ticker', 'Date').orderBy('TradingVolume').rowsBetween(-sys.maxsize, 0)
    window_spec3 = Window.partitionBy('Ticker', 'Date').orderBy('Volume_cum_prc')
    df_prc = df.withColumn('Volume_percentage', col('TradingVolume') / sum('TradingVolume').over(window_spec1))
    df_cumprc_minus = df_prc.withColumn('Volume_cum_prc', sum('Volume_percentage').over(window_spec2) - 0.5)
    df_final = df_cumprc_minus.withColumn('Volume_cum_prc', when(df_cumprc_minus['Volume_cum_prc'] < 0, 2). \
                                          otherwise(df_cumprc_minus['Volume_cum_prc']))
    df_final = df_final.withColumn("rn", row_number().over(window_spec3)) \
        .where('rn = 1') \
        .selectExpr('Ticker', 'Date', 'TradingVolume as D_MED_VW_SIZE')
    pd_grouped = grouped.toPandas()
    pd_final = df_final.toPandas()
    trade_final = pd_grouped.merge(pd_final, how='left', on=['Ticker', 'Date'])
    return trade_final


def merge_volatility(trade_final, volatility_df, merge_table, rolling_window):
    vol_ticker_date = volatility_df.merge(merge_table, how='left', on='ISIN').dropna().reset_index(drop=True)
    vol_ticker_date['Ticker'] = vol_ticker_date['Code'].astype(int)
    vol_ticker_date['Date'] = vol_ticker_date['Date'].astype(int)
    del vol_ticker_date['Code']
    final = trade_final.merge(vol_ticker_date, how='left', on=['Ticker', 'Date'])\
                       .dropna()\
                       .sort_values(['Ticker', 'Date'])\
                       .reset_index(drop=True)
    save_path = '/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data' + '{}'.format(rolling_window) + '.csv'
    final.to_csv(save_path, index=False)
    return final


def generate_data(rolling_window=20):
    spark = create_spark_session()
    df = create_df(spark)
    df = filters(df)
    trade_final = avg_daily(df)
    volatility_df = calculate_volatility(rolling_window)
    merge_table_1 = pd.read_csv(
        '/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/code_isin_industry_table.csv')
    merge_table_2 = pd.read_csv('/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/delisted.csv')
    merge_table = pd.concat([merge_table_1[['Code', 'ISIN', 'Industry']],
                             merge_table_2[['Code', 'ISIN', 'Industry']]], axis=0)
    # merge the data
    return merge_volatility(trade_final, volatility_df, merge_table, rolling_window)


def sort_volume_groups(rolling_window=20):
    try:
        df = pd.read_csv('/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data' + '{}'.format(rolling_window) + '.csv' )
    except FileNotFoundError:
        df = generate_data(rolling_window)
    grouped_mean = df.groupby(['Ticker']).agg('mean').reset_index()
    grouped_mean['VOLkylegroup'] = pd.qcut(grouped_mean.YENVOL, [0, 0.3, 0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1],
            labels=['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']).astype(str)
    grouped_mean['VOLnormalgroup'] = pd.qcut(grouped_mean.YENVOL, [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
                                           labels=['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']).astype(str)
    df = df.merge(grouped_mean[['Ticker', 'VOLkylegroup', 'VOLnormalgroup']], 'left', on='Ticker')
    df.to_csv('/media/guolewen/intraday_data/needs/day_stock_computed_data/full_data_with_volg' + '{}'.format(rolling_window) + '.csv', index=False)
    return df


if __name__ == '__main__':
    generate_data(rolling_window=10)
    sort_volume_groups(rolling_window=10)

