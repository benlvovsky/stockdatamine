#!/bin/bash
source ./common.sh
#export WEKA_PATH=/media/bigdrive/dev/weka-3-7-13/*.jar
#export CP=$WEKA_PATH:/home/ben/wekafiles/packages/LibSVM/LibSVM.jar:/home/ben/wekafiles/packages/LibSVM/lib/libsvm.jar:/media/bigdrive/dev/weka-3-7-13/weka.jar:$CLASSPATH

#modelsstocklist="dataminestocklist_test.csv"
modelsstocklist="dataminestocklist.csv"

OLDIFS=$IFS
IFS=,
[ ! -f $modelsstocklist ] && { echo "$modelsstocklist file not found"; exit 99; }

cat $modelsstocklist | while read stockName
do
	echo "Processing $stockName"
	java -classpath $CP weka.core.converters.CSVLoader -B 1000 extracts/${stockName}.csv > models/${stockName}.arff;
	java -classpath $CP -Xmx1000m weka.classifiers.functions.LibSVM -S 4 -K 2 -D 3 -G 0.0 \
			-R 0.0 -N 0.74 -M 40.0 -C 5.0 -E 0.001 -P 0.1 \
			-seed 1 \
			-t "models/${stockName}.arff" \
			-d "models/${stockName}.model" > "models/${stockName}.model.output"
done
IFS=$OLDIFS
