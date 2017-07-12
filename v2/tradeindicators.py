#create matrix for ml with various trading indicators 
import talib as ta
import numpy as np
import pandas as pd
import common as cm
import time
import json
import re
import sys

# earliestDatTime = "2015-05-12"
allinstr = []

global fullDataFrame
fullDataFrame = None

conn = cm.getdbcon()
cur = conn.cursor()
backShiftDays = -30
difftreshhold = 0.01

def formatLabel_(x):
    if x > 1:
        return 'up'
    else:
        return 'down'

def formatLabel(x):
    if x > 1 + difftreshhold:
        return 'up'
    elif x <= 1 - difftreshhold:
        return 'down'
    else:
        return 'undef'

def getFullDataFrameInstance(isUseBestFeautures, offset, limit, datefrom, useCache, symbol='_'):
    global fullDataFrame
    if not useCache or fullDataFrame is None: # then load
        fullDataFrame = loadCleanAllDataFrame(isUseBestFeautures, offset, limit, datefrom, symbol)
        fullDataFrame.to_csv(symbol + '_cacheable.csv', sep=',')
        print 'fullDataFrame loaded'

    return fullDataFrame

def loadDataSet(symbol, isUseBestFeautures, offset, limit, datefrom, useCache=cm.isUseCache):
    fullDataFrame = getFullDataFrameInstance(isUseBestFeautures, offset, limit, datefrom, useCache, symbol)
    
    #classificationLabels calculation
    closeColumn = symbol + '_close'
    mlDf = pd.DataFrame()
    mlDf['close']        =  fullDataFrame[closeColumn]
    mlDf['backshift']    =  fullDataFrame[closeColumn].shift(backShiftDays)
    mlDf['backshiftdiff']=  fullDataFrame[closeColumn] / fullDataFrame[closeColumn].shift(backShiftDays)
    mlDf['labelFormat']  = (mlDf['close'] / mlDf['backshift']).map(formatLabel)
    classificationLabels = (mlDf['close'] / mlDf['backshift']).map(formatLabel)
#     mlDf.to_csv(symbol + '_shiftsDFTest.csv', sep=',')
#     exit(1)

#     print fullDataFrame.index.values
    #ret vals creation
    p = re.compile('^.+_close$')
    closeOnlyColNames = filter(p.match, fullDataFrame.columns.values)
    noCloseDf = fullDataFrame.drop(closeOnlyColNames, axis=1)
    noCloseColNames = noCloseDf.columns.values
#     noCloseDf.to_csv('concatDFTestNoCloseCols.csv', sep=',')
    X_dataSet = noCloseDf.as_matrix()
    y_predictions = classificationLabels.values
#     print "{0}".format(','.join(y_predictions))
#     exit(1)
#     dateList = fullDataFrame.index.values
    dateList = noCloseDf.index.values
    return (noCloseColNames, X_dataSet, y_predictions, dateList)

def loadCleanAllDataFrame(isUseBestFeautures, offset, limit, datefrom, symbol = '_'):
    allinstr = loadAllInstrJson()

    instrAr = list(allinstr)
    joinedDf = None
    for instr in instrAr:
        newDf = loadSymbolTechAnalytics(instr, offset, limit, datefrom)
        if joinedDf is None:
            joinedDf = newDf.set_index('date')
        else:
            joinedDf = joinedDf.join(newDf.set_index('date'), how='outer')

#     # arrays still in ascending order!
#     # get the first valid index for each column and calculate the max
#     firstValidIndexSeries = joinedDf.apply(lambda col: col.first_valid_index())
#     first_valid_loc = firstValidIndexSeries.max()
#     df = joinedDf.loc[first_valid_loc:]
#     df = df.dropna(axis=1, how='all')
# #     df.to_csv('cleanedOldDates.csv', sep=',')
#     
#     # get the last valid index for each column and calculate the min
#     lastValidIndexSeries = df.apply(lambda col: col.last_valid_index())
#     last_valid_loc = lastValidIndexSeries.min()
#     df = df.loc[:last_valid_loc]
    df = cleanInvalidRows(joinedDf)
    df = df.dropna(axis=1, how='all')   # clean NaN columns
    df = df.fillna(method='ffill').fillna(method='bfill')   #fill missing values
    
    return df.iloc[::-1] # return descending date

def loadSymbolTechAnalytics(symbol, offset, limit, datefrom):
    # get in desc order to ensure last dates data is in as limit might cut it out
    cur.execute("select * from stocks where stock=%s and date >= %s order by date desc offset %s limit %s", \
                (symbol, datefrom, offset, limit))

    records = cur.fetchall()
    colNames = np.array(cur.description)[:,0]
    desc_df = pd.DataFrame.from_records(records, columns=colNames)
    asc_df = desc_df.iloc[::-1] # return ascending date
    date = asc_df['date'].as_matrix()
    close = np.asarray(asc_df['Adj Close'].as_matrix(), dtype='float')
    closeSimple = asc_df.close.as_matrix()
    high = asc_df.high.as_matrix()
    low = asc_df.low.as_matrix()
    open_ = asc_df.open.as_matrix()
    volume = np.asarray(asc_df.volume.as_matrix(), dtype='float')

    analytics = pd.DataFrame()
    analytics['date'] = date
    analytics[symbol + '_close'] = close
    tempDf = pd.DataFrame()
    tempDf['close'] = close
    analytics[symbol + '_rsi'] = ta.RSI(close)
    macd, signal, analytics[symbol + '_macdhist'] = ta.MACD(close, fastperiod=12, slowperiod=26, signalperiod=9)
    analytics[symbol + '_mfi'] = ta.MFI(high, low, close, volume, timeperiod=14)
    analytics[symbol + '_roc'] = ta.ROC(close, timeperiod=10)
    tempDf['stochk'], tempDf['stochd'] = ta.STOCH(high, low, close, fastk_period=5, slowk_period=3, slowk_matype=0, slowd_period=3, slowd_matype=0)
#     analytics[symbol + '_stochsignal'] = asc_df.apply(stochdif, axis=1)
    analytics[symbol + '_stochsignal'] = tempDf.apply(lambda row: row['stochk'] - row['stochd'], axis=1)
    analytics[symbol + '_willr'] = ta.WILLR(high, low, close, timeperiod=14)
    analytics[symbol + '_adx'] = ta.ADX(high, low, close, timeperiod=14)
    analytics[symbol + '_ultosc'] = ta.ULTOSC(high, low, close, timeperiod1=7, timeperiod2=14, timeperiod3=28)
    analytics[symbol + '_obv'] = ta.OBV(close, volume)
    tempDf['upperband'], tempDf['middleband'], tempDf['lowerband'] = ta.BBANDS(close, timeperiod=5, nbdevup=2, nbdevdn=2, matype=0)
    analytics[symbol + '_bbsignalupper'] = tempDf.apply(lambda row: row['close'] / row['upperband'], axis=1)
    analytics[symbol + '_bbsignallower'] = tempDf.apply(lambda row: row['close'] / row['lowerband'], axis=1)
    analytics.set_index('date')
    
    # TODO: add more analytics
    
    #?? maybe we do not need the below line due to various length history giving issues for prediction vs fitting
#     retVal = cleanInvalidRows(analytics)
#     retVal.to_csv(symbol.replace('/', '_') + '_cleanedNansAnzZeroCols.csv', sep=',')
    return retVal

def cleanInvalidRows(dfUnclean):
    # arrays still in ascending order!
    # get the first valid index for each column and calculate the max
    firstValidIndexSeries = dfUnclean.apply(lambda col: col.first_valid_index())
    first_valid_loc = firstValidIndexSeries.max()
    df = dfUnclean.loc[first_valid_loc:]
#     df = df.dropna(axis=1, how='all')
    
    # get the last valid index for each column and calculate the min
    lastValidIndexSeries = df.apply(lambda col: col.last_valid_index())
    last_valid_loc = lastValidIndexSeries.min()
    df = df.loc[:last_valid_loc]
#     df = df.dropna(axis=1, how='all')       # rop all NaN
#     df = df.loc[:, (df != 0).any(axis=0)]   # remove all zeros columns
#     df = df.replace(0, np.NaN)
    return df

def loadAllInstrJson():
    jsonDict = None
    allinstr = []
    with open('v2/helper/download-list.json') as json_data:
        jsonDict = json.load(json_data)
    for instr in jsonDict["allInstr"]:
        allinstr.append(instr["name"])
    
    return allinstr
