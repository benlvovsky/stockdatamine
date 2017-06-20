import numpy as np
from sklearn import svm #, feature_selection #, metrics, datasets
import common as cm
import time
from sklearn.model_selection import cross_val_score, train_test_split, GridSearchCV
import pickle
import psycopg2
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing.data import Normalizer
from sklearn.model_selection._split import KFold, StratifiedShuffleSplit

conn = None
DATASETLENGTH = 1000
TESTSIZE = 0.1
MOVEPRCNT = 0.02
cv = KFold(n_splits=10, shuffle=True) #, random_state=42)
# cv = StratifiedShuffleSplit(n_splits=10, test_size=0.1, random_state=42)

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
        (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol, bestFeautures)    
        decision_function_shape='ovr'
        clf = svm.SVC(kernel='rbf', decision_function_shape=decision_function_shape)
    
        grid = gridSearch(clf, X_allDataSet[:DATASETLENGTH, :], y_allPredictions[:DATASETLENGTH])
#         grid = zoomInGridSearch(clf, X_allDataSet[:DATASETLENGTH, :], y_allPredictions[:DATASETLENGTH])
        bestParams = grid.best_params_
        query = ("UPDATE v2.instrumentsprops SET bestcost={0}, bestgamma={1} WHERE symbol = '{2}';"
                 .format(bestParams['C'], bestParams['gamma'], symbol))
    
        cur.execute(query)
        conn.commit()               # commit separately to ensure this is in as the next operation might fail 
        print '{0} found gamma={1} Cost={2} bestScore={3}, saved'.format(symbol, bestParams['gamma'], bestParams['C'], grid.best_score_)

    cur.close();

def fitAndSave(symbolCSV, bestFeautures = False):
    symbolList = symbolCSV.split(",")
    cur = conn.cursor()
    for symbol in symbolList:
        (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol, bestFeautures)    
        decision_function_shape='ovr'
        query = ("select bestcost, bestgamma from v2.instrumentsprops WHERE symbol='{0}';".format(symbol))
        cur.execute(query)
        bestParams = cur.fetchone();
        print 'bestParams={0}'.format(bestParams)

        clfTrained = svm.SVC(kernel='rbf', gamma=bestParams[1], C=bestParams[0], \
                             decision_function_shape=decision_function_shape).fit(X_allDataSet, y_allPredictions)
        binDump = pickle.dumps(clfTrained)
        cur.execute("UPDATE v2.instrumentsprops SET classifierdump=%s where symbol=%s", (psycopg2.Binary(binDump), symbol))
        conn.commit()
        print '{0}: Fit classification for gamma={1} Cost={2} saved'.format(symbol, bestParams[1], bestParams[0])

    cur.close();

def loadDataSet(symbol, isUseBestFeautures = False, offset=50, limit=DATASETLENGTH):
    cur = conn.cursor()
    if isUseBestFeautures:
        print 'Using best features'
        cur.execute("select bestattributes from v2.instrumentsprops where symbol = '{0}'".format(symbol))
        bestFeatures = cur.fetchone()
        query = ("select date,instrument,{0},prediction from v2.datamining_aggr_view "\
                 "where instrument = \'{1}\' order by date desc offset 50 limit {2}")\
            .format(bestFeatures[0], symbol, DATASETLENGTH)
    else:
        print 'Using all available features'
        query = ("select * from v2.datamining_aggr_view where instrument = \'{0}\' order by date desc offset {1} limit {2}")\
            .format(symbol, offset, DATASETLENGTH)

    start = time.time()
    print 'Start SQL query...'
    cur.execute(query)
    print '                  ...done in {0} seconds'.format(time.time() - start)

    records = cur.fetchall()
    
    numpyRecords = np.array(records)
    X_allDataSet = numpyRecords[:, 2:-1].astype(np.float32)
    colNames = np.array(cur.description)[2:-1, 0]
    yRaw = numpyRecords[:, -1:]
    
    yArr = []
    
    for line in yRaw:
        if line[0] > 1 + MOVEPRCNT:
            yArr.append(1)
        elif line[0] < 1 - MOVEPRCNT:
            yArr.append(2)
        else:
            yArr.append(0)
    
    y_allPredictions = np.array(yArr)
    dateList = numpyRecords[:, 0]
    return (colNames, X_allDataSet, y_allPredictions, dateList)

def getCrossValMeanScore(clf, dataSet, predictions):
#     cv = StratifiedKFold(n_splits=5, test_size=TESTSIZE, random_state=0)
    scores = cross_val_score(clf, dataSet, predictions, cv=cv)
    return (scores.mean(), scores.std())

def optimiseFeautures(symbolCSV):
    symbolList = symbolCSV.split(",")
    cur = conn.cursor()
    for symbol in symbolList:
        (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol)
        print "Optimizing features for '{0}'".format(symbol)
        decision_function_shape='ovr'
        query = ("select bestcost, bestgamma from v2.instrumentsprops WHERE symbol='{0}';".format(symbol))
        cur.execute(query)
        bestParams = cur.fetchone();
        print 'bestParams={0}'.format(bestParams)

        clfLoaded = svm.SVC(kernel='rbf', C=bestParams[0], gamma=bestParams[1], \
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
            if bestMeanScore/bestMeanStd < meanScore/meanStd:
                excludedIndexes.append(curIdx)
                excludedCols.append(colName)
                bestMeanScore = meanScore
                bestMeanStd = meanStd
                print 'Excluded column {0}. bestMeanScore/bestMeanStd {1}/{2} < meanScore/meanStd {3}/{4}'\
                    .format(colName, bestMeanScore, bestMeanStd, meanScore, meanStd)
            else:
                goodCols.append(colName)
                goodIndexes.append(curIdx)
                print 'Column {0} is good. bestMeanScore/bestMeanStd {1}/{2} >= meanScore/meanStd {3}/{4}'\
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
#     cur = conn.cursor()

    for symbol in symbolList:
        (colNames, X_allDataSet, y_allPredictions, dateList) = loadDataSet(symbol, True)
        (colNames, X_allDataSetTest, y_allPredictionsTest, dateList) = loadDataSet(symbol, True, offset=2, limit=30)
        clfLoaded = loadClassifier(symbol)
        (meanScore, std) = getCrossValMeanScore(clfLoaded, X_allDataSet, y_allPredictions)
        print '{0} meanScore={1}, std={2}, clf score on test={3}'.\
            format(symbol, meanScore, std, clfLoaded.score(X_allDataSetTest, y_allPredictionsTest))

# def loadOneRecord(symbol, offset=0):
#     return loadDataSet(symbol, True, offset=offset, limit=1)
#     cur = conn.cursor()
#     cur.execute("select bestattributes from v2.instrumentsprops where symbol = '{0}'".format(symbol))
#     bestFeatures = cur.fetchone()
#     query = ("select date,instrument,{0},prediction from v2.datamining_aggr_view where instrument = \'{1}\'"
#              " order by date desc offset {2} limit 1").format(bestFeatures[0], symbol, offset)
#     cur.execute(query)
#     records = cur.fetchall()
#     numpyRecords = np.array(records)
#     X_allDataSet = numpyRecords[:, 2:-1].astype(np.float32)
#     return (X_allDataSet, numpyRecords[:, 0])

def isPredictionCorrect(prediction, priceDiff):
    return  (priceDiff > 1 + MOVEPRCNT) and (prediction == 1) or \
            (priceDiff < 1 - MOVEPRCNT) and (prediction == 2) or \
            (1 - MOVEPRCNT <= priceDiff <= 1 + MOVEPRCNT) and (prediction == 0)

def loadClassifier(symbol):
    cur = conn.cursor()
    cur.execute("SELECT (classifierdump) FROM v2.instrumentsprops where symbol=%s;", (symbol, ))
    readClfDump = cur.fetchone()[0]
    clfLoaded = pickle.loads(readClfDump)
    return clfLoaded

def predict(symbolCSV, offset=0):
    symbolList = symbolCSV.split(",")
    cur = conn.cursor()
    print "{0},{1},{2},{3},{4},{5},{6}"\
        .format('Date From', 'symbol', 'orig stock Price', 'prediction For Date', 'last Available Date Stock Price', 'prediction', \
                'price Diff', 'is correct')
    for symbol in symbolList:
#         (X_allDataSet, datesList) = loadOneRecord(symbol, offset)
        (colNames, X_allDataSet, y_predictions, datesList) = loadDataSet(symbol, True, offset=offset, limit=1)
        clfLoaded = loadClassifier(symbol)

        cur.execute("select \"Adj Close\" from stocks where stock=%s and date = %s", (symbol, datesList[0]))
        stockPrice = cur.fetchone()[0];
        
        # we get a first one record 1 month later from the point of prediction date
        cur.execute("select date, \"Adj Close\" from stocks where stock=%s and date >= %s + '1 month'::interval order by date asc limit 1"\
                    , (symbol, datesList[0]))
        stockDateAndPriceInAMonthList = cur.fetchall()
#         print "stockDateAndPriceInAMonthList = {0}".format(stockDateAndPriceInAMonthList)
        if len(stockDateAndPriceInAMonthList) > 0:
            lastAvailableDateStockPrice = stockDateAndPriceInAMonthList[0][1]
            predictionForDate = stockDateAndPriceInAMonthList[0][0]
            priceDiff = lastAvailableDateStockPrice/stockPrice
        else:
            lastAvailableDateStockPrice = 'price to diff not present'
            priceDiff = 'cannot diff'
            predictionForDate = 'not defined'

        prediction = clfLoaded.predict(X_allDataSet)
        print "{0},{1},{2},{3},{4},{5},{6}, {7}"\
            .format(datesList[0], symbol, stockPrice, predictionForDate, lastAvailableDateStockPrice, \
                    prediction[0], priceDiff, isPredictionCorrect(prediction[0], priceDiff))

#########################
