#create matrix for ml with various trading indicators 
import talib as ta
import numpy as np
import pandas as pd
import common as cm
import time

conn = cm.getdbcon()
cur = conn.cursor()

def stochdif(row):
    return row['stochk'] - row['stochd']

def loadDataSet(symbol, isUseBestFeautures, offset, limit):
    print 'isUseBestFeautures = {0}, offset={1}, limit={2}'.format(isUseBestFeautures, offset, limit)
    start = time.time()
#     cur.execute("select date, \"Adj Close\" as price from stocks where stock=%s order by date desc offset %s limit %s", (symbol, offset, limit))
    cur.execute("select * from stocks where stock=%s order by date desc offset %s limit %s", (symbol, offset, limit))
    print '                  ...done in {0} seconds'.format(time.time() - start)
    records = cur.fetchall()
    colNames = np.array(cur.description)[:,0]
#     print 'colnames', colNames
    desc_df = pd.DataFrame.from_records(records, columns=colNames)
    desc_df.set_index('date')
    df = desc_df.iloc[::-1]

#     analysis = pd.DataFrame(index = df.index)
    adjClose = df['Adj Close'].as_matrix()
    close = df.close.as_matrix()
    high = df.close.as_matrix()
    low = df.close.as_matrix()
    open = df.close.as_matrix()
    volume = df.close.as_matrix()
    
    analytics = pd.DataFrame()
#     rsiAr = ta.RSI(adjClose)
    analytics['rsi'] = ta.RSI(adjClose)
    macd, signal, analytics['macdhist'] = ta.MACD(adjClose, fastperiod=12, slowperiod=26, signalperiod=9)
    analytics['mfi'] = ta.MFI(high, low, close, volume, timeperiod=14)
    analytics['roc'] = ta.ROC(adjClose, timeperiod=10)
    analytics['stochk'], analytics['stochd'] = ta.STOCH(high, low, adjClose, fastk_period=5, slowk_period=3, slowk_matype=0, slowd_period=3, slowd_matype=0)
#     analytics['stochsignal'] = df.apply(stochdif, axis=1)
    analytics['stochsignal'] = analytics.apply(lambda row: row['stochk'] - row['stochd'], axis=1)
    analytics['willr'] = ta.WILLR(high, low, adjClose, timeperiod=14)
#     print df.rsi.as_matrix(), df.date.as_matrix()
    funcsOHLCCalls(df, analytics)
    print analytics

    exit(0)
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

def toMatrix(prices):
    macd = prices.apply(MACD, fastperiod=10, slowperiod=20, signalperiod=9)
    return macd

# Define the MACD function   
def MACD(prices, fastperiod=12, slowperiod=26, signalperiod=9):
    '''
    Function to return the difference between the most recent 
    MACD value and MACD signal. Positive values are long
    position entry signals 
    Returns: macd - signal
    '''
    print '---type(prices)={0}'.format(type(prices))
    macd, signal, hist = ta.MACD(prices,
                                    fastperiod=fastperiod, 
                                    slowperiod=slowperiod, 
                                    signalperiod=signalperiod)
    return hist

def mvCrossOverSignals(symbolCSV, offset=0, limit=10):
    symbolList = symbolCSV.split(",")
    cur = conn.cursor()
    print "Using offset={0}, limit={1}".format(offset,limit)
    for symbol in symbolList:
#         (X_allDataSet, datesList) = loadOneRecord(symbol, offset)
#         (colNames, X_allDataSet, y_predictions, datesList) = loadDataSet(symbol, isUseBestFeautures=True, offset=offset, limit=limit)
        cur.execute("select \"Adj Close\" from stocks where stock=%s offset %s limit %s", \
                    (symbol, offset, limit))
        stockPrice = cur.fetchall()
#         print type(stockPrice), stockPrice
        print ta.MACD(np.array(stockPrice)[:,0].astype(np.float32))

function_names_ohlc = "CDLLADDERBOTTOM,CDLSTALLEDPATTERN,CDLUPSIDEGAP2CROWS,CDLMORNINGDOJISTAR,CDL3STARSINSOUTH"

def funcsOHLCCalls(dfIn, dfOut):
    adjClose = dfIn['Adj Close'].as_matrix()
    closePr = dfIn.close.as_matrix()
    highPr = dfIn.close.as_matrix()
    lowPr = dfIn.close.as_matrix()
    openPr = dfIn.close.as_matrix()
    volume = dfIn.close.as_matrix()

    funcs = function_names_ohlc.split(',')
#     print "funcs=", funcs
    for f in funcs:
        toExec = getattr(ta, f)
#         print f 
        dfOut[f] = toExec(openPr, highPr, lowPr, adjClose)
