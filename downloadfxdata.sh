#!/bin/bash

downloadlist="downloadfxlist.csv"
export PGPASSWORD='postgres'
#psql -h localhost -U postgres -d postgres -c "TRUNCATE stocks"

INPUT=$downloadlist
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
cat $INPUT | while read stockName
do
	echo "Downloading $stockName..."
	curl -o models/$stockName.csv http://195.128.78.52/$stockName.csv?market=5\&em=181410\&code=$stockName\&df=1\&mf=10\&yf=2014\&from=01.11.2014\&dt=31\&mt=11\&yt=2025\&to=31.12.2025\&p=8\&f=$stockName\&e=.csv\&cn=$stockName\&dtf=1\&tmf=4\&MSOR=0\&mstimever=0\&sep=1\&sep2=3\&datf=5\&at=1
	echo "Adding Code field..."
	tail -n +2 models/${stockName}.csv | while read date time open high low close vol tail
	do
		printf "\"$stockName\",\"${date:0:4}-${date:4:2}-${date:6:2}\",\"${open}\",\"${high}\",\"${low}\",\"${close}\",\"${vol}\"\n"
	done > models/${stockName}_fixed.csv
	echo "Importing $stockName into DB from models/${stockName}_fixed.csv"
	sql="COPY stocks (stock,date,open,high,low,close,\"Adj Close\") FROM '$(pwd)/models/${stockName}_fixed.csv' WITH CSV delimiter as ','"
	printf "${sql}\n"
	psql -h localhost -U postgres -d postgres -c "delete from stocks where stock='$stockName'"
	psql -h localhost -U postgres -d postgres -c "${sql}"
	echo "Importing $stockName into DB finished"
done
IFS=$OLDIFS
