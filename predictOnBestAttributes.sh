#!/bin/bash
source ./common.sh

suffix="_test"

OLDIFS=$IFS
IFS=,
dmStocksOrd | while read stockName tail
do
	bestAttributeList=$(psql -h localhost -U postgres -d postgres -c "${COPY (select bestattributes FROM dataminestocks where stockName='${stockName}') TO STDOUT}")
	
	#extract prediction data
	sql="COPY (select date,price,$(attributeList),next5 FROM datamining_stocks_view where stockName='${stockName}' offset 0 limit 1) TO STDOUT DELIMITER ',' CSV HEADER"
	psql -h localhost -U postgres -d postgres -c "${sql}" > "extracts/${stockName}${suffix}.csv" 

	testFileName="${stockName}${suffix}"
	#echo "Processing $stockName with filename ${testFileName}"
	fixedClass=$(paste -d '\0' <(cat extracts/${testFileName}.csv) <(printf '\n-100'))
	removedFirstCols=$(cut -d ',' -f 1,2  --complement <(printf "${fixedClass}"))
	date=$(cat  <(printf "${fixedClass}") | tail -n +2 | cut -d ',' -f 1)
	printf "${removedFirstCols}" > extracts/${testFileName}_4weka.csv
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${testFileName}_4weka.csv > models/${testFileName}.arff
	prediction=$( \
	java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM \
			-p 1,2,3,4,5,6 \
			-T "models/${testFileName}.arff" \
			-l "models/${stockName}.model" \
			| tail -n +6 | tr -s ' ' \
			| cut -d ' ' -f 4)
	echo $stockName,$date,$prediction
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set prediction=${prediction}, preddate='$date'::date where stockname='${stockName}'"
done
dmStocksOrd
# | sort --field-separator=',' -nr --key=3 > "models/predicted.txt"
IFS=$OLDIFS
