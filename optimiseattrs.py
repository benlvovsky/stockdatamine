#!/usr/bin/env python

import sys
import psycopg2
import common.py

def viewquery="""
 SELECT s.date,
    s.stock AS stockname,
    s."Adj Close" AS price,
    stockavgdiffset(s.stock, s.date) AS stockavg,
    stockavgdiffset('^AORD'::text, s.date) AS aord,
    stockavgdiffset('^N225'::text, s.date) AS n225,
    stockavgdiffset('^NDX'::text, s.date) AS ndx,
    stockavgdiffset('^DJI'::text, s.date) AS dji,
    stockavgdiffset('^FTSE'::text, s.date) AS ftse,
    stockavgdiffset('^GDAXI'::text, s.date) AS gdaxi,
    stockavgdiffset('^SSEC'::text, s.date) AS ssec,
    stockavgdiffset('^HSI'::text, s.date) AS hsi,
    stockavgdiffset('^BSESN'::text, s.date) AS bsesn,
    stockavgdiffset('^JKSE'::text, s.date) AS jkse,
    stockavgdiffset('^KLSE'::text, s.date) AS klse,
    stockavgdiffset('^NZ50'::text, s.date) AS nz50,
    stockavgdiffset('^STI'::text, s.date) AS sti,
    stockavgdiffset('^KS11'::text, s.date) AS ks11,
    stockavgdiffset('^TWII'::text, s.date) AS twii,
    stockavgdiffset('^BVSP'::text, s.date) AS bvsp,
    stockavgdiffset('^GSPTSE'::text, s.date) AS gsptse,
    stockavgdiffset('^MXX'::text, s.date) AS mxx,
    stockavgdiffset('^GSPC'::text, s.date) AS gspc,
    stockavgdiffset('^ATX'::text, s.date) AS atx,
    stockavgdiffset('^BFX'::text, s.date) AS bfx,
    stockavgdiffset('^FCHI'::text, s.date) AS fchi,
    stockavgdiffset('^OSEAX'::text, s.date) AS oseax,
    stockavgdiffset('^OMXSPI'::text, s.date) AS omxspi,
    stockavgdiffset('^SSMI'::text, s.date) AS ssmi,
    stockavgdiffset('GD.AT'::text, s.date) AS gd,
    stockavgdiffset('EURUSD'::text, s.date) AS eurusd,
    stockavgdiffset('USDJPY'::text, s.date) AS usdjpy,
    stockavgdiffset('USDCHF'::text, s.date) AS usdchf,
    stockavgdiffset('GBPUSD'::text, s.date) AS gbpusd,
    stockavgdiffset('USDCAD'::text, s.date) AS usdcad,
    stockavgdiffset('EURGBP'::text, s.date) AS eurgbp,
    stockavgdiffset('EURJPY'::text, s.date) AS eurjpy,
    stockavgdiffset('EURCHF'::text, s.date) AS eurchf,
    stockavgdiffset('AUDUSD'::text, s.date) AS audusd,
    stockavgdiffset('GBPJPY'::text, s.date) AS gbpjpy,
    stockavgdiffset('CHFJPY'::text, s.date) AS chfjpy,
    stockavgdiffset('GBPCHF'::text, s.date) AS gbpchf,
    stockavgdiffset('NZDUSD'::text, s.date) AS nzdusd,
    stockavgdiffset('CHOC'::text, s.date) AS cmd_choc,
    stockavgdiffset('CORN'::text, s.date) AS cmd_corn,
    stockavgdiffset('CTNN'::text, s.date) AS cmd_ctnn,
    stockavgdiffset('CUPM'::text, s.date) AS cmd_cupm,
    stockavgdiffset('FOIL'::text, s.date) AS cmd_foil,
    stockavgdiffset('GAZ'::text, s.date) AS cmd_gaz,
    stockavgdiffset('GLD'::text, s.date) AS cmd_gld,
    stockavgdiffset('HEVY'::text, s.date) AS cmd_hevy,
    stockavgdiffset('LEDD'::text, s.date) AS cmd_ledd,
    stockavgdiffset('LSTK'::text, s.date) AS cmd_lstk,
    stockavgdiffset('NINI'::text, s.date) AS cmd_nini,
    stockavgdiffset('OIL'::text, s.date) AS cmd_oil,
    stockavgdiffset('PALL'::text, s.date) AS cmd_pall,
    stockavgdiffset('PPLT'::text, s.date) AS cmd_pplt,
    stockavgdiffset('SGAR'::text, s.date) AS cmd_sgar,
    stockavgdiffset('SLV'::text, s.date) AS cmd_slv,
    stockavgdiffset('SOYB'::text, s.date) AS cmd_soyb,
    stockavgdiffset('UHN'::text, s.date) AS cmd_uhn,
    date_part('dow'::text, s.date) AS dow,
    date_part('week'::text, s.date) AS week,
    islastthurthday(s.date) AS optexpday,
    change(s.stock, s.date, '7 days'::interval) AS prediction
   FROM stocks s
  WHERE s.stock={1} order by s.date desc
  limit 10;
"""

def construct_line( label, line ):
	new_line = []
	if float( label ) == 0.0:
		label = "0"
	new_line.append( label )

	for i, item in enumerate( line ):
		if item == '' or float( item ) == 0.0:
			continue
		new_item = "%s:%s" % ( i + 1, item )
		new_line.append( new_item )
	new_line = " ".join( new_line )
	new_line += "\n"
	return new_line

OLDIFS=$IFS
IFS=,
cv=2
limit=480
wkCost=100
wkNu=0.55

def optimiseattrall():
	#	psql -h localhost -U postgres -d postgres -c "COPY (select instrument from downloadinstruments where type='$1') to STDOUT WITH CSV delimiter as ','"
	query="select stockname from dataminestocks where active=true and optimiseattr=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)
	for row in cur:
		print row
		optimiseattr(row['stockname'])
	conn.close()
	print "finished all"

def optimiseattr(stockname):
	print "Optimising attributes for " + stockName
	outresult=subprocess.Popen(viewquery.format(stockname)
	print stockname + " stock optimisation finished"

while read stockName tail
do
	echo "$stockName..."
	echo "Building model for $stockName."
	query="select stockname from dataminestocks where active=true and optimiseattr=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)

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

IFS=$OLDIFS
