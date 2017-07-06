#create matrix for ml with various trading indicators 
import talib as ta
import numpy as np
import pandas as pd
import common as cm
import time
import json
import re

# earliestDatTime = "2015-05-12"

allinstr = []

global fullDataFrame
fullDataFrame = None

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

def getFullDataFrameInstance(symbol, isUseBestFeautures, offset, limit):
    global fullDataFrame
    if fullDataFrame == None:
        fullDataFrame = loadCleanAllDataFrame(symbol, isUseBestFeautures, offset, limit)
    return fullDataFrame

def loadDataSet(symbol, isUseBestFeautures, offset, limit):
    fullDataFrame = getFullDataFrameInstance(symbol, isUseBestFeautures, offset, limit)
    
    #classificationLabels calculation
    mlDf = pd.DataFrame()
    mlDf['close'] = fullDataFrame[symbol + '_close']
    mlDf['nextshift'] = fullDataFrame[symbol + '_close'].shift(shiftDays)
    mlDf['shiftdiff'] = fullDataFrame[symbol + '_close'].shift(shiftDays) / fullDataFrame[symbol + '_close']
    mlDf['labelFormat'] = (fullDataFrame[symbol + '_close'].shift(shiftDays) / fullDataFrame[symbol + '_close']).map(formatLabel)
    classificationLabels = (fullDataFrame[symbol + '_close'].shift(shiftDays) / fullDataFrame[symbol + '_close']).map(formatLabel)

    mlDf.to_csv('shiftsDFTest.csv', sep=',')

    #ret vals creation
    p = re.compile('^.+_close$')
    closeOnlyColNames = filter(p.match, fullDataFrame.columns.values)
    noCloseDf = fullDataFrame.drop(closeOnlyColNames, axis=1)
    noCloseColNames = noCloseDf.columns.values
    noCloseDf.to_csv('concatDFTestNoCloseCols.csv', sep=',')
#     print "closeOnlyColNames={0}".format(closeOnlyColNames)
#     print "noCloseColNames={0}".format(noCloseColNames)
    X_dataSet = noCloseDf.as_matrix()
    y_predictions = classificationLabels.values
    dateList = fullDataFrame.index.values
    return (noCloseColNames, X_dataSet, y_predictions, dateList)

def loadCleanAllDataFrame(symbol, isUseBestFeautures, offset, limit):
    allinstr = loadAllInstrJson()

    instrAr = list(allinstr)
    instrAr.remove(symbol)
    instrAr.insert(0, symbol)
#     print 'instrAr=', instrAr
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

def loadAllInstrJson():
    jsonDict = None
    allinstr = []
    with open('v2/helper/download-list.json') as json_data:
        jsonDict = json.load(json_data)
    for instr in jsonDict["allInstr"]:
        allinstr.append(instr["name"])
    
    return allinstr
