#!/bin/bash
source ./common.sh

suffix="_test"

OLDIFS=$IFS
IFS=,

dmStocksOrd | while read stockName tail
do
	excludeAttributeList=$(psql -h localhost -U postgres -d postgres -c \
		"COPY ( \
			select excludedattributes FROM dataminestocks where stockName='$stockName' \
			) TO STDOUT")
#	echo "excludeAttributeList=$excludeAttributeList"
	testFileName="${stockName}${suffix}"
	sql="COPY (select date,price,$(attributeList) FROM datamining_stocks_view where stockName='${stockName}' offset 0 limit 1) TO STDOUT DELIMITER ',' CSV HEADER"
	psql -h localhost -U postgres -d postgres -c "${sql}" > "extracts/${testFileName}.csv" 
	date=$(cat  extracts/${testFileName}.csv | tail -n +2 | cut -d ',' -f 1)
	fixedClassOnlyNeededAttr=$(paste -d '\0' extracts/${testFileName}.csv <(printf '\n-100'))
	fixedClassOnlyNeededAttr=$((printf "$fixedClassOnlyNeededAttr") | cut --complement -d, -f 1,2)
	fixedClassOnlyNeededAttr=$((printf "$fixedClassOnlyNeededAttr") | cut --complement -d, -f $(echo $excludeAttributeList))
#	echo "fixedClassOnlyNeededAttr=$fixedClassOnlyNeededAttr"
	printf "${fixedClassOnlyNeededAttr}" > extracts/${testFileName}_4weka.csv
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${testFileName}_4weka.csv > models/${testFileName}.arff
	prediction=$( \
	java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM \
			-p 1,2,3,4,5,6 \
			-T "models/${testFileName}.arff" \
			-l "models/${stockName}_bestattr.model" \
			| tail -n +6 | tr -s ' ' \
			| cut -d ' ' -f 4)
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set prediction=${prediction}, preddate='$date'::date where stockname='${stockName}'"
	echo $stockName,$date,$prediction
done
#dmStocksOrd
# | sort --field-separator=',' -nr --key=3 > "models/predicted.txt"
IFS=$OLDIFS
