#!/bin/bash

downloadlist="downloadstocklist.csv"
export PGPASSWORD='postgres'
psql -h localhost -U postgres -d postgres -c "TRUNCATE stocks"

INPUT=$downloadlist
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read stockName
do
	echo "Downloading $stockName..."
	curl -o models/$stockName http://real-chart.finance.yahoo.com/table.csv?s=$stockName\&a=10\&b=28\&c=1997\&d=11\&e=4\&f=2015\&g=d\&ignore=.csv
	echo "Downloading $stockName finished"
	echo "Importing $stockName into DB..."
	# load into DB
	sql="COPY stocks (date,stock,open,high,low,close,\"Adj Close\") FROM '$(pwd)/models/$stockName' WITH CSV HEADER delimiter as ','"
	#echo $sql
	psql -h localhost -U postgres -d postgres -c "$sql"
	echo "Importing $stockName into DB finished"
done < $INPUT
IFS=$OLDIFS

