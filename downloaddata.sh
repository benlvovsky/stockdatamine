#!/bin/bash

#downloadlist="downloadstocklist_test.csv"
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
	maxdate=`psql -t -h localhost -U postgres -d postgres -c "select max(date) from stocks where stock='$stockName';"`
	maxdate=${maxdate//[[:blank:]]/} #trim
	echo "maxdate='$maxdate'"
	if [ -z "$maxdate" ]; then
		maxdate="2014-01-01"
	fi
	echo "maxdate in use:$maxdate"
	year=${maxdate:0:4}
	month=${maxdate:5:2}
	monthfixed=$((month-1))
	printf "monthfixed=${monthfixed}\n"
	day=${maxdate:8:2}
	echo "Date to download from: ${maxdate}=${day}/${month}/${year}"
	url="http://real-chart.finance.yahoo.com/table.csv?s=$stockName&a=${monthfixed}&b=${day}&c=${year}&d=11&e=4&f=2025&g=d&ignore=.csv"
	echo $url
	#http://real-chart.finance.yahoo.com/table.csv?s=CBA.AX\&a=11 &b=4&c=2015&d=11&e=6&f=2015&g=d&ignore=.csv
	#http://real-chart.finance.yahoo.com/table.csv?s=CBA.AX\&a=12\&b=04\&c=2015\&d=11\&e=4\&f=2025\&g=d\&ignore=.csv
	curl -o models/$stockName.csv ${url}
	echo "Adding Code field..."
	tail -n +2 models/${stockName}.csv | while read date open high low close vol adjclose tail
	do
		printf "\"$stockName\",\"${date}\",\"${open}\",\"${high}\",\"${low}\",\"${close}\",\"${vol}\"\n"
	done > models/${stockName}_fixed.csv
	echo "Importing $stockName into DB from models/${stockName}_fixed.csv"
	sql="COPY stocks (stock,date,open,high,low,close,\"Adj Close\") FROM '$(pwd)/models/${stockName}_fixed.csv' WITH CSV delimiter as ','"
	printf "${sql}\n"
	#psql -h localhost -U postgres -d postgres -c "delete from stocks where stock='$stockName'"
	psql -h localhost -U postgres -d postgres -c "${sql}"
	echo "Importing $stockName into DB finished"
done

IFS=$OLDIFS
