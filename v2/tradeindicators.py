#create matrix for ml with various trading indicators 
import common as cm
import talib as ta
import numpy as np
import pandas as pd
import time
import json
import re
import sys
from psycopg2._psycopg import cursor
from matplotlib.cbook import Null
import yaml

# earliestDatTime = "2015-05-12"
allinstr = []

global fullDataFrame
fullDataFrame = None

settingsMap = None

if settingsMap is None:
    f = open('./v2/settings.yaml')
    settingsMap = yaml.safe_load(f)
    f.close()

# conn = cm.getdbcon()
# settingsMap = cm.loadSettings()
cursor = None

def cur():
    global cursor
    if cursor is None:
        cursor = cm.getdbcon().cursor()
    return cursor

# backShiftDays = -30
# difftreshhold = 0.02
# upper = 1 + difftreshhold
# lower = 1 - difftreshhold
# print '++++++++++++++++{}'.format(cm.settingsMap)

def backShiftDays():
    return settingsMap["root"]["trdeindicators"]["backShiftDays"]

def difftreshhold():
    return settingsMap["root"]["trdeindicators"]["difftreshhold"]

def upper():
    return settingsMap["root"]["trdeindicators"]["upper"]

def lower():
    return settingsMap["root"]["trdeindicators"]["lower"]

# print 'backShiftDays={}'.format(backShiftDays)
# exit(1)

def formatLabel(priceDiff):
    if priceDiff > upper():
        return 'up'
    elif upper() >= priceDiff >= lower():
        return 'undef'
    elif lower > priceDiff >= 0:
        return 'down'
    else:
        return '???'

def getFullDataFrameInstance(isUseBestFeautures, offset, limit, datefrom, useCache, symbol='_'):
    global fullDataFrame
    if not useCache or fullDataFrame is None: # then load
        fullDataFrame = loadCleanAllDataFrame(isUseBestFeautures, offset, limit, datefrom, symbol)
        fullDataFrame.to_csv(symbol + '_cacheable.csv', sep=',')
        print 'fullDataFrame loaded'

    return fullDataFrame

def onlyGoodFeatures(fullDataFrame, symbol):
    cur().execute("select bestattributes from v2.instrumentsprops where symbol = '{}'".format(symbol))
    bestFeatures = cur().fetchone()
    bestColList = bestFeatures[0].split(',')
    retVal = fullDataFrame[bestColList]
    return retVal

def loadDataSet(symbol, isUseBestFeautures, offset, limit, datefrom, useCache=cm.isUseCache):
    fullDataFrame = getFullDataFrameInstance(isUseBestFeautures, offset, limit, datefrom, useCache, symbol)
    
#     sys.stdout.write('Orig fullDataFrame shape = {}'.format(fullDataFrame.shape))
    if isUseBestFeautures:
        workingDataFrame = onlyGoodFeatures(fullDataFrame, symbol)
#         sys.stdout.write('. Only good features filtered. Best col shape = {}\n'.format(workingDataFrame.shape))
    else:
        workingDataFrame = fullDataFrame

    #classificationLabels calculation
    closeColumn = symbol + '_close'
    mlDf = pd.DataFrame()
    mlDf['close']        =  fullDataFrame[closeColumn]
    mlDf['backshift']    =  fullDataFrame[closeColumn].shift(backShiftDays())
    mlDf['backshiftdiff']=  fullDataFrame[closeColumn] / fullDataFrame[closeColumn].shift(backShiftDays())
    mlDf['labelFormat']  = (mlDf['close'] / mlDf['backshift']).map(formatLabel)
    classificationLabels = (mlDf['close'] / mlDf['backshift']).map(formatLabel)
#     mlDf.to_csv(symbol + '_shiftsDFTest.csv', sep=',')

    #ret vals creation
    p = re.compile('^.+_close$')
    closeOnlyColNames = filter(p.match, workingDataFrame.columns.values)
    noCloseDf = workingDataFrame.drop(closeOnlyColNames, axis=1)
    noCloseColNames = noCloseDf.columns.values
    X_dataSet = noCloseDf.as_matrix()
    y_predictions = classificationLabels.values
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
    cur().execute("select * from stocks where stock=%s and date >= %s order by date desc offset %s limit %s", \
                (symbol, datefrom, offset, limit))

    records = cur().fetchall()
    colNames = np.array(cur().description)[:,0]
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
    macd, signal, analytics[symbol + '_macdhist1'] = ta.MACD(close, fastperiod=12, slowperiod=26, signalperiod=9)
    macd, signal, analytics[symbol + '_macdhist2'] = ta.MACD(close, fastperiod=8, slowperiod=17, signalperiod=9)
    analytics[symbol + '_mfi1'] = ta.MFI(high, low, close, volume, timeperiod=14)
    analytics[symbol + '_mfi2'] = ta.MFI(high, low, close, volume, timeperiod=20)
    analytics[symbol + '_roc1'] = ta.ROC(close, timeperiod=10)
    analytics[symbol + '_roc2'] = ta.ROC(close, timeperiod=20)
    tempDf['stochk1'], tempDf['stochd1'] = ta.STOCH(high, low, close, fastk_period=5, slowk_period=3, slowk_matype=0, slowd_period=3, slowd_matype=0)
    tempDf['stochk2'], tempDf['stochd2'] = ta.STOCH(high, low, close, fastk_period=10, slowk_period=6, slowk_matype=0, slowd_period=6, slowd_matype=0)
#     analytics[symbol + '_stochsignal'] = asc_df.apply(stochdif, axis=1)
    analytics[symbol + '_stochsignal1'] = tempDf.apply(lambda row: row['stochk1'] - row['stochd1'], axis=1)
    analytics[symbol + '_stochsignal2'] = tempDf.apply(lambda row: row['stochk2'] - row['stochd2'], axis=1)
    analytics[symbol + '_willr1'] = ta.WILLR(high, low, close, timeperiod=14)
    analytics[symbol + '_willr2'] = ta.WILLR(high, low, close, timeperiod=28)
    analytics[symbol + '_adx1'] = ta.ADX(high, low, close, timeperiod=14)
    analytics[symbol + '_adx2'] = ta.ADX(high, low, close, timeperiod=28)
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
    return analytics

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
    
    lastValidIndexSeries.to_csv('lastValidIndexSeries.csv', sep=',')
    firstValidIndexSeries.to_csv('firstValidIndexSeries.csv', sep=',')
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
