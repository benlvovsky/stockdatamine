#!/bin/bash
source ./common.sh
source ./libsvmcommon.sh

OLDIFS=$IFS
IFS=,
cv=2
limit=480
wkCost=100
wkNu=0.55
while read stockName tail
do
	echo "$stockName..."
	echo "Building model for $stockName."
	date=$(extractLastDate ${stockName})
	sql="COPY (select $(attributeList) FROM datamining_stocks_view where stockName='${stockName}' offset ${offset} limit ${limit}) TO STDOUT DELIMITER ',' CSV HEADER"
	psql -h localhost -U postgres -d postgres -c "${sql}" > extracts/${stockName}.csv
	lsCalcModel $stockName "-" $cv < extracts/${stockName}.csv
	bestError=$error
	bestCorrelation=${correlation}
	beginning=1
	echo "Original error=$bestError"
	allAttributes=$(head -1 extracts/${stockName}.csv)
	bestAttributes=$allAttributes
	i=1
	IFS=,
	read -r -a attrArray <<< "$allAttributes"
	classAttribute=${attrArray[-1]}
	echo "classAttribute='$classAttribute'"
	bestExcludedAttrs=""

	#excluded attribute list delimiter
	ead=""
	
	for tryAttr in ${allAttributes[@]}; do
#		set -x
		if [ "$tryAttr" != "${classAttribute}" ] 
		then
			echo -n "Trying attribute '$tryAttr' index $i... "
			trialExcludedAttrs=$bestExcludedAttrs$ead$i
			lsCalcModel ${stockName} "$trialExcludedAttrs" $cv  < extracts/${stockName}.csv
			#   $error and $correlation come from lsCalcModel() call
			echo -n " reported error=$error, correlation=$correlation. "
			isFoundBetter=$(echo "${error}<${bestError}" | bc)
			if [ ${isFoundBetter} -eq 1 ]
			then
				ead=","
				bestExcludedAttrs=$trialExcludedAttrs
				bestError=${error}
				bestCorrelation=${correlation}
				bestAttributes=$(head -1 <(printf "$extractdata"))
				echo -n " better with removed attribute $i $tryAttr"
			else
				echo -n " not better than $bestError"
			fi
			echo ""
		else
			echo "skipping class attribute"
		fi
		i=$((i+1))
	done
	echo "Best attrbutes list for $stockName calculated"
	psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestattributes='${bestAttributes}', excludedattributes='${bestExcludedAttrs}', bestCorrelation=$bestCorrelation, error=$bestError where stockname='${stockName}'"
done  < <(dmStocksOptimiseAttr)
#<(printf "TLS.AX\n")

IFS=$OLDIFS
