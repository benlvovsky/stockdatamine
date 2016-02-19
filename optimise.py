#!/usr/bin/env python

import sys
import psycopg2
import common
import subprocess
from common import *

def genOptimiseAll(optimiseFunc, startPar, stopPar, stepPar, dbCol, paramOption):
	query="select stockname, excludedattributes, bestcost, bestnu from {0} where " +
		"active=true and excludedattributes is not NULL and excludedattributes<>'' " +
		"and {1} is NULL order by stockname asc".\
		format(dataminestocksViewName, dbCol)
	conn = getdbcon()
	cur = conn.cursor()
	curUp = conn.cursor()
	cur.execute(query)
	for row in cur:
		stockname=row[0]
		excludedattributes=row[1]
		bestCost=row[2]
		bestNu=row[3]
		extractdata = extractData(stockname)
		(nu, corr)=genOptimiseOne(paramOption, stockname, excludedattributes, extractdata, startPar, stopPar, stepPar)
		print "1---------------------------------------------"
		(nu, corr)=genOptimiseOne(paramOption, stockname, excludedattributes, extractdata, nu-0.1, 1, 0.01)
		print "2---------------------------------------------"
		(nu, corr)=genOptimiseOne(paramOption, stockname, excludedattributes, extractdata, nu-0.01, 1, 0.001)
		print "3---------------------------------------------"
		(nu, corr)=genOptimiseOne(paramOption, stockname, excludedattributes, extractdata, nu-0.001, 1, 0.0001)
		curUp.execute("update {0} set {4}={1}, bestCorrelation={2} where stockname='{3}'".format(dataminestocksViewName, nu-startNu, corr, stockname, dbCol))

	conn.commit()
	conn.close()
	print "optimisation finished"

def genOptimiseOne(paramOption, stockname, excludedattributes, extractdata, start, stop, step):
	print "Stock " + stockname

	tryParam=start
	bestParam=tryParam
	(trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata,, "{0} {1}".format(paramOption, tryParam))
	print "Starting correlation={0}, with param={1}".format(trialCorrelation, bestParam)
	bestCorrelation=trialCorrelation

	tryParam = start + step
	while tryParam < stop:
		print "Trial {0}={1}".format(paramOption, tryParam)
		(trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, tryParam)
		print "Result: correlation={0} for trial Nu={1} with current bestCorrelation={2}".format(trialCorrelation, tryParam, bestCorrelation)
		if trialCorrelation >= bestCorrelation:
			bestCorrelation = trialCorrelation
			bestParam = tryParam
			print "Found better or same correlation="+str(bestCorrelation) + " with Nu={0}".format(bestParam)
		else:
			print "Not better. Best nu={0} with correlation={1}".format(bestParam, bestCorrelation)
			break
		tryParam=tryParam+step

	return (bestParam, bestCorrelation)
