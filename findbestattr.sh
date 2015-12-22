#!/bin/bash
#Expects extract being done. Looks for files in extracts folder
source ./common.sh

OLDIFS=$IFS
IFS=,
crossvalidation=2
#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
#dmStocks
dmStocksNoAttr | while read stockName tail
do
	echo "$stockName..."
	calcModel ${stockName} "-" $crossvalidation
	bestCorrelation=$correlation
	echo "Original correlation=$bestCorrelation"
	allAttributes=$(head -1 extracts/${stockName}.csv)
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
		#	psql -h localhost -U postgres -d postgres -c "update dataminestocks set correlation=${correlation} where stockname='${stockName}'"
			#echo "trialExcludedAttrs='$trialExcludedAttrs'"
			calcModel ${stockName} "$trialExcludedAttrs" ${crossvalidation}
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
done

IFS=$OLDIFS
#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
#	psql -h localhost -U postgres -d postgres -c "update dataminestocks set correlation=${correlation} where stockname='${stockName}'"

