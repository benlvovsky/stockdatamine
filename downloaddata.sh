#!/bin/bash
curl -o $1 http://real-chart.finance.yahoo.com/table.csv?s=$1\&a=10\&b=28\&c=1997\&d=11\&e=4\&f=2015\&g=d\&ignore=.csv
INPUT=$1
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read Date Open High Low Close Volume AdjClose
do
	echo "Date    =$Date"   
	echo "Open    =$Open"
	echo "High    =$High"
	echo "Low     =$Low"
	echo "Close   =$Close"
	echo "Volume  =$Volume"
	echo "AdjClose=$AdjClose"
done < $INPUT
IFS=$OLDIFS

# load into DB
psql -U postgres -c "TRUNCATE stocks"
sql="COPY stocks (date,stock,open,high,low,close,adjclose) FROM '/Users/lvoskyb/Documents/$1' WITH CSV HEADER delimiter as ','"
#echo $sql
psql -U postgres -c "$sql"
