import numpy as np
import matplotlib.pyplot as plt
from sklearn import svm, metrics #, datasets
import common as cm
import os

# import some data to play with
# iris = datasets.load_iris()
# print type(iris.target)
# print iris.target

os.environ['PGHOST'] = '127.0.0.1' # visible in this process + all children

query = "select * from v2.datamining_aggr_view where instrument = '^AORD' order by date desc limit 10000;"
conn = cm.getdbcon()
cur = conn.cursor()
cur.execute(query)

# retrieve the records from the database
records = cur.fetchall()

# print out the records using pretty print
# note that the NAMES of the columns are not shown, instead just indexes.
# for most people this isn't very useful so we'll show you how to return
# columns as a dictionary (hash) in the next example.
# print(records)
numpyRecords = np.array(records)
# X = iris.data[:, :2]  # we only take the first two features. We could
#                       # avoid this ugly slicing by using a two-dim dataset
# y = iris.target
X = numpyRecords[30:, 2:]
predict = numpyRecords[:, 2:]
# print X
# print '----------------------------------'
X = X[:, 0:-1:]
#print X
#exit()

yRaw = numpyRecords[:, len(numpyRecords[0]) - 1:]

# y = np.empty([0, 1], float)
yArr = []

for line in yRaw:
    if line[0] > 1.02:
#         np.append(y, np.array([[0.0]]), axis=0)
        yArr.append(1)
    else:
        yArr.append(2)

y = np.array(yArr)

#print 'X=\n{0}'.format(X)
#print '{0}'.format(type(y))
#print 'y=\n{0}]'.format(y)
#print '{0}'.format(type(y))
#print np.isnan(X.any())

h = .02  # step size in the mesh

# we create an instance of SVM and fit out data. We do not scale our
# data since we want to plot the support vectors
C = 1.0  # SVM regularization parameter
svc = svm.SVC(kernel='linear', C=C).fit(X, y)
rbf_svc = svm.SVC(kernel='rbf', gamma=0.7, C=C).fit(X, y)
poly_svc = svm.SVC(kernel='poly', degree=3, C=C).fit(X, y)
# lin_svc = svm.LinearSVC(C=C).fit(X, y)

# create a mesh to plot in
x_min, x_max = X[:, 0].min() - 1, X[:, 0].max() + 1
y_min, y_max = X[:, 1].min() - 1, X[:, 1].max() + 1
xx, yy = np.meshgrid(np.arange(x_min, x_max, h),
                     np.arange(y_min, y_max, h))

# title for the plots
titles = ['SVC with linear kernel',
#           'LinearSVC (linear kernel)',
          'SVC with RBF kernel',
          'SVC with polynomial (degree 3) kernel']

for i, clf in enumerate((svc, rbf_svc, poly_svc)):
    # Plot the decision boundary. For that, we will assign a color to each
    # point in the mesh [x_min, x_max]x[y_min, y_max].
    Z = clf.predict(X) 
    print '{0}\n{1}\n\n'.format(clf.kernel, Z)

svcLinearPredict = svc.predict(X)
svcRbfPredict = rbf_svc.predict(X)
print 'SVC with linear kernel equals to rbf kernel = {0}'.format(np.array_equal(svcLinearPredict, svcRbfPredict))
print 'The difference between linear and rbf kernel predictions: {0}'.format(svcLinearPredict - svcRbfPredict)
