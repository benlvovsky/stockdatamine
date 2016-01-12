#!/bin/bash
#Expects extract being done. Looks for files in extrcts folder
source ./common.sh
source ./libsvmcommon.sh

OLDIFS=$IFS
IFS=,
offset=30
limit=480
wkCost=100
wkNu=0.556

while read stockName tail
do
	echo "Building model for $stockName."
	excludeAttrList=$(psql -h localhost -U postgres -d postgres -c "COPY (select excludedattributes from dataminestocks where stockname='$stockName') to STDOUT")
	date=$(extractLastDate ${stockName})
	sql="COPY (select $(attributeList) FROM datamining_stocks_view where stockName='${stockName}' offset ${offset} limit ${limit}) TO STDOUT DELIMITER ',' CSV HEADER"
	lsCalcModel $stockName "$excludeAttrList" 3 < <(psql -h localhost -U postgres -d postgres -c "${sql}")
#		| tee "extracts/${stockName}.ls.csv"
#	echo "Extracted form DB..."

#	psql -h localhost -U postgres -d postgres -c "update dataminestocks set correlation=${correlation}, corrdate='$date'::date where stockname='${stockName}'"

	echo -n " correlation=${correlation}. Error=$error"
	echo ""
done < <(printf "CBA.AX\n")

#<(dmStocksToPredict)
#<(printf "TLS.AX\n")
#"^AXJO\nBHP.AX\nCBA.AX\nWOW.AX\n"
#<(dmTheStocks "^AXJO")
#(dmStocks)
IFS=$OLDIFS
