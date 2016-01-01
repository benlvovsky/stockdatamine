#!/bin/bash
#Expects extract being done. Looks for files in extracts folder
source ./common.sh
source ./wekacommon.sh

OLDIFS=$IFS
IFS=,
start=$1
step=$2

limit=1000
oldCost=$wkCost
oldNu=$wkNu
while read stockName tail
do
	echo -n "$stockName..."
	excludeAttributeList=$(psql -h localhost -U postgres -d postgres -c \
		"COPY ( \
			select excludedattributes FROM dataminestocks where stockName='$stockName' \
			) TO STDOUT")

	try=$start
	wkCost=1
	best=$try
	wkNu=$try
	wkCalcModel ${stockName} "$excludeAttributeList" 2
	bestCorrelation=$correlation
	echo " Starting correlation=$bestCorrelation, Nu=$best."
	i=1

	while true; do
		try=$(echo "$try+$step" | bc -l)
		echo -n "Trying nu=$try, step=$step. "
		wkNu=$try
		wkCalcModel ${stockName} "$excludeAttributeList" 2
		trialCorrelation=$correlation
		isFoundBetter=$(echo "${trialCorrelation}>${bestCorrelation}" | bc)
		if [ ${isFoundBetter} -eq 1 ]
		then
			echo -n "It is better with Nu=$wkNu, correlation=$trialCorrelation"
			bestCorrelation=${trialCorrelation}
			best=$try
			step=$(echo "$step*2" | bc -l)
			echo ""
		else
			echo "Not better. Best nu=$best, correlation=$bestCorrelation"
			break
		fi
	done
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestnu='${best}', bestCorrelation=$bestCorrelation where stockname='${stockName}'"
done  < <(echo "^AXJO")
# < (dmStocksNoAttr)

IFS=$OLDIFS
wkNu=$oldNu
wkCost=$oldCost
