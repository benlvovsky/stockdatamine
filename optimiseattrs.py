#!/usr/bin/env python

import sys
import psycopg2
import common
import subprocess
from common import *

#OLDIFS=$IFS
#IFS=,
cv=10
limit=480
offset=20
dataminestocksViewName="dataminestocks_py"
startNu=0.00000001
initialStepNu=0.1

def optimiseNuAll():
	print "optimiseNu"
	query="select stockname, excludedattributes from "+ dataminestocksViewName + " where active=true and excludedattributes is not NULL and excludedattributes<>'' and bestnu is NULL order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	curUp = conn.cursor()
	cur.execute(query)
	for row in cur:
		stockname=row[0]
		excludedattributes=row[1]
		extractdata = extractData(stockname)
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, startNu, 1, 0.1)
		print "11111111111111111111111111111111111111111"
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, nu-0.1, 1, 0.01)
		print "22222222222222222222222222222222222222222"
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, nu-0.01, 1, 0.001)
		print "33333333333333333333333333333333333333333"
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, nu-0.001, 1, 0.0001)
		#psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestnu='${best}', bestCorrelation=$bestCorrelation where stockname='${stockName}'"
		curUp.execute("update {0} set bestnu={1}, bestCorrelation={2} where stockname='{3}'".format(dataminestocksViewName, nu-startNu, corr, stockname))
		conn.commit()
#		sys.exit()

	conn.close()
	print "finished all"

def optimiseNu(stockname, excludedattributes, extractdata, start, stop, step):
	print "Stock " + stockname

	tryNu=start
	bestNu=tryNu
	(trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, tryNu)
	print "Starting correlation={0}, with nu={1}".format(trialCorrelation, bestNu)
	bestCorrelation=trialCorrelation

	tryNu = start + step
	while tryNu < stop:
		print "Trial Nu={0}".format(tryNu)
		(trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, tryNu)
		print "Result: correlation={0} for trial Nu={1} with current bestCorrelation={2}".format(trialCorrelation, tryNu, bestCorrelation)
		if trialCorrelation >= bestCorrelation:
			bestCorrelation = trialCorrelation
			bestNu = tryNu
			print "Found better or same correlation="+str(bestCorrelation) + " with Nu={0}".format(bestNu)
		else:
			print "Not better. Best nu={0} with correlation={1}".format(bestNu, bestCorrelation)
			break
		tryNu=tryNu+step
	
	return (bestNu, bestCorrelation)

def optimiseattrall():
	print "optimiseattrall"
	query="select stockname, bestnu, bestcost from " + dataminestocksViewName + " where active=true and optimiseattr=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)
	for row in cur:
		optimiseattr(row[0], row[1])
	conn.close()
	print "finished all"

def optimiseattr(stockname, nu):
	print "Optimising attributes for {0}".format(stockname)
	extractdata = extractData(stockname)
	header=extractdata.splitlines()[0]
	hdrArray=header.split(",")
	hlen=len(hdrArray)
	print "array len={0}, class is last title={1}".format(hlen, hdrArray[hlen-1])
	(bestError, bestCorr, bestAttrCsv) = lsCalcModel(stockname, "-", cv, extractdata, nu)
	bestExcludeCsv=""
	trialExcludeCsv=""
	delim=""
	for colIdx in range(len(hdrArray) - 1):
		trialExcludeCsv=bestExcludeCsv+delim+"{0}".format(colIdx+1)
		(trialError, trialCorr, trailAttrCsv) = lsCalcModel(stockname, trialExcludeCsv, cv, extractdata)
		if trialCorr>bestCorr:
			print stockname + " found better correlation " + trialCorr
			bestCorr=trialCorr
			bestError=trialError
			bestExcludeCsv=trialExcludeCsv
			bestAttrCsv=trailAttrCsv
			delim=","

	print 'error=' + bestError + ', corr=' + bestCorr
	cmd="psql -h localhost -U postgres -d postgres -c \"update dataminestocks_py set bestattributes='{0}', excludedattributes='{1}', bestCorrelation={2}, error={3} where stockname='{4}'\"".format(bestAttrCsv, bestExcludeCsv, bestCorr, bestError, stockName)
	res = subprocess.check_output(cmd, shell=True)
	print res + ". " + stockname + " stock optimisation finished"

def buildModels(db='u'):
	print "buildModels"
	query="select stockname, excludedattributes, bestcost, bestnu from "+ dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
#	connDate = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	
	curDate = conn.cursor()
	cur.execute(query)
	for row in cur:

		stockname=row[0]
		excludedattributes=row[1]
		bestcost=row[2]
		nu=row[3]
		extractdata = extractData(stockname)

		curDate.execute("select date FROM datamining_stocks_view where stockName='CBA.AX' limit 1".format(stockname))
		for dateRow in curDate:
			date=str(dateRow[0])
			print 'date='+date

		(error, corr, attrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, nu)

		if db == 'u':
#			connUpdate = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
#			curUp = connUpdate.cursor()
#			curUp.execute("update {0} set correlation={1}, corrdate='{2}'::date, error=error where stockname='{3}'".format(dataminestocksViewName, corr, date, error, stockname))
			curUp = conn.cursor()
			curUp.execute("update {0} set correlation=%s, error=%s where stockname=%s".format(dataminestocksViewName), (corr, error, stockname))#, date, error, stockname))
			print 'DB updated with date="{0}"'.format(date)
			conn.commit()
			#curUp.close()

	conn.close()
	print "finished all"

def extractData(stockname):
	sql="COPY (SELECT * from datamine1('{0}') offset {1} limit {2}) TO STDOUT DELIMITER ',' CSV HEADER".format(stockname, offset, limit)
	extractdata = subprocess.check_output("export PGPASSWORD='postgres';psql -h localhost -U postgres -d postgres -c \"{0}\"".format(sql), shell=True)
	return extractdata

def main():
	if len(sys.argv) >= 2:
		if sys.argv[1] == 'attr':
			optimiseattrall()
		elif sys.argv[1] == 'nu':
			optimiseNuAll()
		elif sys.argv[1] == 'bm':
			buildModels()
	else:
		print "Allowed commands: 'attr', 'nu', 'bm'"

if __name__ == "__main__":
	main()
