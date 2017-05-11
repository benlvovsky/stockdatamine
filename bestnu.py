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

if [ -z "$2" ]
then
	echo "Usage: 1st parameter start for Nu, second parameter step"
	exit 999
fi

OLDIFS=$IFS
IFS=,
start=$1
step=$2

limit=1000
oldCost=$wkCost
oldNu=$wkNu
crossvalidation=2
while read stockName tail
do
	echo -n "$stockName..."
	excludeAttributeList=$(psql -h localhost -U postgres -d postgres -c \
		"COPY ( \
			select excludedattributes FROM dataminestocks where stockName='$stockName' \
			) TO STDOUT")

	try=$start
	wkCost=100
	best=$try
	wkNu=$try
	wkCalcModel ${stockName} "$excludeAttributeList" $crossvalidation
	echo -n "first done"
	bestCorrelation=$correlation
	echo " Starting correlation=$bestCorrelation, Nu=$best."
	i=1

	while true; do
		try=$(echo "$try+$step" | bc -l)
		echo -n "Trying nu=$try, step=$step. "
		wkNu=$try
		wkCalcModel ${stockName} "$excludeAttributeList" 2
		trialCorrelation=$correlation
		isFoundBetter=$(echo "$trialCorrelation >= $bestCorrelation" | bc)
		echo "trialCorrelation=$trialCorrelation, bestCorrelation=$bestCorrelation"
		if [ $isFoundBetter -eq 1 ]
		then
			echo -n "It is not worse with Nu=$wkNu, correlation=$trialCorrelation. Continue..."
			bestCorrelation=${trialCorrelation}
			best=$try
			step=$(echo "$step*2" | bc -l)
			echo ""
		else
			echo "Not better. Best nu=$best, correlation=$bestCorrelation"
			break
		fi
	done
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestnu='${best}', bestCorrelation=$bestCorrelation where stockname='${stockName}'"
done  < <(printf "TLS.AX\n")

def optimiseAll():
	query="select stockname from dataminestocks where active=true and (bestNu is NULL or len(trim(bestNu))=0) order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)
	for row in cur:
		stockName=row[0]
		print stockName
		optimiseOne(stockName)
	conn.close()
	print "finished all"

def optimiseOne(stockname):
	print "Optimising Nu for {0}".format(stockname)
	sql="COPY (SELECT * from datamine1('{0}') offset {1} limit {2}) TO STDOUT DELIMITER ',' CSV HEADER".format(stockname, offset, limit)
#	print sql
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

def main(startNu, originalStep):
	optimiseAll(startNu, originalStep)

if __name__ == "__main__":
	main()
