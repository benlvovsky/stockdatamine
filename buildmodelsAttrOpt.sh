#!/bin/bash
#Expects extract being done. Looks for files in extrcts folder
source ./common.sh

OLDIFS=$IFS
IFS=,

#./extract2csv.sh -m
#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
while read stockName tail
do
	echo "Building model for $stockName."
	excludeAttrList=$(psql -h localhost -U postgres -d postgres -c "COPY (select excludedattributes from dataminestocks where stockname='$stockName') to STDOUT")
	extractStock ${stockName} | cut --complement -d, -f $(echo $excludeAttrList) > extracts/${stockName}_exclattr.csv
	date=$(extractLastDate ${stockName})
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${stockName}_exclattr.csv > extracts/${stockName}_exclattr.arff
	echo $arff
	correlation=$(java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 \
			-R 0.0 -N 0.74 -M 40.0 -C 5.0 -E 0.001 -P 0.1 \
			-seed 1 \
			-t extracts/${stockName}_exclattr.arff \
			-d "models/${stockName}_bestattr.model" | tee "models/${stockName}.model.output" \
				| grep "Correlation coefficient" | tail -1 | tr -s ' ' | cut -d " " -f 3)

	psql -h localhost -U postgres -d postgres -c "update dataminestocks set correlation=${correlation}, corrdate='$date'::date where stockname='${stockName}'"

	echo " correlation ${correlation}. done."
done < <(dmTheStocks "^AXJO")
#(dmStocks)

#echo "Sorted stocks by correlation:"
#dmStocksOrd
IFS=$OLDIFS
#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
