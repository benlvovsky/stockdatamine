#!/bin/bash
#Expects extract being done. Looks for files in extracts folder
source ./common.sh
source ./wekacommon.sh

OLDIFS=$IFS
IFS=,
crossvalidation=2
#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
#dmStocks
limit=480
wkCost=100
wkNu=0.55
while read stockName tail
do
	echo "$stockName..."
	rm -f extracts/${stockName}.csv
	extractStock ${stockName} > extracts/${stockName}.csv
#	calcModel ${stockName} "-" $crossvalidation
	wkCalcModel ${stockName} "-" $crossvalidation

	bestCorrelation=$correlation
	echo "Original correlation=$bestCorrelation"
	allAttributes=$(head -1 extracts/${stockName}_currtrialattr.csv)
	bestAttributes=$allAttributes
	i=1
	read -r -a attrArray <<< "$allAttributes"
	classAttribute=${attrArray[-1]}
	echo "classAttribute='$classAttribute'"
	excludedAttrs=""
	
	#excluded attribute list delimiter
	ead=""
	
	for tryAttr in ${allAttributes[@]}; do
		if [ "$tryAttr" != "${classAttribute}" ] 
		then
			echo "Trying attribute '$tryAttr' index $i"
			trialExcludedAttrs=$excludedAttrs$ead$i
#			calcModel ${stockName} "$trialExcludedAttrs" ${crossvalidation}
			wkCalcModel ${stockName} "$trialExcludedAttrs" $crossvalidation
			trialCorrelation=$correlation
			isFoundBetter=$(echo "${trialCorrelation}>${bestCorrelation}" | bc)
			echo -n "Trial correlation=$trialCorrelation. "
			if [ ${isFoundBetter} -eq 1 ]
			then
				excludedAttrs=$trialExcludedAttrs
				ead=","
				bestCorrelation=${trialCorrelation}
				mv extracts/${stockName}_currtrialattr.csv extracts/${stockName}_bestattr.csv
				mv models/${stockName}_currtrialattr.model models/${stockName}_bestattr.model
				bestAttributes=$(head -1 extracts/${stockName}_bestattr.csv)
				echo -n "It is better with removed attribute $i $tryAttr"
			else
				echo -n "Not better. Still on $bestCorrelation"
			fi
			echo ""
		else
			echo "skipping class attribute"
		fi
		i=$((i+1))
	done
	echo "Best attrbutes list for $stockName calculated"
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestattributes='${bestAttributes}', excludedattributes='${excludedAttrs}', bestCorrelation=$bestCorrelation where stockname='${stockName}'"
done  < <(printf "TLS.AX\n")
#< <(printf "^AXJO\nBHP.AX\nCBA.AX\nWOW.AX\n")
# < (dmStocksNoAttr)

IFS=$OLDIFS
