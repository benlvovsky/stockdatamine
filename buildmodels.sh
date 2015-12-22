#!/bin/bash
#Expects extract being done. Looks for files in extrcts folder
source ./common.sh

OLDIFS=$IFS
IFS=,

#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
dmStocksNoAttr | while read stockName tail
do
	printf "Building model for $stockName..."
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${stockName}.csv > models/${stockName}.arff;
	correlation=$(java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 \
			-R 0.0 -N 0.74 -M 40.0 -C 5.0 -E 0.001 -P 0.1 \
			-seed 1 \
			-t "models/${stockName}.arff" \
			-d "models/${stockName}.model" | tee "models/${stockName}.model.output" \
				| grep "Correlation coefficient" | tail -1 | tr -s ' ' | cut -d " " -f 3)
	
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set correlation=${correlation} where stockname='${stockName}'"
	
	echo "correlation ${correlation}. done"
done
echo "Sorted stocks by correlation:"
dmStocksOrd
IFS=$OLDIFS
#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
