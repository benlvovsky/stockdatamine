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
	rm models/${stockName}*.csv
	maxDatePlusOne ${stockName}
	url="http://real-chart.finance.yahoo.com/table.csv?s=$stockName\&a=${monthfixed}\&b=${day}\&c=${year}\&d=11\&e=4\&f=2025\&g=d\&ignore=.csv"
	echo $url
	#http://real-chart.finance.yahoo.com/table.csv?s=CBA.AX&a=12&b=04&c=2015&d=11&e=4&f=2025&g=d&ignore=.csv
	curl -o models/$stockName.csv ${url}
	echo "Adding Code field..."
	tail -n +2 models/${stockName}.csv | while read date open high low close vol adjclose tail
	do
		printf "\"$stockName\",\"${date}\",\"${open}\",\"${high}\",\"${low}\",\"${close}\",\"${vol}\"\n"
	done > models/${stockName}_fixed.csv
#	echo "Importing $stockName into DB from models/${stockName}_fixed.csv"
#	sql="COPY stocks (stock,date,open,high,low,close,\"Adj Close\") FROM '$(pwd)/models/${stockName}_fixed.csv' WITH CSV delimiter as ','"
#	printf "${sql}\n"
#	#	psql -h localhost -U postgres -d postgres -c "delete from stocks where stock='$stockName'"
#	psql -h localhost -U postgres -d postgres -c "${sql}"
#	echo "Importing $stockName into DB finished"
	importIntoDB ${stockName}
done
IFS=$OLDIFS
