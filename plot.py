import numpy as np
import matplotlib.pyplot as plt
from sklearn import svm, metrics #, datasets
import common as cm
import os
import time
from sklearn.model_selection import cross_val_score, train_test_split, ShuffleSplit, StratifiedShuffleSplit, GridSearchCV
# import some data to play with
# iris = datasets.load_iris()
# print type(iris.target)
# print iris.target

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

      # Now we need to fit a classifier for all parameters in the 2d version
    # (we use a smaller set of parameters here because it takes a while to train)
#     C_2d_range = [1e-2, 1, 1e2]
#     gamma_2d_range = [1e-1, 1, 1e1]
#     classifiers = []
#     for C in C_2d_range:
#         for gamma in gamma_2d_range:
#             clf = svm.SVC(C=C, gamma=gamma)
#             clf.fit(X_2d, y_2d)
#             classifiers.append((C, gamma, clf))
    return grid.best_params_

def v2analysis():
    if os.environ.get('PGHOST') is None:
        os.environ['PGHOST'] = '127.0.0.1' # visible in this process + all children
        print 'PGHOST was None => set PGHOST to {0}'.format(os.environ['PGHOST'])

    query = "select * from v2.datamining_aggr_view where instrument = '^AORD' and date < (now() - '6 weeks'::interval) order by date desc limit 2500"
    conn = cm.getdbcon()
    cur = conn.cursor()
    
    start = time.time()
    print 'Start SQL query...'
    cur.execute(query)
    print '                  ...done in {0} seconds'.format(time.time() - start)
    
    start = time.time()
    # retrieve the records from the database
    records = cur.fetchall()
    
    # print out the records using pretty print
    # note that the NAMES of the columns are not shown, instead just indexes.
    # for most people this isn't very useful so we'll show you how to return
    # columns as a dictionary (hash) in the next example.
    # print(records)
    numpyRecords = np.array(records)
    # X_allDataSet = iris.data[:, :2]  # we only take the first two features. We could
    #                       # avoid this ugly slicing by using a two-dim dataset
    # y_allPredictions = iris.target
    X_allDataSet = numpyRecords[:, 2:]
    X_allDataSet = X_allDataSet[:, 0:-1:]
    
    yRaw = numpyRecords[:, len(numpyRecords[0]) - 1:]
    
    # y_allPredictions = np.empty([0, 1], float)
    yArr = []
    
    for line in yRaw:
        if line[0] > 1.02:
            yArr.append(1)
        elif line[0] < 1.02:
            yArr.append(2)
        else:
            yArr.append(0)
    
    start = time.time()
    y_allPredictions = np.array(yArr)
    X_train, X_test, y_train, y_test = train_test_split(X_allDataSet, y_allPredictions, test_size=0.3, random_state=0)
    
    #print 'X_allDataSet=\n{0}'.format(X_allDataSet)
    #print '{0}'.format(type(y_allPredictions))
    #print 'y_allPredictions=\n{0}]'.format(y_allPredictions)
    #print '{0}'.format(type(y_allPredictions))
    #print np.isnan(X_allDataSet.any())
    
#     h = .02  # step size in the mesh
    # we create an instance of SVM and fit out data. We do not scale our
    # data since we want to plot the support vectors
    
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
    
    # create a mesh to plot in
    # x_min, x_max = X_allDataSet[:, 0].min() - 1, X_allDataSet[:, 0].max() + 1
    # y_min, y_max = X_allDataSet[:, 1].min() - 1, X_allDataSet[:, 1].max() + 1
    # xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
    #                      np.arange(y_min, y_max, h))
    
    # title for the plots
    titles = ['SVC with linear kernel',
              'LinearSVC (linear kernel)',
              'SVC with RBF kernel',
              'SVC with RBF kernel and best params C={0}, gamma={1}'.format(bestParams['C'], bestParams['gamma']),
              'SVC with polynomial (degree 3) kernel']
    
    start = time.time()
    print 'Start looping classifiers...'
    for i, clf in enumerate((svc, lin_svc, rbf_svc, rbf_svc_betParams, poly_svc)):
        # Plot the decision boundary. For that, we will assign a color to each
        # point in the mesh [x_min, x_max]x[y_min, y_max].
    #     Z = clf.predict(X_allDataSet) 
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
    
    # svcLinearPredict = svc.predict(X_allDataSet)
    # svcRbfPredict = rbf_svc.predict(X_allDataSet)
    # print 'SVC with linear kernel equals to rbf kernel = {0}'.format(np.array_equal(svcLinearPredict, svcRbfPredict))
    # print 'The difference between linear and rbf kernel predictions: \n{0}'.format(svcLinearPredict - svcRbfPredict)
