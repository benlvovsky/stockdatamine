#!/bin/bash
source ./common.sh

function attributeList() {
	local filename="attributelist.csv"
	local delim='' # no comma at start
	cat $filename | while read attr alias
	do
		printf "${delim}${attr} as ${alias}"
		delim=',' #ecerysubsequest attribute has to have comma in front
	done
}

#INPUT="dataminestocklist_test.csv"
INPUT="dataminestocklist.csv"
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
rm -rf ./extract
mkdir extracts
#chmod -R 777 ./extracts
cat $INPUT | while read stockName
do
	echo "Extracting $stockName..."
	sql="COPY (select DATE,price,stockname,$(attributeList) FROM datamining_stocks_view where stockName='${stockName}') TO '$(pwd)/extracts/${stockName}.csv' DELIMITER ',' CSV HEADER"
	printf "${sql}\n"
	psql -h localhost -U postgres -d postgres -c "${sql}"
done
IFS=$OLDIFS
