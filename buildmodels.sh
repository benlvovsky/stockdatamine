#!/bin/bash
source ./common.sh

modelsstocklist="dataminestocklist.csv"
attributelist="attributelist.csv"

OLDIFS=$IFS
IFS=,
[ ! -f $modelsstocklist ] && { echo "$modelsstocklist file not found"; exit 99; }
[ ! -f $attributelist ] && { echo "$attributelist file not found"; exit 99; }

#read attributes file into array

arrayAttrIdx=()
arrayAttrName=()
arrayAttrAlias=()
i=1
printf "Read attributes from file:"
cat $attributelist | while read attribute alias tail
do
    printf "$attribute($i),"
	arrayAttrIdx+=(i)
	i=$((i+1))
    arrayName+=("$attribute")
    arrayAlias+=("$alias")
done
printf "\ni is ${i}\n"

bestCorrelation=-100
cat $modelsstocklist | while read stockName
do
	echo "Processing $stockName. Array size=${#arrayName[*]}"
	for ((i=0; i < ${#arrayName[*]}; i++))
	do
		printf "Do weka command with attributes in use: (${arrayName[*]})"
	done
done
IFS=$OLDIFS
