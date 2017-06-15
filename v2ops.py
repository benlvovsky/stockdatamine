import numpy as np
from sklearn import svm #, feature_selection #, metrics, datasets
import common as cm
import time
from sklearn.model_selection import cross_val_score, train_test_split, ShuffleSplit, StratifiedShuffleSplit, GridSearchCV
import pickle
import psycopg2
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing.data import Normalizer

def gridSearch(clf, X, y):
    C_range = np.logspace(-2, 10, 13)
    gamma_range = np.logspace(-9, 3, 13)
    param_grid = dict(gamma=gamma_range, C=C_range)
    cv = StratifiedShuffleSplit(n_splits=5, test_size=0.2, random_state=42)
    grid = GridSearchCV(clf, param_grid=param_grid, cv=cv, n_jobs=-1)
    grid.fit(X, y)
    return grid

def v2analysis(symbol = '^AORD'):
    (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol)
    
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
        cv = ShuffleSplit(n_splits=5, test_size=0.3, random_state=0)
        scores = cross_val_score(clf, X_allDataSet, y_allPredictions, cv=cv)
        print 'cross val scores={0}'.format(scores)
        print("Accuracy as a mean score and the 95 %% confidence interval of the score estimate : %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))
        print '-------------------'
    
    print '                               ...done in {0} seconds'.format(time.time() - start)
    
def gammaCostCalc(symbolCSV, bestFeautures = False):
    symbolList = symbolCSV.split(",")
    DATALENGTH = 1000
    conn = cm.getdbcon()
    cur = conn.cursor()
    for symbol in symbolList:
        (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol, bestFeautures)    
        decision_function_shape='ovr'
        clf = svm.SVC(kernel='rbf', decision_function_shape=decision_function_shape)
    
        grid = gridSearch(clf, X_allDataSet[:DATALENGTH, :], y_allPredictions[:DATALENGTH])
        bestParams = grid.best_params_
        query = ("UPDATE v2.instrumentsprops SET bestcost={0}, bestgamma={1} WHERE symbol = '{2}';"
                 .format(bestParams['C'], bestParams['gamma'], symbol))
    
        cur.execute(query)
        conn.commit()               # commit separately to ensure this is in as the next operation might fail 
        print '{0} found gamma={1} Cost={2} bestScore={3}, saved'.format(symbol, bestParams['gamma'], bestParams['C'], grid.best_score_)

    cur.close();

def fitAndSave(symbolCSV, bestFeautures = False):
    symbolList = symbolCSV.split(",")
    conn = cm.getdbcon()
    cur = conn.cursor()
    for symbol in symbolList:
        (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol, bestFeautures)    
        decision_function_shape='ovr'
        query = ("select bestcost, bestgamma from v2.instrumentsprops WHERE symbol='{0}';".format(symbol))
        cur.execute(query)
        bestParams = cur.fetchone();
        print 'bestParams={0}'.format(bestParams)

        clf = svm.SVC(kernel='rbf', decision_function_shape=decision_function_shape)
        clfTrained = svm.SVC(kernel='rbf', gamma=bestParams[1], C=bestParams[0], \
                             decision_function_shape=decision_function_shape).fit(X_allDataSet, y_allPredictions)
        binDump = pickle.dumps(clfTrained)
        cur.execute("UPDATE v2.instrumentsprops SET classifierdump=%s where symbol=%s", (psycopg2.Binary(binDump), symbol))
        conn.commit()
        print '{0}: Fit classification for gamma={1} Cost={2} saved'.format(symbol, bestParams[1], bestParams[0])

    cur.close();

def loadDataSet(symbol, isUseBestFeautures = False):
    conn = cm.getdbcon()
    cur = conn.cursor()
    if isUseBestFeautures:
        print 'Using best features'
        cur.execute("select bestattributes from v2.instrumentsprops where symbol = '{0}'".format(symbol))
        bestFeatures = cur.fetchone()
        query = ("select date,instrument,{0},prediction from v2.datamining_aggr_view where instrument = \'{1}\' order by date desc offset 50 limit 2500")\
            .format(bestFeatures[0], symbol)
    else:
        print 'Using all available features'
        query = ("select * from v2.datamining_aggr_view where instrument = \'{0}\' order by date desc offset 50 limit 2500")\
            .format(symbol)

    start = time.time()
    print 'Start SQL query...'
    cur.execute(query)
    print '                  ...done in {0} seconds'.format(time.time() - start)

    start = time.time()
    records = cur.fetchall()
    
    numpyRecords = np.array(records)
    X_allDataSet = numpyRecords[:, 2:-1].astype(np.float64)
#     X_allDataSet = Normalizer().fit_transform(numpyRecords[:, 2:-1].astype(np.float64))
    colNames = np.array(cur.description)[2:-1, 0]
    yRaw = numpyRecords[:, len(numpyRecords[0]) - 1:]
    
    yArr = []
    
    for line in yRaw:
        if line[0] > 1.02:
            yArr.append(1)
        elif line[0] < 0.98:
            yArr.append(2)
        else:
            yArr.append(0)
    
    y_allPredictions = np.array(yArr)
    
    return (colNames, X_allDataSet, y_allPredictions)

def getCrossValMeanScore(clf, dataSet, predictions):
    cv = ShuffleSplit(n_splits=5, test_size=0.1, random_state=0)
    scores = cross_val_score(clf, dataSet, predictions, cv=cv)
    return (scores.mean(), scores.std())

def optimiseFeautures(symbolCSV):
    symbolList = symbolCSV.split(",")
    conn = cm.getdbcon()
    cur = conn.cursor()
    for symbol in symbolList:
        (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol)
#         print "{0}: colNames length={1}".format(symbol, len(colNames))
        cur.execute("SELECT (classifierdump) FROM v2.instrumentsprops where symbol=%s;", (symbol,))
        readClfDump = cur.fetchone()[0];
        clfLoaded = pickle.loads(readClfDump)
    
        excludedIndexes = []
        excludedCols = []
        goodIndexes = []
        goodCols = []
        (bestMeanScore, std) = getCrossValMeanScore(clfLoaded, X_allDataSet, y_allPredictions)
        X_reduced = np.copy(X_allDataSet)
        for curIdx, colName in enumerate(colNames):
            testExcludedIndexes = np.append(excludedIndexes, curIdx)
            testX_reduced = np.delete(X_reduced, testExcludedIndexes, axis=1)
            (meanScore, std) = getCrossValMeanScore(clfLoaded, testX_reduced, y_allPredictions)
            if bestMeanScore < meanScore:
                excludedIndexes.append(curIdx)
                excludedCols.append(colName)
                bestMeanScore = meanScore
                print 'Excluded column {0}. bestMeanscore {1} < meanScore {2}'.format(colName, bestMeanScore, meanScore)
            else:
                goodCols.append(colName)
                goodIndexes.append(curIdx)
                print 'Column {0} is good. bestMeanScore {1} >= meanScore {2}'.format(colName, bestMeanScore, meanScore)
        
        goodColsStr = ','.join(goodCols)
        excludedColsStr = ','.join(excludedCols)
        
        #to read back is like my_list = my_string.split(",")
    
        query = ("UPDATE v2.instrumentsprops SET bestattributes='{0}', excludedattributes='{1}', bestcorrelation={2}"
                 " WHERE symbol = '{3}';"
                 .format(goodColsStr, excludedColsStr, bestMeanScore, symbol))
        cur.execute(query)
        conn.commit()               # commit separately to ensure this is in as the next operation might fail 
        print 'optimiseFeautures done. bestMeanScore={0}'.format(bestMeanScore)

def testPerformance(symbolCSV):
    symbolList = symbolCSV.split(",")
    conn = cm.getdbcon()
    cur = conn.cursor()

    for symbol in symbolList:
        (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol, True)
        cur.execute("SELECT (classifierdump) FROM v2.instrumentsprops where symbol=%s;", (symbol,))
        readClfDump = cur.fetchone()[0];
        clfLoaded = pickle.loads(readClfDump)
        (meanScore, std) = getCrossValMeanScore(clfLoaded, X_allDataSet, y_allPredictions)
        print '{0} meanScore={1}, std={2}'.format(symbol, meanScore, std)

def loadOneRecord(symbol, offset=0):
    conn = cm.getdbcon()
    cur = conn.cursor()
    cur.execute("select bestattributes from v2.instrumentsprops where symbol = '{0}'".format(symbol))
    bestFeatures = cur.fetchone()
    query = ("select date,instrument,{0},prediction from v2.datamining_aggr_view where instrument = \'{1}\'"
             " order by date desc offset {2} limit 1").format(bestFeatures[0], symbol, offset)
    cur.execute(query)
    records = cur.fetchall()
    numpyRecords = np.array(records, np.float64)
    X_allDataSet = numpyRecords[:, 2:-1].astype(np.float32)
    return (X_allDataSet, numpyRecords[:, 0])

def predict(symbolCSV, offset=0):
    symbolList = symbolCSV.split(",")
    conn = cm.getdbcon()
    cur = conn.cursor()
    for symbol in symbolList:
        (X_allDataSet, datesList) = loadOneRecord(symbol, offset)
        cur.execute("SELECT (classifierdump) FROM v2.instrumentsprops where symbol=%s;", (symbol,))
        readClfDump = cur.fetchone()[0];

        cur.execute("select \"Adj Close\" from stocks where stock=%s and date = %s", (symbol, datesList[0]))
        stockPrice = cur.fetchone()[0];
        cur.execute("select date, \"Adj Close\" from stocks where stock=%s and date > %s order by date desc", (symbol, datesList[0]))
        stockDateAndPriceInAMonthList = cur.fetchall();
#         print "stockDateAndPriceInAMonthList = {0}".format(stockDateAndPriceInAMonthList)
        lastAvailableDateStockPrice = stockDateAndPriceInAMonthList[0][1]
#         print "lastAvailableDateStockPrice = {0}".format(lastAvailableDateStockPrice)
        
#         print "[Adj close] for stock {0} for date date {1} = {2}".format(symbol, datesList[0], stockPrice)
        
        clfLoaded = pickle.loads(readClfDump)
        prediction = clfLoaded.predict(X_allDataSet)
        print "{0},{1},{2},{3},{4},{5}".format(datesList[0], symbol, prediction[0], stockPrice, lastAvailableDateStockPrice, lastAvailableDateStockPrice/stockPrice)
