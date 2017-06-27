#create matrix for ml with various trading indicators 
import talib as ta
import numpy as np
import pandas as pd
import common as cm
import time
from pip._vendor.colorama.initialise import atexit_done

allinstr = [ 
'^AORD',
'^N225',
'^NDX',
'^GDAXI',
'^SSEC',
'^HSI',
'^BSESN',
'^JKSE',
'^KLSE',
'^NZ50',
'^STI',
'^KS11',
'^TWII',
'^BVSP',
'^GSPTSE',
'^MXX',
'^GSPC',
'^ATX',
'^BFX',
'^FCHI',
'^OSEAX',
'^OMXSPI',
'FXA',
'FXB',
'FXC',
'FXE',
'FXF',
'FXS',
'FXY',
'CHOC',
'CORN',
'CTNN',
'CUPM',
'FOIL',
'GAZ',
'GLD',
'HEVY',
'LEDD',
'LSTK',
'NINI',
'OIL',
'PALL',
'PPLT',
'SGAR',
'SLV',
'SOYB',
'UHN'
]

conn = cm.getdbcon()
cur = conn.cursor()

def loadDataSet(symbol, isUseBestFeautures, offset, limit):
    df = []
    instrAr = list(allinstr)
    instrAr.remove(symbol)
    instrAr.insert(0, symbol)
    print 'instrAr=', instrAr
#     for instr in instrAr:
#         df.append(loadDataFrame(instr, offset, limit))
    joinedDf = None
    for instr in instrAr:
        newDf = loadDataFrame(instr, offset, limit)
        if joinedDf is None:
            joinedDf = newDf.set_index('date')
        else:
            joinedDf = joinedDf.join(newDf.set_index('date'), how='outer')

        joinedDf.to_csv('concatDFTest.csv', sep=',')
#         joinedDf = joinedDf.reindex(['date'])
#         joinedDf = joinedDf.set_index(['date'])
        
    joinedDf.to_csv('concatDFTest.csv', sep=',')
    return joinedDf

def loadDataFrame(symbol, offset, limit):
    print 'symbol="{0}" offset={1} limit={2}'.format(symbol, offset, limit)
    start = time.time()
#     cur.execute("select date, \"Adj Close\" as price from stocks where stock=%s order by date desc offset %s limit %s", (symbol, offset, limit))
    cur.execute("select * from stocks where stock=%s order by date desc offset %s limit %s", (symbol, offset, limit))
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

    numpyRecords = np.array(records)
    X_allDataSet = numpyRecords[:, 2:-1].astype(np.float32)
    colNames = np.array(cur.description)[2:-1, 0]
    yRaw = numpyRecords[:, -1:].astype(np.float32)
    
    yArr = []
    
    for line in yRaw:
        diff = line[0]
#         if diff > (1 + MOVEPRCNT):
#             yArr.append(1)
#         elif diff < (1 - MOVEPRCNT):
#             yArr.append(2)
        if diff > 1:
            yArr.append(1)
        else:
            yArr.append(0)

    y_allPredictions = np.array(yArr)
    dateList = numpyRecords[:, 0]
    return (colNames, X_allDataSet, y_allPredictions, dateList)
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
