import csv
import pandas as pd
import numpy as np
from sklearn import svm #, feature_selection #, metrics, datasets
import common as cm
import time
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
import pickle
import psycopg2
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import MinMaxScaler
from sklearn.preprocessing.data import Normalizer
from sklearn.model_selection._split import KFold, StratifiedShuffleSplit,\
    StratifiedKFold
import tradeindicators as ti

conn = None
FEATURESELECTIONDATASETLENGTH = cm.FEATURESELECTIONDATASETLENGTH
DATASETLENGTH                 = cm.DATASETLENGTH         
GAMMACOSTDATASETLENGTH        = cm.GAMMACOSTDATASETLENGTH
FITDATASETLENGTH              = cm.FITDATASETLENGTH      
TESTDATASETLENGTH             = cm.TESTDATASETLENGTH     
PREDICTATASETLENGTH           = cm.PREDICTATASETLENGTH     

# cv = KFold(n_splits=5, shuffle=True) #, random_state=42)
# cv = StratifiedShuffleSplit(n_splits=10, test_size=0.1, random_state=42)
cv = StratifiedKFold(n_splits=10, shuffle=True, random_state=42)
g_scaler = MinMaxScaler()

def init():
    global conn
    conn = cm.getdbcon()

def redefineLogRange(origRange, centerValue, rangeLength):
    centerIdxArr, = np.where(origRange >= centerValue) # we will use the first index of that condition and it will be close enough 
    centerIdx = centerIdxArr[0]

    start = origRange[centerIdx]
    end = start
    if centerIdx > 0:
        start = origRange[centerIdx - 1] # get previous value
    if centerIdx < len(origRange) - 1:
        end = origRange[centerIdx + 1] # get next value
#     print "start={0}, end={1}".format(start, end)
#     newRange = np.linspace(np.around(start, 2), np.around(end, 2), rangeLength, dtype=np.float32)
    newRange = np.linspace(start, end, rangeLength, dtype=np.float32)
    print "centerIdxArr={0}, centerIdx={1}, value={2}, start={3}, end={4}\n     new range={5}".\
        format(centerIdxArr, centerIdx, origRange[centerIdx], start, end, newRange)
#     print "new range={0}".format(newRange)
    return newRange

def zoomInGridSearch(clf, X, y):
    startC = -2
#     endC = 10
    endC = 13
    startGamma = -9
#     endGamma = 3
    endGamma = 6
#     rangeLength = 13
    rangeLength = 4

    C_range = np.logspace(startC, endC, rangeLength, dtype=np.float32)
    gamma_range = np.logspace(startGamma, endGamma, rangeLength, dtype=np.float32)
    print "starting C_range={0}, gamma_range={1}".format(C_range, gamma_range)
    rangeLength = 16
    for i in range(3):
        param_grid = dict(gamma=gamma_range, C=C_range)
        grid = GridSearchCV(clf, param_grid=param_grid, cv=cv, n_jobs=-1)
        grid.fit(X, y)
        print "Step {0}: startC={1}, endC={2}, startGamma={3}, endGamma={4}, best params={5}, score={6}"\
            .format(i, startC, endC, startGamma, endGamma, grid.best_params_, grid.best_score_)
            
        C_range = redefineLogRange(C_range, grid.best_params_['C'], rangeLength)
        gamma_range = redefineLogRange(gamma_range, grid.best_params_['gamma'], rangeLength)

    return grid

def gridSearch(clf, X, y):
    gamma_range = np.logspace(-9, 3, 13)
    C_range = np.logspace(-2, 10, 13)
    param_grid = dict(gamma=gamma_range, C=C_range)
    grid = GridSearchCV(clf, param_grid=param_grid, cv=cv, n_jobs=-1)
    grid.fit(X, y)
    return grid

def v2analysis(symbol = '^AORD'):
    (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol)
    
    X_train, X_test, y_train, y_test = train_test_split(X_allDataSet, y_allPredictions, test_size=0.3, random_state=0)
    
    grid = gridSearch(svm.SVC(kernel='rbf'), X_allDataSet[:1000, :], y_allPredictions[:1000])
    bestParams = grid.best_params_
    print 'type(bestParams)={0}'.format(type(bestParams))
    
    start = time.time()
    print 'Start fitting...'
    C = 1.0  # SVM regularization parameter
    svc = svm.SVC(kernel='linear', C=C).fit(X_train, y_train)
    rbf_svc = svm.SVC(kernel='rbf', gamma=0.7, C=C).fit(X_train, y_train)
    rbf_svc_betParams = svm.SVC(kernel='rbf', decision_function_shape='ovr', gamma=bestParams['gamma'], C=bestParams['C']).fit(X_train, y_train)
    poly_svc = svm.SVC(kernel='poly', degree=3, C=C).fit(X_train, y_train)
    lin_svc = svm.LinearSVC(C=C).fit(X_train, y_train)
    print '                ...done in {0} seconds'.format(time.time() - start)
    
    titles = ['SVC with linear kernel',
              'LinearSVC (linear kernel)',
              'SVC with RBF kernel',
              'SVC with RBF kernel and best params C={0}, gamma={1}'.format(bestParams['C'], bestParams['gamma']),
              'SVC with polynomial (degree 3) kernel']
    
    start = time.time()
    print 'Start looping classifiers...'
    for i, clf in enumerate((svc, lin_svc, rbf_svc, rbf_svc_betParams, poly_svc)):
        print '{0}'.format(titles[i])
        print 'Classifier: {0}'.format(clf)
        print 'test score={0}'.format(clf.score(X_test, y_test))
#         cv = StratifiedKFold(n_splits=5, test_size=0.3, random_state=0)
        scores = cross_val_score(clf, X_allDataSet, y_allPredictions, cv=cv)
        print 'cross val scores={0}'.format(scores)
        print("Accuracy as a mean score and the 95 %% confidence interval of the score estimate : %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))
        print '-------------------'
    
    print '                               ...done in {0} seconds'.format(time.time() - start)
    
def gammaCostCalc(symbolCSV, bestFeautures = False):
    symbolList = symbolCSV.split(",")
#     DATALENGTH = 1000
    cur = conn.cursor()
    for symbol in symbolList:
        (colNames, X_allDataSetUnscaled, y_allPredictions, dateList) = loadDataSet( \
                                        symbol, bestFeautures, limit=GAMMACOSTDATASETLENGTH)    
#         g_scaler = StandardScaler()
        X_allDataSet = g_scaler.fit_transform(X_allDataSetUnscaled)
        decision_function_shape='ovr'
        clf = svm.SVC(kernel='rbf', decision_function_shape=decision_function_shape)
    
        grid = gridSearch(clf, X_allDataSet[:GAMMACOSTDATASETLENGTH, :], y_allPredictions[:GAMMACOSTDATASETLENGTH])
#         grid = zoomInGridSearch(clf, X_allDataSet[:DATASETLENGTH, :], y_allPredictions[:DATASETLENGTH])
        bestParams = grid.best_params_
        query = ("UPDATE v2.instrumentsprops SET bestcost={0}, bestgamma={1} WHERE symbol = '{2}';"
                 .format(bestParams['C'], bestParams['gamma'], symbol))
    
        cur.execute(query)
        
        # No need to save g_scaler and classifier here. They have to be savesd only in fitAndSave()
#         clfTrained = svm.SVC(kernel='rbf', C=bestParams['C'], gamma=bestParams['gamma'], \
#                              decision_function_shape=decision_function_shape)\
#                                 .fit(X_allDataSet, y_allPredictions)
#         binDump = pickle.dumps(clfTrained)
#         cur.execute("UPDATE v2.instrumentsprops SET classifierdump=%s where symbol=%s", (psycopg2.Binary(binDump), symbol))
#         conn.commit()               # commit separately to ensure this is in as the next operation might fail 
        print '{0} found Cost={1} gamma={2} bestScore={3}, saved'.\
            format(symbol, bestParams['C'], bestParams['gamma'], grid.best_score_)

    cur.close();

def fitAndSave(symbolCSV, bestFeautures = False):
    symbolList = symbolCSV.split(",")
    cur = conn.cursor()
    for symbol in symbolList:
#         (colNames, X_allDataSetUnscaled, y_allPredictions, dateList) = loadDataSet(symbol, bestFeautures, offset=200, limit=FITDATASETLENGTH)
        (colNames, X_allDataSetUnscaled, y_allPredictions, dateList) = loadDataSet(symbol, offset=0, limit=FITDATASETLENGTH, useCache=True)
        X_reduced = X_allDataSetUnscaled[TESTDATASETLENGTH:,]
        y_reduced = y_allPredictions[TESTDATASETLENGTH:,]
#         print ' all data shape: {0}, X_reduced shape: {1}'.format(X_allDataSetUnscaled.shape, X_reduced.shape)

# using global         g_scaler = StandardScaler()
        X_allDataSet = g_scaler.fit_transform(X_reduced)
        decision_function_shape='ovr'
        bestParams = loadBestParams(symbol)
        clfTrained = svm.SVC(kernel='rbf', \
#                              C=10,
# use default for now C and gamma         C=bestParams[0], gamma=bestParams[1], \
                             decision_function_shape=decision_function_shape).fit(X_allDataSet, y_reduced)
        binDump = pickle.dumps(clfTrained)
        binDumpScaler = pickle.dumps(g_scaler)
        cur.execute("UPDATE v2.instrumentsprops SET classifierdump=%s, scalerdump=%s where symbol=%s", \
                    (psycopg2.Binary(binDump), psycopg2.Binary(binDumpScaler), symbol))
        conn.commit()
        print '{0}: Fit classification for gamma={1} Cost={2} saved'.format(symbol, bestParams[1], bestParams[0])

    cur.close();

def loadDataSet(symbol, isUseBestFeautures = False, offset=50, limit=DATASETLENGTH, useCache=False):
    return ti.loadDataSet(symbol, isUseBestFeautures, offset, limit, useCache)

def loadDataSet_(symbol, isUseBestFeautures = False, offset=50, limit=DATASETLENGTH):
    cur = conn.cursor()
    if isUseBestFeautures:
        print 'Using best features. isUseBestFeautures = {0}, offset={1}, limit={2}'.format(isUseBestFeautures, offset, limit)
        cur.execute("select bestattributes from v2.instrumentsprops where symbol = '{0}'".format(symbol))
        bestFeatures = cur.fetchone()
        query = ("select date,instrument,{0},prediction from v2.datamining_aggr_view "\
                 "where instrument = \'{1}\' order by date desc offset {2} limit {3}")\
            .format(bestFeatures[0], symbol, offset, limit)
    else:
        print 'Using all available features. isUseBestFeautures = {0}, offset={1}, limit={2}'.format(isUseBestFeautures, offset, limit)
        query = ("select * from v2.datamining_aggr_view where instrument = \'{0}\' order by date desc offset {1} limit {2}")\
            .format(symbol, offset, limit)

    start = time.time()
    cur.execute(query)
    print '                  ...done in {0} seconds'.format(time.time() - start)

    records = cur.fetchall()
    
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

def getCrossValMeanScore(clf, dataSet, predictions):
    scores = cross_val_score(clf, dataSet, predictions, cv=cv)
    return (scores.mean(), scores.std())

def loadBestParams(symbol):
    query = "select bestcost, bestgamma from v2.instrumentsprops WHERE symbol='{0}';".format(symbol)
    cur = conn.cursor()
    cur.execute(query)
    bestParams = cur.fetchone()
    print 'bestParams={0}'.format(bestParams)
    return bestParams

def optimiseFeautures(symbolCSV):
    symbolList = symbolCSV.split(",")
    cur = conn.cursor()
    for symbol in symbolList:
        (colNames, X_allDataSetUnscaled, y_allPredictions, dateList) = loadDataSet(\
                            symbol, limit=FEATURESELECTIONDATASETLENGTH)
# using global        g_scaler = StandardScaler()
        X_allDataSet = g_scaler.fit_transform(X_allDataSetUnscaled)
        print "Optimizing features for '{0}'".format(symbol)
        decision_function_shape='ovr'
        bestParams = loadBestParams(symbol)

        clfLoaded = svm.SVC(kernel='rbf', 
# use default for now                 C=bestParams[0],\
# use default for now                 gamma=bestParams[1], \
                            decision_function_shape=decision_function_shape).fit(X_allDataSet, y_allPredictions)

        excludedIndexes = []
        excludedCols = []
        goodIndexes = []
        goodCols = []
        (bestMeanScore, bestMeanStd) = getCrossValMeanScore(clfLoaded, X_allDataSet, y_allPredictions)
        X_reduced = np.copy(X_allDataSet)
        for curIdx, colName in enumerate(colNames):
            testExcludedIndexes = np.append(excludedIndexes, curIdx)
            testX_reduced = np.delete(X_reduced, testExcludedIndexes, axis=1)
            (meanScore, meanStd) = getCrossValMeanScore(clfLoaded, testX_reduced, y_allPredictions)
            if bestMeanScore/bestMeanStd <= meanScore/meanStd:
                excludedIndexes.append(curIdx)
                excludedCols.append(colName)
                print 'Excluded column {0}. bestMeanScore/bestMeanStd {1}/{2} <= meanScore/meanStd {3}/{4}'\
                    .format(colName, bestMeanScore, bestMeanStd, meanScore, meanStd)
                bestMeanScore = meanScore
                bestMeanStd = meanStd
            else:
                goodCols.append(colName)
                goodIndexes.append(curIdx)
                print 'Column {0} is good. bestMeanScore/bestMeanStd {1}/{2} > meanScore/meanStd {3}/{4}'\
                    .format(colName, bestMeanScore, bestMeanStd, meanScore, meanStd)
        
        goodColsStr = ','.join(goodCols)
        excludedColsStr = ','.join(excludedCols)
        
        query = ("UPDATE v2.instrumentsprops SET bestattributes='{0}', excludedattributes='{1}', bestcorrelation={2}"
                 " WHERE symbol = '{3}';"
                 .format(goodColsStr, excludedColsStr, bestMeanScore, symbol))
        cur.execute(query)
        conn.commit()               # commit separately to ensure this is in as the next operation might fail 
        print 'optimiseFeautures done. bestMeanScore={0}, bestMeanStd={1}'.format(bestMeanScore, bestMeanStd)

def testPerformance(symbolCSV):
    symbolList = symbolCSV.split(",")

    for symbol in symbolList:
#         (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol, True, offset=200, limit=DATASETLENGTH)
#         (colNames, X_allDataSetTestUnscaled, y_allPredictionsTest, dateList) = loadDataSet(symbol, True, offset=100, limit=100)
#         print ' all data shape: {0}, test shape: {1}'.format(X_allDataSet.shape, X_allDataSetTestUnscaled.shape)
        (clf, l_scaler) = loadClassifier(symbol)
        (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol, isUseBestFeautures=False, offset=0, limit=FITDATASETLENGTH, useCache=True)
        X_allDataSetScaled = l_scaler.transform(X_allDataSet)
        X_reduced = X_allDataSetScaled[TESTDATASETLENGTH:,]
        y_reduced = y_allPredictions[TESTDATASETLENGTH:,]
        X_test = X_allDataSetScaled[0:TESTDATASETLENGTH,]
        y_test = y_allPredictions[0:TESTDATASETLENGTH,]

#         print ' all data shape: {0}, X_reduced shape: {1}, X_test shape: {2}'.format(X_allDataSetScaled.shape, X_reduced.shape, X_test.shape)
        (meanScore, std) = getCrossValMeanScore(clf, X_reduced, y_reduced)
        print '%6s: meanScore=%.3f std=%.3f  clf score on test=%.3f' % \
            (symbol, meanScore, std, clf.score(X_test, y_test))
#         print '{0} meanScore = {1}, std = {2}, clf score on test = {3}'.\
#             format(symbol, meanScore, std, clf.score(X_test, y_test))

def isPredictionCorrect(prediction, priceDiff):
    if type(priceDiff) is str:
        return "Unknown"
    else:
        return prediction == ti.formatLabel(priceDiff)
#         return  (priceDiff > 1) and (prediction == 1) or \
#             (priceDiff <= 1) and (prediction == 0)
#         return  (priceDiff > 1 + MOVEPRCNT) and (prediction == 1) or \
#             (priceDiff < 1 - MOVEPRCNT) and (prediction == 2) or \
#             (1 - MOVEPRCNT <= priceDiff <= 1 + MOVEPRCNT) and (prediction == 0)

def loadClassifier(symbol):
    cur = conn.cursor()
    cur.execute("SELECT classifierdump, scalerdump FROM v2.instrumentsprops where symbol=%s;", (symbol, ))
    blob = cur.fetchone()
    readClfDump = blob[0]
    readScalerDump = blob[1]
    clfLoaded = pickle.loads(readClfDump)
    scalerLoaded = pickle.loads(readScalerDump)
    return (clfLoaded, scalerLoaded)

def predict(symbolCSV, offset=0):
    symbolList = symbolCSV.split(",")
    cur = conn.cursor()
    print "Using offset={0}".format(offset)
    print "DF date,Date From,Symbol,Orig Price,Prediction For Date,Last Available Date Price,prediction," \
                "Price Diff,Is Correct"
    for symbol in symbolList:
        (clf, l_scaler) = loadClassifier(symbol)
        (colNames, X_allDataSetUnscaled, y_predictions, datesList) = loadDataSet(\
                                    symbol, isUseBestFeautures=False, offset=0, limit=PREDICTATASETLENGTH)
        X_allDataSet = l_scaler.transform(X_allDataSetUnscaled)

        np.savetxt(symbol + "_dates.csv", datesList, "%s", ",")
        offsetInt = int(offset)
        theDate = datesList[offsetInt]
        toPredictDataSet = X_allDataSet[offsetInt].reshape(1, -1)
        cur.execute("select date, \"Adj Close\" from stocks where stock = %s and date >= %s order by date asc limit 1",\
                    (symbol, theDate))
        dateAndPriceClosest = cur.fetchall()
        dbFoundDate = dateAndPriceClosest[0][0];
        dbFoundStockPrice = dateAndPriceClosest[0][1];
        cur.execute("select date, \"Adj Close\" from stocks where stock = %s and date >= %s + '1 month'::interval order by date asc limit 1"\
                    , (symbol, theDate))
        stockDateAndPriceInAMonthList = cur.fetchall()
        if len(stockDateAndPriceInAMonthList) > 0:
            predictionForDate = stockDateAndPriceInAMonthList[0][0]
            lastAvailableDateStockPrice = stockDateAndPriceInAMonthList[0][1]
            priceDiff = lastAvailableDateStockPrice/dbFoundStockPrice
        else:
            predictionForDate = 'None'
            lastAvailableDateStockPrice = 'None'
            priceDiff = 'None'

        prediction = clf.predict(toPredictDataSet)
        thePrediction = prediction[0]
#         print "Using samples from array:\n{0}\nshape:{1}".format(X_allDataSet, X_allDataSet.shape)
#         print "Using first from predictions array: {0}".format(prediction)
        print "{0},{1},{2},{3},{4},{5},{6},{7},{8}"\
            .format(theDate, dbFoundDate, symbol, dbFoundStockPrice, predictionForDate, lastAvailableDateStockPrice, \
                    thePrediction, priceDiff, isPredictionCorrect(thePrediction, priceDiff))

#########################
