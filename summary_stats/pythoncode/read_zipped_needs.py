import os
import zipfile
import shutil
import time
import findspark
findspark.init()
from pyspark.sql import SparkSession
from pyspark.sql.types import LongType, IntegerType, ShortType, ByteType


def zip_extract(path):
    """

    :param path: the path should contains the zipped daily files like HTICST120.20190401.1.zip
    :return: extracted_path
    """
    list_zip_files = os.listdir(path)
    extracted_path = os.path.join(os.path.dirname(path), os.path.basename(path) + '_extracted')
    print(extracted_path)
    if not os.path.exists(extracted_path):
        os.makedirs(extracted_path)
    # set working directory as extracted_path and put extracted files there
    os.chdir(extracted_path)
    assert os.getcwd() == extracted_path, "extracted directory should be the current working directory"
    for file in list_zip_files:
        file_path = os.path.join(path, file)
        try:
            print("{} is extracting".format(file))
            zipfile.ZipFile(file_path).extractall()
            print("{} is successfully extracted".format(file))
        except zipfile.BadZipfile:
            print("Bad CRC-32 for {}".format(file), "This file need to be checked")
    return extracted_path


def df_transform(date, df):
    df = df.selectExpr("_c0 as RecordType", "_c1 as Date", "_c2 as Exchange",
                       "_c3 as Section", "_c4 as Session", "_c5 as Ticker",
                       "_c6 as TradeTime", "_c9 as DetailedTime", "_c10 as ControlNum",
                       "_c11 as TradePrice", "_c12 as TradeTypeFlag", "_c13 as TickFlag",
                       "_c14 as TradingVolume", "_c15 as TradingVolumeFlag", "_c16 as ClosingQuoteFlag",
                       "_c17 as AskQuote", "_c18 as AskSize", "_c19 as AskFlag",
                       "_c20 as BidQuote", "_c21 as BidSize", "_c22 as BidFlag")
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
    df = df.withColumn('TradingVolume', df['TradingVolume'].cast(IntegerType()))
    df = df.withColumn('TradingVolumeFlag', df['TradingVolumeFlag'].cast(ShortType()))
    df = df.withColumn('TickFlag', df['TickFlag'].cast(ShortType()))
    df = df.withColumn('ClosingQuoteFlag', df['ClosingQuoteFlag'].cast(ShortType()))
    df = df.withColumn('YenVolume', df['TradePrice'] * df['TradingVolume'])
    df = df.withColumn('AskQuote', df['AskQuote'].cast(IntegerType()))
    df = df.withColumn('AskSize', df['AskSize'].cast(IntegerType()))
    df = df.withColumn('AskFlag', df['AskFlag'].cast(ShortType()))
    df = df.withColumn('BidQuote', df['BidQuote'].cast(IntegerType()))
    df = df.withColumn('BidSize', df['BidSize'].cast(IntegerType()))
    df = df.withColumn('BidFlag', df['BidFlag'].cast(ShortType()))
    df = df.withColumn('Spread', df['AskQuote'] - df['BidQuote'])
    df = df.withColumn('PrcSpread', df['Spread'] / df['TradePrice'])
    # filter the trade entries only
    df = df.filter("TradePrice is not NULL").orderBy('Ticker')
    output_dir = '/media/guolewen/intraday_data/needs/extracted_data/'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    df.toPandas().to_csv(os.path.join(output_dir, date + '.csv'), index=False)


def extract_trading_data(extracted_path):
    spark = SparkSession.builder.master('local[*]').appName('ExtractTrading').getOrCreate()
    date_set = set([file.split('.')[1] for file in os.listdir(extracted_path)])
    df_dicts = {date: spark.read.format('csv').option('header', 'false')
                                              .load(extracted_path + '/*.{}.*'.format(date)) for date in date_set}
    for k, v in df_dicts.items():
        df_transform(k, v)
    # del extract_path directory
    shutil.rmtree(extracted_path)
    return


if __name__=="__main__":
    t1 = time.time()
    path = '/media/guolewen/intraday_data/needs/202006'
    extracted_path = zip_extract(path)
    extract_trading_data(extracted_path)
    t2 = time.time()
    print("total running time is", t2 - t1)

