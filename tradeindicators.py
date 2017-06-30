#create matrix for ml with various trading indicators 
import talib as ta
import numpy as np
import pandas as pd
import common as cm
import time
from pip._vendor.colorama.initialise import atexit_done
from cProfile import label

earliestDatTime = "2016-1-1"

allinstr = [ 
'^AORD',
'^N225',
'^NDX',
#not enough history '^GDAXI',
'^SSEC',
'^HSI',
'^BSESN',
'^JKSE',
'^KLSE',
'^NZ50',
#not enough history  '^STI',
'^KS11',
'^TWII',
'^BVSP',
'^GSPTSE',
'^MXX',
'^GSPC',
'^ATX',
#very sparse data  '^BFX',
'^FCHI',
#very sparse data  '^OSEAX',
#very sparse data  '^OMXSPI',
'FXA',
'FXB',
'FXC',
'FXE',
'FXF',
#very sparse data  'FXS',
'FXY',
#very sparse data  'CHOC',
'CORN',
#very sparse data  'CTNN',
#very sparse data  'CUPM',
#very sparse data  'FOIL',
'GAZ',
'GLD',
#very sparse data 'HEVY',
#very sparse data  'LEDD',
#very sparse data  'LSTK',
# 'NINI',
'OIL',
'PALL',
'PPLT',
#very sparse data  'SGAR',
'SLV',
'SOYB',
'UHN'
]

conn = cm.getdbcon()
cur = conn.cursor()
shiftDays = -20
difftreshhold = 0.03

def formatLabel(x):
    if x > 1 + difftreshhold:
        return 'up'
    elif x < 1 - difftreshhold:
        return 'down'
    else:
        return 'neutral'

def loadDataSet(symbol, isUseBestFeautures, offset, limit):
    df = loadCleanAllDataFrame(symbol, isUseBestFeautures, offset, limit)
    mlDf = pd.DataFrame()
    mlDf['close'] = df[symbol + '_close']
    mlDf['nextshift'] = df[symbol + '_close'].shift(shiftDays)
    mlDf['shiftdiff'] = df[symbol + '_close'].shift(shiftDays) / df[symbol + '_close']
    mlDf['labelFormat'] = (df[symbol + '_close'].shift(shiftDays) / df[symbol + '_close']).map(formatLabel)
    labels = (df[symbol + '_close'].shift(shiftDays) / df[symbol + '_close']).map(formatLabel)

    mlDf.to_csv('shiftsDFTest.csv', sep=',')

#     dateList = df['date'].as_matrix()
    colNames = df.columns.values
    X_dataSet = df.as_matrix()
    y_predictions = labels.values
    dateList = df.index.values
    return (colNames, X_dataSet, y_predictions, dateList)

def loadCleanAllDataFrame(symbol, isUseBestFeautures, offset, limit):
    instrAr = list(allinstr)
    instrAr.remove(symbol)
    instrAr.insert(0, symbol)
    print 'instrAr=', instrAr
    joinedDf = None
    for instr in instrAr:
        newDf = loadSymbolDataFrame(instr, offset, limit)
        if joinedDf is None:
            joinedDf = newDf.set_index('date')
        else:
            joinedDf = joinedDf.join(newDf.set_index('date'), how='outer')

    # get the first valid index for each column and calculate the max
    first_valid_loc = joinedDf.apply(lambda col: col.first_valid_index()).max()    
    df = joinedDf.loc[first_valid_loc:]
    
    # get the last valid index for each column and calculate the min
    last_valid_loc = df.apply(lambda col: col.last_valid_index()).min()
    df = df.loc[:last_valid_loc]

    df = df.fillna(method='ffill').fillna(method='bfill')

    df.to_csv('concatDFTest.csv', sep=',')
    return df

def loadSymbolDataFrame(symbol, offset, limit):
    print 'symbol="{0}" offset={1} limit={2}'.format(symbol, offset, limit)
    start = time.time()
    cur.execute("select * from stocks where stock=%s order by date desc offset %s limit %s", \
                (symbol, offset, limit))
#     cur.execute("select * from stocks where stock=%s and date >= %s order by date desc offset %s limit %s", \
#                 (symbol, earliestDatTime, offset, limit))
    print '                  ...done in {0} seconds'.format(time.time() - start)
    records = cur.fetchall()
    colNames = np.array(cur.description)[:,0]
#     print 'colnames', colNames
    desc_df = pd.DataFrame.from_records(records, columns=colNames)
#     desc_df.set_index('date')
    df = desc_df.iloc[::-1]

    date = df['date'].as_matrix()
    close = np.asarray(df['Adj Close'].as_matrix(), dtype='float')
#     print close
    closeSimple = df.close.as_matrix()
    high = df.high.as_matrix()
    low = df.low.as_matrix()
    open_ = df.open.as_matrix()
    volume = np.asarray(df.volume.as_matrix(), dtype='float')

    analytics = pd.DataFrame()
    analytics['date'] = date
    analytics[symbol + '_close'] = close
    tempDf = pd.DataFrame()
#     analytics[symbol + '_close'] = close
    tempDf['close'] = close
    analytics[symbol + '_rsi'] = ta.RSI(close)
    macd, signal, analytics[symbol + '_macdhist'] = ta.MACD(close, fastperiod=12, slowperiod=26, signalperiod=9)
    analytics[symbol + '_mfi'] = ta.MFI(high, low, close, volume, timeperiod=14)
    analytics[symbol + '_roc'] = ta.ROC(close, timeperiod=10)
    tempDf['stochk'], tempDf['stochd'] = ta.STOCH(high, low, close, fastk_period=5, slowk_period=3, slowk_matype=0, slowd_period=3, slowd_matype=0)
#     analytics[symbol + '_stochsignal'] = df.apply(stochdif, axis=1)
    analytics[symbol + '_stochsignal'] = tempDf.apply(lambda row: row['stochk'] - row['stochd'], axis=1)
    analytics[symbol + '_willr'] = ta.WILLR(high, low, close, timeperiod=14)
    analytics[symbol + '_adx'] = ta.ADX(high, low, close, timeperiod=14)
    analytics[symbol + '_ultosc'] = ta.ULTOSC(high, low, close, timeperiod1=7, timeperiod2=14, timeperiod3=28)
    analytics[symbol + '_obv'] = ta.OBV(close, volume)
    tempDf['upperband'], tempDf['middleband'], tempDf['lowerband'] = ta.BBANDS(close, timeperiod=5, nbdevup=2, nbdevdn=2, matype=0)
    analytics[symbol + '_bbsignalupper'] = tempDf.apply(lambda row: row['close'] / row['upperband'], axis=1)
    analytics[symbol + '_bbsignallower'] = tempDf.apply(lambda row: row['close'] / row['lowerband'], axis=1)
#     print df.rsi.as_matrix(), df.date.as_matrix()
#     funcsOHLCCalls(df, analytics)
#     print analytics
    analytics.set_index('date')
    return analytics

#     exit(0)
############################
# 
# function_names_ohlc = "CDLLADDERBOTTOM,CDLSTALLEDPATTERN,CDLUPSIDEGAP2CROWS,CDLMORNINGDOJISTAR,CDL3STARSINSOUTH"
# 
# def funcsOHLCCalls(dfIn, dfOut):
#     adjClose = dfIn['Adj Close'].as_matrix()
#     closePr = dfIn.close.as_matrix()
#     highPr = dfIn.close.as_matrix()
#     lowPr = dfIn.close.as_matrix()
#     openPr = dfIn.close.as_matrix()
#     volume = dfIn.close.as_matrix()
# 
#     funcs = function_names_ohlc.split(',')
# #     print "funcs=", funcs
#     for f in funcs:
#         toExec = getattr(ta, f)
# #         print f 
#         dfOut[f] = toExec(openPr, highPr, lowPr, adjClose)
