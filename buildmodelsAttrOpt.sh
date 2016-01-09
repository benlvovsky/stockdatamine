#!/bin/bash
#Expects extract being done. Looks for files in extrcts folder
source ./common.sh
source ./wekacommon.sh

OLDIFS=$IFS
IFS=,
limit=480
wkCost=100
wkNu=0.556

#./extract2csv.sh -m
#psql -h localhost -U postgres -d postgres -c "COPY (select * from dataminestocks) to STDOUT WITH CSV delimiter as ','"
while read stockName tail
do
	echo "Building model for $stockName."
	excludeAttrList=$(psql -h localhost -U postgres -d postgres -c "COPY (select excludedattributes from dataminestocks where stockname='$stockName') to STDOUT")
	date=$(extractLastDate ${stockName})
	wkCalcModel $stockName "$excludeAttrList" 2
	#echo "$excludeAttrList"
	mv models/${stockName}_currtrialattr.model models/${stockName}_bestattr.model

	psql -h localhost -U postgres -d postgres -c "update dataminestocks set correlation=${correlation}, corrdate='$date'::date where stockname='${stockName}'"

	echo -n " correlation ${correlation}. done."
	echo ""
done < <(printf "TLS.AX\n")
#"^AXJO\nBHP.AX\nCBA.AX\nWOW.AX\n"
#<(dmTheStocks "^AXJO")
#(dmStocks)
IFS=$OLDIFS
