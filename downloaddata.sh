#!/bin/bash

downloadlist="downloadstocklist.csv"
export PGPASSWORD='postgres'
#psql -h localhost -U postgres -d postgres -c "TRUNCATE stocks"

INPUT=$downloadlist
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
cat $INPUT | while read stockName
do
	echo "Downloading $stockName..."
	maxdate=`psql -H -h localhost -U postgres -d postgres -c "select max(date) from stocks where stock='CBA.AX';"`;year=${maxdate:0:14};month=${maxdate:6:2};day=${maxdate:9:2};echo "${maxdate}--->${day}/${month}/${year}"
	psql -h localhost -U postgres -d postgres -c "select date from stocks where stock='$stockName' order by date limit 1"
	curl -o models/$stockName.csv http://real-chart.finance.yahoo.com/table.csv?s=$stockName\&a=10\&b=28\&c=1997\&d=11\&e=4\&f=2015\&g=d\&ignore=.csv
	echo "Adding Code field..."
	tail -n +2 models/${stockName}.csv | while read date open high low close vol adjclose tail
	do
		printf "\"$stockName\",\"${date}\",\"${open}\",\"${high}\",\"${low}\",\"${close}\",\"${vol}\"\n"
	done > models/${stockName}_fixed.csv
	echo "Importing $stockName into DB from models/${stockName}_fixed.csv"
	sql="COPY stocks (stock,date,open,high,low,close,\"Adj Close\") FROM '$(pwd)/models/${stockName}_fixed.csv' WITH CSV delimiter as ','"
	printf "${sql}\n"
	psql -h localhost -U postgres -d postgres -c "delete from stocks where stock='$stockName'"
	psql -h localhost -U postgres -d postgres -c "${sql}"
	echo "Importing $stockName into DB finished"
done

IFS=$OLDIFS
