#!/usr/bin/env python

import sys
import psycopg2
import common
import subprocess
from common import *

#OLDIFS=$IFS
#IFS=,
cv=5
limit=480
offset=20

def optimiseattrall():
	print "optimiseattrall"
	#	psql -h localhost -U postgres -d postgres -c "COPY (select instrument from downloadinstruments where type='$1') to STDOUT WITH CSV delimiter as ','"
	query="select stockname from dataminestocks where active=true and optimiseattr=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)
	for row in cur:
		stockName=row[0]
		print stockName
		optimiseattr(stockName)
	conn.close()
	print "finished all"

def optimiseattr(stockname):
	print "Optimising attributes for {0}".format(stockname)
	sql="COPY (SELECT * from datamine1('{0}') offset {1} limit {2}) TO STDOUT DELIMITER ',' CSV HEADER".format(stockname, offset, limit)
	print sql
	extractdata = subprocess.check_output("export PGPASSWORD='postgres';psql -h localhost -U postgres -d postgres -c \"{0}\"".format(sql), shell=True)
	header=extractdata.splitlines()[0]
	hdrArray=header.split(",")
	hlen=len(hdrArray)
	print "array len={0}, class is last title={1}".format(hlen, hdrArray[hlen-1])
	(bestError, bestCorr, bestAttrCsv) = lsCalcModel(stockname, "-", cv, extractdata)
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

def main():
	optimiseattrall()

if __name__ == "__main__":
	main()
