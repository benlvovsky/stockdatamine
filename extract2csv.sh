#!/bin/bash
source ./common.sh

#INPUT="dataminestocklist_test.csv"
#INPUT="dataminestocklist.csv"
OLDIFS=$IFS
IFS=,
#[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
if [[ "$1" != '-m' && "$1" != '-t' ]]
then
	echo "Got parameter '${1}'. Should have one parameter:"
	echo "	-m for models extracts (bulk records) or"
	echo "	-p for prediction extract (only last record)"
	exit 99
elif [ "$1" = '-m' ]
then
	offset=30
	limit=200
	fileSuffix=''
	extraAttributes=""
	echo "	-m for models"
else
	offset=0
	limit=1
	fileSuffix='_test'
	extraAttributes="date,price,"
	echo "	-t for tests"
fi
#rm -rf ./extracts
#mkdir ./extracts
#chmod 777 -R ./extracts
#cat $INPUT
dmStocks | while read stockName tail
do
	echo "Extracting $stockName limit=$limit, offset=$offset, fileSuffix=$fileSuffix"
	sql="COPY (select ${extraAttributes}$(attributeList) FROM datamining_stocks_view where stockName='${stockName}' offset ${offset} limit ${limit}) TO '$(pwd)/extracts/${stockName}${fileSuffix}.csv' DELIMITER ',' CSV HEADER"
#	printf "${sql}\n"
	psql -h localhost -U postgres -d postgres -c "${sql}"
done
IFS=$OLDIFS
