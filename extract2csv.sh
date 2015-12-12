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
rm -rf ./extracts
mkdir ./extracts
chmod 777 -R ./extracts
cat $INPUT | while read stockName
do
	echo "Extracting $stockName..."
	sql="COPY (select DATE,price,$(attributeList) FROM datamining_stocks_view where stockName='${stockName}') TO '$(pwd)/extracts/${stockName}.csv' DELIMITER ',' CSV HEADER"
	printf "${sql}\n"
	psql -h localhost -U postgres -d postgres -c "${sql}"
done
IFS=$OLDIFS
