#!/bin/bash
source ./common.sh

OLDIFS=$IFS
IFS=,
downloadInstruments FM | while read stockName
do
	echo "Downloading $stockName..."
	rm downloads/${stockName}*.csv
	#psql -h localhost -U postgres -d postgres -c "delete from stocks where stock='$stockName'"
	maxDatePlusOne ${stockName}
	url="http://195.128.78.52/${stockName}.csv?market=5\&em=181410\&code=${stockName}\&df=${day}\&mf=${monthfixed}\&yf=${year}\&from=${day}.${month}.${year}\&dt=31\&mt=11\&yt=2025\&to=31.12.2025\&p=8\&f=${stockName}\&e=.csv\&cn=${stockName}\&dtf=1\&tmf=4\&MSOR=0\&mstimever=0\&sep=1\&sep2=3\&datf=5\&at=1"
	echo $url
	curl -o downloads/$stockName.csv ${url}
	#curl -o downloads/EURUSD.csv http://195.128.78.52/EURUSD.csv?market=5\&em=181410\&code=EURUSD\&df=4\&mf=11\&yf=2015\&from=04.12.2015\&dt=31\&mt=11\&yt=2025\&to=31.12.2025\&p=8\&f=EURUSD\&e=.csv\&cn=EURUSD\&dtf=1\&tmf=4\&MSOR=0\&mstimever=0\&sep=1\&sep2=3\&datf=5\&at=1
	echo "Adding Code field..."
	tail -n +2 downloads/${stockName}.csv | while read date time open high low close vol tail
	do
		volfixed=$(echo ${vol} | tr -d '\r')
		#twice close to make up "Adjusted close"
		printf "\"$stockName\",\"${date:0:4}-${date:4:2}-${date:6:2}\",\"${open}\",\"${high}\",\"${low}\",\"${close}\",\"${volfixed}\",\"${close}\"\n"
	done > downloads/${stockName}_fixed.csv
	importIntoDB ${stockName}
done
IFS=$OLDIFS
