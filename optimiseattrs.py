#!/usr/bin/env python

import sys
import psycopg2
import common
import subprocess
from common import *

#OLDIFS=$IFS
#IFS=,
cv=2
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
	sql="COPY (SELECT * from datamine('{0}', {1}, {2})) TO STDOUT DELIMITER ',' CSV HEADER".format(stockname, offset, limit)
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
		trialExcludeCsv=delim+"{0}".format(colIdx+1)
		(trialError, trialCorr, trailAttrCsv) = lsCalcModel(stockname, trialExcludeCsv, cv, extractdata)
		if trialCorr>corr:
			bestCorr=trialCorr
			bestError=trialError
			bestExcludeCsv=trialExcludeCsv
			bestAttrCsv=trailAttrCsv
			delim=","

	print 'error=' + bestError + ', corr=' + bestCorr
	cmd="psql -h localhost -U postgres -d postgres -c \"update dataminestocks set bestattributes='{0}', excludedattributes='{1}', bestCorrelation={2}, error={3} where stockname='{4}'\"".format(bestAttrCsv, bestExcludeCsv, bestCorr, bestError, stockName)
	res = subprocess.check_output(cmd, shell=True)
	print res + ". " + stockname + " stock optimisation finished"

def main():
	optimiseattrall()

if __name__ == "__main__":
	main()

#	lsCalcModel $stockName "-" $cv < extracts/${stockName}.csv
#	bestError=$error
#	bestCorrelation=${correlation}
#	beginning=1
#	echo "Original error=$bestError"
#	allAttributes=$(head -1 extracts/${stockName}.csv)
#	bestAttributes=$allAttributes
#	i=1
#	IFS=,
#	read -r -a attrArray <<< "$allAttributes"
#	classAttribute=${attrArray[-1]}
#	echo "classAttribute='$classAttribute'"
#	bestExcludedAttrs=""
#
#	#excluded attribute list delimiter
#	ead=""
#	
#	for tryAttr in ${allAttributes[@]}; do
##		set -x
#		if [ "$tryAttr" != "${classAttribute}" ] 
#		then
#			echo -n "Trying attribute '$tryAttr' index $i... "
#			trialExcludedAttrs=$bestExcludedAttrs$ead$i
#			lsCalcModel ${stockName} "$trialExcludedAttrs" $cv  < extracts/${stockName}.csv
#			#   $error and $correlation come from lsCalcModel() call
#			echo -n " reported error=$error, correlation=$correlation. "
#			isFoundBetter=$(echo "${error}<${bestError}" | bc)
#			if [ ${isFoundBetter} -eq 1 ]
#			then
#				ead=","
#				bestExcludedAttrs=$trialExcludedAttrs
#				bestError=${error}
#				bestCorrelation=${correlation}
#				bestAttributes=$(head -1 <(printf "$extractdata"))
#				echo -n " better with removed attribute $i $tryAttr"
#			else
#				echo -n " not better than $bestError"
#			fi
#			echo ""
#		else
#			echo "skipping class attribute"
#		fi
#		i=$((i+1))
#	done
#	echo "Best attrbutes list for $stockName calculated"
#	psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestattributes='${bestAttributes}', excludedattributes='${bestExcludedAttrs}', bestCorrelation=$bestCorrelation, error=$bestError where stockname='${stockName}'"
#done  < <(dmStocksOptimiseAttr)
#
#IFS=$OLDIFS
#
