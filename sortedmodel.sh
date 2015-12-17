#!/bin/bash
source ./common.sh

#INPUT="dataminestocklist_test.csv"
INPUT="dataminestocklist.csv"
OLDIFS=$IFS
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
#echo "Creating sorted csv..."
echo "Stock name,Model Correlation Coefficient"
cat $INPUT | while read stockName
do
	echo ${stockName},$(cat models/${stockName}.model.output | grep "Correlation coefficient" | tail -1 | tr -s ' ' | cut -d " " -f 3)
done | sort --field-separator=',' -nr --key=2 
#echo "Done..."
IFS=$OLDIFS
