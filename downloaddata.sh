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
	rm downloads/${stockName}*.csv
	maxDatePlusOne ${stockName}
	#ur_="http://real-chart.finance.yahoo.com/table.csv?s=BXB.AX&a=11&b=11&c=2015&d=11&e=15&f=2025&g=d&ignore=.csv"
	#ur_="http://real-chart.finance.yahoo.com/table.csv?s=BXB.AX&a=11&b=11&c=2015&d=11&e=4&f=2025&g=d&ignore=.csv"
	#url="http://real-chart.finance.yahoo.com/table.csv?s=$stockName\&a=${monthfixed}\&b=${day}\&c=${year}\&d=11\&e=4\&f=2025\&g=d\&ignore=.csv"
	url="http://real-chart.finance.yahoo.com/table.csv?s=$stockName&a=${monthfixed}&b=${day}&c=${year}&d=11&e=4&f=2025&g=d&ignore=.csv"
	echo $url
	#http://real-chart.finance.yahoo.com/table.csv?s=CBA.AX&a=12&b=04&c=2015&d=11&e=4&f=2025&g=d&ignore=.csv
	curl -o downloads/$stockName.csv ${url}
	echo "Adding Code field..."
	tail -n +2 downloads/${stockName}.csv | while read date open high low close vol adjclose tail
	do
		printf "\"$stockName\",\"${date}\",\"${open}\",\"${high}\",\"${low}\",\"${close}\",\"${vol}\",\"${adjclose}\"\n"
	done > downloads/${stockName}_fixed.csv

	importIntoDB ${stockName}
done
IFS=$OLDIFS
