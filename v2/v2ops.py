import datetime as dt
import csv
import pandas as pd
import numpy as np
from sklearn import svm #, feature_selection #, metrics, datasets
import tradeindicators as ti
import common as cm
import time
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
import pickle
import psycopg2
import settings as st

from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import MinMaxScaler
from sklearn.preprocessing.data import Normalizer
from sklearn.model_selection._split import KFold, StratifiedShuffleSplit,\
    StratifiedKFold

FEATURESELECTIONDATASETLENGTH = st.DICT["root"]["common"]["FEATURESELECTIONDATASETLENGTH"]    
DATASETLENGTH                 = st.DICT["root"]["common"]["DATASETLENGTH"] 
GAMMACOSTDATASETLENGTH        = st.DICT["root"]["common"]["GAMMACOSTDATASETLENGTH"]
FITDATASETLENGTH              = st.DICT["root"]["common"]["FITDATASETLENGTH"]
TESTDATASETLENGTH             = st.DICT["root"]["common"]["TESTDATASETLENGTH"]
PREDICTATASETLENGTH           = st.DICT["root"]["common"]["PREDICTATASETLENGTH"] 
FITDATEFROM                   = dt.datetime.strptime('1982-01-01','%Y-%m-%d')

# FITDATEFROM                   = dt.datetime.strptime('2000-01-01','%Y-%m-%d')
# cv = KFold(n_splits=5, shuffle=True) #, random_state=42)
# cv = StratifiedShuffleSplit(n_splits=10, test_size=0.1, random_state=42)
cv = StratifiedKFold(n_splits=10, shuffle=True, random_state=42)
gammaCostCv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
FEATURES_SELECTION_CV = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
g_scaler = StandardScaler()
# g_scaler = MinMaxScaler()

conn = cm.getdbcon()
cur = conn.cursor()

def init():
    global conn
    global cur
    conn = cm.getdbcon()
    cur = conn.cursor()

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
    grid = GridSearchCV(clf, param_grid=param_grid, cv=gammaCostCv, n_jobs=-1)
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
    for symbol in symbolList:
        (colNames, X_allDataSetUnscaled, y_allPredictions, dateList) = loadDataSet( \
                                        symbol, isUseBestFeautures=bestFeautures, limit=GAMMACOSTDATASETLENGTH)    
        X_allDataSet = g_scaler.fit_transform(X_allDataSetUnscaled)
        decision_function_shape='ovr'
        clf = svm.SVC(kernel='rbf', decision_function_shape=decision_function_shape)
    
        grid = gridSearch(clf, X_allDataSet[:GAMMACOSTDATASETLENGTH, :], y_allPredictions[:GAMMACOSTDATASETLENGTH])
#         grid = zoomInGridSearch(clf, X_allDataSet[:DATASETLENGTH, :], y_allPredictions[:DATASETLENGTH])
        bestParams = grid.best_params_
        query = (
            '''
            INSERT INTO v2.instrumentsprops(symbol) 
                select '{2}' where not exists 
                        (select 1 from v2.instrumentsprops i2 where i2.symbol = '{2}');
            UPDATE v2.instrumentsprops SET bestcost={0}, bestgamma={1} WHERE symbol = '{2}';
            '''
                 .format(bestParams['C'], bestParams['gamma'], symbol))
        cur.execute(query)
        
        print '{0} found Cost={1} gamma={2} bestScore={3}, saved'.\
            format(symbol, bestParams['C'], bestParams['gamma'], grid.best_score_)

    cur.close();

def fitAndSave(symbolCSV, bestFeautures):
    symbolList = symbolCSV.split(",")
    for symbol in symbolList:
        (colNames, X_allDataSetUnscaled, y_allPredictions, dateList) = loadDataSet(symbol, offset=0, isUseBestFeautures=bestFeautures,
                                limit=FITDATASETLENGTH)
        X_reduced = X_allDataSetUnscaled[TESTDATASETLENGTH:,]
        y_reduced = y_allPredictions[TESTDATASETLENGTH:,]

        X_allDataSet = g_scaler.fit_transform(X_reduced)
        decision_function_shape='ovr'
        bestParams = loadBestParams(symbol)
        clfTrained = svm.SVC(kernel='rbf', \
                             C=bestParams[0], gamma=bestParams[1], \
                             decision_function_shape=decision_function_shape).fit(X_allDataSet, y_reduced)
        binDump = pickle.dumps(clfTrained)
        binDumpScaler = pickle.dumps(g_scaler)
        cur.execute("UPDATE v2.instrumentsprops SET classifierdump=%s, scalerdump=%s where symbol=%s", \
                    (psycopg2.Binary(binDump), psycopg2.Binary(binDumpScaler), symbol))
        conn.commit()
#         print '{0}: Fit classification for gamma={1} Cost={2} saved'.format(symbol, bestParams[1], bestParams[0])
        print '{0}: Fit classification and scaler saved'.format(symbol)

    cur.close();

def loadDataSet(symbol, isUseBestFeautures = False, offset=0, limit=DATASETLENGTH, datefrom=FITDATEFROM):
    return ti.loadDataSet(symbol, isUseBestFeautures, offset, limit, datefrom)

def loadDataSet_(symbol, isUseBestFeautures = False, offset=50, limit=DATASETLENGTH):
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

def getCrossValMeanScore(clf, dataSet, predictions, cv=cv):
    scores = cross_val_score(clf, dataSet, predictions, cv=cv)
    return (scores.mean(), scores.std())

def loadBestParams(symbol):
    query = "select bestcost, bestgamma from v2.instrumentsprops WHERE symbol='{0}';".format(symbol)
    cur.execute(query)
    bestParams = cur.fetchone()
    return bestParams

def optimiseFeautures(symbolCSV):
    symbolList = symbolCSV.split(",")
    for symbol in symbolList:
        (colNames, X_allDataSetUnscaled, y_allPredictions, dateList) = loadDataSet(symbol, limit=DATASETLENGTH)
        X_allDataSet    = g_scaler.fit_transform(X_allDataSetUnscaled)
        X_allDataSet    = X_allDataSet[:FEATURESELECTIONDATASETLENGTH,]
        y_predictions   = y_predictions[:FEATURESELECTIONDATASETLENGTH,]
        datesList       = datesList[:FEATURESELECTIONDATASETLENGTH,]

        print "Optimizing features for '{0}'".format(symbol)
        bestParams = loadBestParams(symbol)

        clfLoaded = svm.SVC(kernel='rbf', 
#                 C=bestParams[0],\
#                 gamma=bestParams[1], \
                 decision_function_shape='ovr').fit(X_allDataSet, y_allPredictions)

        excludedIndexes = []
        excludedCols = []
        goodIndexes = []
        goodCols = []
        (bestMeanScore, bestMeanStd) = getCrossValMeanScore(clfLoaded, X_allDataSet, y_allPredictions, cv=FEATURES_SELECTION_CV)
        X_reduced = np.copy(X_allDataSet)
        for curIdx, colName in enumerate(colNames):
            testExcludedIndexes = np.append(excludedIndexes, curIdx)
            testX_reduced = np.delete(X_reduced, testExcludedIndexes, axis=1)
            (meanScore, meanStd) = getCrossValMeanScore(clfLoaded, testX_reduced, y_allPredictions, cv=FEATURES_SELECTION_CV)
            if bestMeanScore/bestMeanStd <= meanScore/meanStd:
                excludedIndexes.append(curIdx)
                excludedCols.append(colName)
                print 'Excluded {}. best MeanScore/MeanStd {:>6.5f}/{:>6.5f} <= meanScore/meanStd {:>6.5f}/{:>6.5f}'\
                    .format(colName, bestMeanScore, bestMeanStd, meanScore, meanStd)
                bestMeanScore = meanScore
                bestMeanStd = meanStd
            else:
                goodCols.append(colName)
                goodIndexes.append(curIdx)
                print 'Left     {}. best MeanScore/MeanStd {:>6.5f}/{:>6.5f} > meanScore/meanStd {:>6.5f}/{:>6.5f}'\
                    .format(colName, bestMeanScore, bestMeanStd, meanScore, meanStd)
        
        goodColsStr = ','.join(goodCols)
        excludedColsStr = ','.join(excludedCols)
        
        query = ("UPDATE v2.instrumentsprops SET bestattributes='{0}', excludedattributes='{1}', bestcorrelation={2}"
                 " WHERE symbol = '{3}';"
                 .format(goodColsStr, excludedColsStr, bestMeanScore, symbol))
        cur.execute(query)
        conn.commit()               # commit separately to ensure this is in as the next operation might fail 
        print '{} optimiseFeautures done. best MeanScore={}, MeanStd={}'.format(symbol, bestMeanScore, bestMeanStd)

def testPerformance(symbolCSV, isUseBestFeautures):
    symbolList = symbolCSV.split(",")

    for symbol in symbolList:
        (clf, l_scaler) = loadClassifier(symbol)
        (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol, isUseBestFeautures=isUseBestFeautures, offset=0, limit=FITDATASETLENGTH)
        X_allDataSetScaled = l_scaler.transform(X_allDataSet)
        X_reduced = X_allDataSetScaled[TESTDATASETLENGTH:,]
        y_reduced = y_allPredictions[TESTDATASETLENGTH:,]
        X_test = X_allDataSetScaled[0:TESTDATASETLENGTH,]
        y_test = y_allPredictions[0:TESTDATASETLENGTH,]

        (meanScore, std) = getCrossValMeanScore(clf, X_reduced, y_reduced)
        print '%6s: meanScore=%.3f std=%.3f  clf score on test=%.3f' % \
            (symbol, meanScore, std, clf.score(X_test, y_test))

def isPredictionCorrect(prediction, priceDiff):
    if priceDiff is None:
        return "None"
    elif prediction == 'undef' or ti.formatLabel(priceDiff) == 'undef':
        return 'someUndef'
    else:
        return str(prediction == ti.formatLabel(priceDiff))

def loadClassifier(symbol):
    cur.execute("SELECT classifierdump, scalerdump FROM v2.instrumentsprops where symbol=%s;", (symbol, ))
    blob = cur.fetchone()
    readClfDump = blob[0]
    readScalerDump = blob[1]
    clfLoaded = pickle.loads(readClfDump)
    scalerLoaded = pickle.loads(readScalerDump)
    return (clfLoaded, scalerLoaded)

def predict(symbolCSV, offset=0, isUseBestFeautures=True):
    symbolList = symbolCSV.split(",")
    print "Using offset={0}".format(offset)
    print '{:^10s} {:^10s} {:^10s} {:^10s} {:^10s} {:^10s} {:^5s} {:^10s} {:^10s}'.format(
        "DF date","Date From","Symbol","Orig Price","Pred Date",
        "Last avail Price","prediction",
        "Price Diff","Is Correct")
    for symbol in symbolList:
        (clf, l_scaler) = loadClassifier(symbol)
        (colNames, X_allDataSetUnscaled, y_predictions, datesList) = \
                        loadDataSet(symbol, limit=FITDATASETLENGTH, isUseBestFeautures=isUseBestFeautures)
        dfCompr = pd.DataFrame(X_allDataSetUnscaled)
        dfCompr.to_csv(symbol + '_X_allDataSetUnscaled.csv', sep=',')

        X_allDataSet    = l_scaler.transform(X_allDataSetUnscaled)
        X_allDataSet    = X_allDataSet[:PREDICTATASETLENGTH,]
        y_predictions   = y_predictions[:PREDICTATASETLENGTH,]
        datesList       = datesList[:PREDICTATASETLENGTH,]

        np.savetxt(symbol + "_dates.csv", datesList, "%s", ",")
        offsetInt = int(offset)
        theDate = datesList[offsetInt]
#         toPredictDataSet = X_allDataSet[offsetInt].reshape(1, -1)
#         print '{0}: {1}'.format(symbol, ','.join(map(str, X_allDataSetUnscaled[offsetInt])))
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
            priceDiffStr = '{:>12.11f}'.format(priceDiff)
        else:
            predictionForDate = 'None'
            lastAvailableDateStockPrice = -1
            priceDiff = None
            priceDiffStr = 'None'

#         prediction = clf.predict(toPredictDataSet)
        prediction = clf.predict(X_allDataSet)
#         f1=open('./1.txt', 'w+')
#         f2=open('./2.txt', 'w+')
        dfCompr = pd.DataFrame(
                {
                'Dates Actual': datesList,
                'Outcome Actual': y_predictions,
                'Outcome Predicted': prediction
                })
        dfCompr['Just right'] = (dfCompr['Outcome Actual'] == dfCompr['Outcome Predicted'])
        dfCompr['OK'] = dfCompr.apply(lambda row: row['Outcome Actual'] == row['Outcome Predicted'] or \
                                        row['Outcome Actual'] == 'undef' or \
                                        row['Outcome Predicted'] == 'undef', axis=1)
        dfCompr['Wrong'] = dfCompr.apply(lambda row: row['Outcome Actual'] != row['Outcome Predicted'] and \
                                        row['Outcome Actual'] != 'undef' and \
                                        row['Outcome Predicted'] != 'undef', axis=1)
        dfCompr.to_csv(symbol + '_comparison.csv', sep=',')

        thePrediction = prediction[offsetInt]
        print '{:^10s} {:^10s} {:^10s} {:>10.2f} {:^10s} {:>10.2f} {:^10s} {:>10s} {:^10s}'\
            .format(str(theDate),
                    str(dbFoundDate), 
                    symbol, 
                    dbFoundStockPrice,
                    str(predictionForDate), 
                    lastAvailableDateStockPrice,
                    thePrediction,
                    priceDiffStr,
                    isPredictionCorrect(thePrediction, priceDiff))
