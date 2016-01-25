#!/usr/bin/env python

import sys
import psycopg2
import common.py

def construct_line( label, line ):
	new_line = []
	if float( label ) == 0.0:
		label = "0"
	new_line.append( label )

	for i, item in enumerate( line ):
		if item == '' or float( item ) == 0.0:
			continue
		new_item = "%s:%s" % ( i + 1, item )
		new_line.append( new_item )
	new_line = " ".join( new_line )
	new_line += "\n"
	return new_line

OLDIFS=$IFS
IFS=,
cv=2
limit=480
wkCost=100
wkNu=0.55

def optimiseattrall():
	#	psql -h localhost -U postgres -d postgres -c "COPY (select instrument from downloadinstruments where type='$1') to STDOUT WITH CSV delimiter as ','"
	query="select stockname from dataminestocks where active=true and optimiseattr=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)
	for row in cur:
		print row
		optimiseattr(row['stockname'])
	conn.close()
	print "finished all"

def optimiseattr(stockname):
	print "Optimising attributes for " + stockName

	print stockname + " stock optimisation finished"

while read stockName tail
do
	echo "$stockName..."
	echo "Building model for $stockName."
	query="select stockname from dataminestocks where active=true and optimiseattr=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)

	date=$(extractLastDate ${stockName})
	sql="COPY (select $(attributeList) FROM datamining_stocks_view where stockName='${stockName}' offset ${offset} limit ${limit}) TO STDOUT DELIMITER ',' CSV HEADER"
	psql -h localhost -U postgres -d postgres -c "${sql}" > extracts/${stockName}.csv
	lsCalcModel $stockName "-" $cv < extracts/${stockName}.csv
	bestError=$error
	bestCorrelation=${correlation}
	beginning=1
	echo "Original error=$bestError"
	allAttributes=$(head -1 extracts/${stockName}.csv)
	bestAttributes=$allAttributes
	i=1
	IFS=,
	read -r -a attrArray <<< "$allAttributes"
	classAttribute=${attrArray[-1]}
	echo "classAttribute='$classAttribute'"
	bestExcludedAttrs=""

	#excluded attribute list delimiter
	ead=""
	
	for tryAttr in ${allAttributes[@]}; do
#		set -x
		if [ "$tryAttr" != "${classAttribute}" ] 
		then
			echo -n "Trying attribute '$tryAttr' index $i... "
			trialExcludedAttrs=$bestExcludedAttrs$ead$i
			lsCalcModel ${stockName} "$trialExcludedAttrs" $cv  < extracts/${stockName}.csv
			#   $error and $correlation come from lsCalcModel() call
			echo -n " reported error=$error, correlation=$correlation. "
			isFoundBetter=$(echo "${error}<${bestError}" | bc)
			if [ ${isFoundBetter} -eq 1 ]
			then
				ead=","
				bestExcludedAttrs=$trialExcludedAttrs
				bestError=${error}
				bestCorrelation=${correlation}
				bestAttributes=$(head -1 <(printf "$extractdata"))
				echo -n " better with removed attribute $i $tryAttr"
			else
				echo -n " not better than $bestError"
			fi
			echo ""
		else
			echo "skipping class attribute"
		fi
		i=$((i+1))
	done
	echo "Best attrbutes list for $stockName calculated"
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestattributes='${bestAttributes}', excludedattributes='${bestExcludedAttrs}', bestCorrelation=$bestCorrelation, error=$bestError where stockname='${stockName}'"
done  < <(dmStocksOptimiseAttr)

IFS=$OLDIFS
