import numpy as np
#import matplotlib.pyplot as plt
from sklearn import svm, feature_selection #, metrics, datasets
import common as cm
import os
import time
from sklearn.model_selection import cross_val_score, train_test_split, ShuffleSplit, StratifiedShuffleSplit, GridSearchCV
import pickle
import psycopg2
import StringIO
import sys

def gridSearch(clf, X, y):
    start = time.time()
    print 'Start gridSearch...'
    C_range = np.logspace(-2, 10, 13)
    gamma_range = np.logspace(-9, 3, 13)
    param_grid = dict(gamma=gamma_range, C=C_range)
    cv = StratifiedShuffleSplit(n_splits=5, test_size=0.2, random_state=42)
    grid = GridSearchCV(clf, param_grid=param_grid, cv=cv)
    grid.fit(X, y)
    
    print '                  ...done in {0} seconds'.format(time.time() - start)
    print("The best parameters are %s with a score of %0.2f"
          % (grid.best_params_, grid.best_score_))
    
    print 'grid.best_params_ keys=value:'
    for key in grid.best_params_:
        print '      {0}={1}'.format(key, grid.best_params_[key])

    return grid.best_params_

def v2analysis(symbol = '^AORD'):
    (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol)
    
    X_train, X_test, y_train, y_test = train_test_split(X_allDataSet, y_allPredictions, test_size=0.3, random_state=0)
    
    bestParams = gridSearch(svm.SVC(kernel='rbf'), X_allDataSet[:1000, :], y_allPredictions[:1000])
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
    #     print 'train score={0}'.format(clf.score(X_train, y_train))
        cv = ShuffleSplit(n_splits=5, test_size=0.3, random_state=0)
        scores = cross_val_score(clf, X_allDataSet, y_allPredictions, cv=cv)
        print 'cross val scores={0}'.format(scores)
        print("Accuracy as a mean score and the 95 %% confidence interval of the score estimate : %0.2f (+/- %0.2f)" % (scores.mean(), scores.std() * 2))
        print '-------------------'
    
    print '                               ...done in {0} seconds'.format(time.time() - start)
    
def gammaCostCalc(symbol):
    (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol)
    
    X_train, X_test, y_train, y_test = train_test_split(X_allDataSet, y_allPredictions, test_size=0.3, random_state=0)
    decision_function_shape='ovr'
    clf = svm.SVC(kernel='rbf', decision_function_shape=decision_function_shape)
    # calculate best parameters to calculate on some of the data set

    bestParams = gridSearch(clf, X_allDataSet[:1000, :], y_allPredictions[:1000])
#     bestParams = gridSearch(clf, X_allDataSet, y_allPredictions)
    query = ("UPDATE v2.instrumentsprops SET bestcost={0}, bestgamma={1} WHERE symbol = '{2}';"
             .format(bestParams['C'], bestParams['gamma'], symbol))
    conn = cm.getdbcon()
    cur = conn.cursor()

    cur.execute(query)
    conn.commit()               # commit separately to ensure this is in as the next operation might fail 

    clfTrained = svm.SVC(kernel='rbf', gamma=bestParams['gamma'], C=bestParams['C'], \
                         decision_function_shape=decision_function_shape).fit(X_train, y_train)
    binDump = pickle.dumps(clfTrained)
    #    use clf = pickle.load(xxx)
    cur.execute("UPDATE v2.instrumentsprops SET classifierdump=%s where symbol=%s", (psycopg2.Binary(binDump), symbol))
    conn.commit()
    print '    stored in DB'
    cur.close();

def loadDataSet(symbol):
    query = ("select * from v2.datamining_aggr_view where instrument = \'{0}\'"
             " and date < (now() - '7 weeks'::interval) order by date desc limit 2500").format(symbol)
    conn = cm.getdbcon()
    cur = conn.cursor()

    start = time.time()
    print 'Start SQL query...'
    cur.execute(query)
    print '                  ...done in {0} seconds'.format(time.time() - start)

    start = time.time()
    records = cur.fetchall()
    
    numpyRecords = np.array(records)
    X_allDataSet = numpyRecords[:, 2:-1]

#     print 'X_allDataSet: {0}'.format(X_allDataSet)

    colNames = np.array(cur.description)[2:-1, 0]
#     print 'column names: {0}'.format(colNames)
    
    yRaw = numpyRecords[:, len(numpyRecords[0]) - 1:]
    
    yArr = []
    
    for line in yRaw:
        if line[0] > 1.02:
            yArr.append(1)
        elif line[0] < 1.02:
            yArr.append(2)
        else:
            yArr.append(0)
    
    y_allPredictions = np.array(yArr)
    
    return (colNames, X_allDataSet, y_allPredictions)

def getCrossValMeanScore(clf, dataSet, predictions):
    cv = ShuffleSplit(n_splits=5, test_size=0.3, random_state=0)
    scores = cross_val_score(clf, dataSet, predictions, cv=cv)
    return scores.mean()
    #, scores.std() * 2))

def optimiseFeautures(symbol):
    (colNames, X_allDataSet, y_allPredictions) = loadDataSet(symbol)
    print "arr lengths: colNames={0}, X_allDataSet={1}".format(len(colNames), len(X_allDataSet[0]))
    conn = cm.getdbcon()
    cur = conn.cursor()
    cur.execute("SELECT (classifierdump) FROM v2.instrumentsprops where symbol=%s;", (symbol,))
    readClfDump = cur.fetchone()[0];
    clfLoaded = pickle.loads(readClfDump)

    excludedIndexes = []
    excludedCols = []
    goodIndexes = []
    goodCols = []
    bestMeanScore = getCrossValMeanScore(clfLoaded, X_allDataSet, y_allPredictions)
    X_reduced = np.copy(X_allDataSet)
    for curIdx, colName in enumerate(colNames):
        testExcludedIndexes = np.append(excludedIndexes, curIdx)
        testX_reduced = np.delete(X_reduced, testExcludedIndexes, axis=1)
        meanScore = getCrossValMeanScore(clfLoaded, testX_reduced, y_allPredictions)
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
    cur.close();
    print 'optimiseFeautures done. bestMeanScore={0}'.format(bestMeanScore)
