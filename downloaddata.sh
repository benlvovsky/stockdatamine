#!/bin/bash
source ./common.sh

#downloadlist="downloadstocklist_test.csv"
downloadlist="downloadstocklist.csv"

INPUT=$downloadlist
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
cat $INPUT | while read stockName
do
	echo "Downloading $stockName..."
	maxDatePlusOne ${stockName}
	url="http://real-chart.finance.yahoo.com/table.csv?s=$stockName&a=${monthfixed}&b=${day}&c=${year}&d=11&e=4&f=2025&g=d&ignore=.csv"
	echo $url
	#http://real-chart.finance.yahoo.com/table.csv?s=CBA.AX\&a=12\&b=04\&c=2015\&d=11\&e=4\&f=2025\&g=d\&ignore=.csv
	curl -o models/$stockName.csv ${url}
	echo "Adding Code field..."
	tail -n +2 models/${stockName}.csv | while read date open high low close vol adjclose tail
	do
		printf "\"$stockName\",\"${date}\",\"${open}\",\"${high}\",\"${low}\",\"${close}\",\"${vol}\",\"${adjclose}\"\n"
	done > models/${stockName}_fixed.csv

	importIntoDB ${stockName}
done
IFS=$OLDIFS
