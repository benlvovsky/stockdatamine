from datetime import *
import time
import csv
import os
import calendar
import subprocess
import sys

import psycopg2

from common import *
import common

crumb = None

#https://query1.finance.yahoo.com/v7/finance/download/CBA.AX?period1=1451606400&period2=1514764800&interval=1d&events=history&crumb=W9G90F5GRNd
#https://query1.finance.yahoo.com/v7/finance/download/CBA.AX?period1=1493011050&period2=1495603050&interval=1d&events=history&crumb=W9G90F5GRNd

#https://query1.finance.yahoo.com/v7/finance/download/CBA.AX?period1=1492930738&period2=1495522738&interval=1d&events=history&crumb=W9G90F5GRNd

downlUrlDict = {"YAHOO" : r"https://query1.finance.yahoo.com/v7/finance/download/{ticker}?period1={period1}&period2={period2}&interval=1d&events=history&crumb={crumb}",
				"YAHOO_OLD" : r"http://real-chart.finance.yahoo.com/table.csv?s={0}&a={1}&b={2}&c={3}&d=11&e=4&f=2025&g=d&ignore=.csv",
				"FM"    : r"http://195.128.78.52/{0}.csv?market=5\&em=181410\&code={0}\&df={2}\&mf={1}\&yf={3}\&from={2}.{4}.{3}\&dt=31\&mt=11\&yt=2025\&to=31.12.2025\&p=8\&f={0}\&e=.csv\&cn={0}\&dtf=1\&tmf=4\&MSOR=0\&mstimever=0\&sep=1\&sep2=3\&datf=5\&at=1"}

def fmDownlParseFunc(csvrow):
	print "csvrow start..." + str(csvrow[0:8]) + "...end"
	(date, time, openV, high, low, close, vol) = tuple(csvrow[0:7])
	adjclose = close
	vol = vol.strip()
	dateFixed = date[0:4] + "-" + date[4:6] + "-" + date[6:8]
	print "dateFixed="+dateFixed
	return (dateFixed, openV, high, low, close, vol, adjclose)


def nullToZero(s):
	if s == 'null':
		return '0'
	else:
		return s

def yahooDownlParseFunc(csvrow):
	(date, openV, high, low, close, adjclose, vol) = tuple(csvrow[0:7])
# 	return tuple(csvrow)
	return (date,      nullToZero(openV), nullToZero(high), nullToZero(low), nullToZero(close), nullToZero(vol), nullToZero(adjclose))

def fmUrlDownlBuilderFunc(stockName, month, day, year):
	return downlUrlDict["FM"].format(stockName, month-1, day, year, month)

def getCrumb():
	global crumb
	if crumb is None:
		print "Calculating new crumb..."
		cmd="curl --cookie cookies.txt --cookie-jar cookies.txt https://au.finance.yahoo.com/quote/CBA.AX"
		proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		(stdoutdata, stderrdata) = proc.communicate()
		first = 'CrumbStore":{"crumb":"'
		last = '"},'
		crumb = stdoutdata.split(first)[1].split(last)[0]

	print "crumb='{0}'".format(crumb)
	return crumb

def yahooDownlUrlBuilderFunc(stockName, month, day, year):
	dt1 = datetime(year=year, month=month+1, day=day)
	dt2 = datetime(year=2025, month=01, day=01)
	timestamp1 = calendar.timegm(dt1.timetuple())
	timestamp2 = calendar.timegm(dt2.timetuple())
	return downlUrlDict["YAHOO"].format(ticker=stockName, period1=timestamp1, period2=timestamp2, crumb=getCrumb())

downlParseFuncDict = {"YAHOO": yahooDownlParseFunc, "FM": fmDownlParseFunc}
downlUrlBuilder = {"YAHOO": yahooDownlUrlBuilderFunc, "FM": fmUrlDownlBuilderFunc}

def downloadInstruments():
	print "downloadInstruments..."
	query="select instrument, type from v2.downloadinstruments order by instrument"
	conn = getdbcon()
	cur = conn.cursor()
	curDate = conn.cursor()
	cur.execute(query)
	print "cur.rowcount=" + str(cur.rowcount)
	for row in cur:
		stockName = row[0]
		downlType = row[1]
		print "Downloading " + stockName
		subprocess.call("rm -f downloads/"+stockName+"*.csv", shell=True)

		curDate.execute("select max(date + interval '1 day') from stocks where stock='" + stockName + "'")
		maxdaterow = curDate.fetchone()
		print "maxdaterow=" + str(maxdaterow)
		date = datetime.strptime("2000-01-01", "%Y-%m-%d").date()
		if maxdaterow and maxdaterow[0]:
			date = maxdaterow[0]

		print "date from=" + str(date) + " = " + str(date.day) + "/" + str(date.month)  + "/" + str(date.year)

		url = downlUrlBuilder[downlType](stockName, date.month-1, date.day, date.year)

		print "download url=" + url

		cmd="curl --cookie cookies.txt --cookie-jar cookies.txt -o downloads/"+stockName+".csv '" + url + "'"
		print "cmd=" + cmd
		proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		(stdoutdata, stderrdata) = proc.communicate()
		print stdoutdata

		if os.path.isfile("downloads/"+stockName+".csv"):
			loadindb = True
			with open("downloads/"+stockName+".csv", 'rb') as inf, open("downloads/"+stockName+"_fixed.csv", 'w') as outf:
				firstLine = inf.readline()
				print "firstLine="+firstLine
				if "High,Low,Close," not in firstLine and "<DATE>,<TIME>,<OPEN>,<HIGH>,<LOW>,<CLOSE>,<VOL>" not in firstLine:
					print "downloaded file has no stock price data"
					loadindb = False
				else:
					reader = csv.reader(inf, delimiter=",")
					writer = csv.writer(outf, delimiter=",")
					for csvrow in reader:
						(date, openV, high, low, close, vol, adjclose) = downlParseFuncDict[downlType](csvrow)
						writer.writerow((stockName, date, openV, high, low, close, vol, adjclose))

			if loadindb:
				sql = ""
#				sql += "CREATE TEMP TABLE tmp_table ON COMMIT DROP AS SELECT *  FROM stocks WITH NO DATA; "
#				sql += "CREATE TABLE tmp_table AS SELECT *  FROM stocks WITH NO DATA; "
				sql += "TRUNCATE table tmp_table;"
				sql += "COPY tmp_table (stock,date,open,high,low,close,volume,\\\"Adj Close\\\") FROM '" + str(os.getcwd()) \
					+ "/downloads/"+stockName+"_fixed.csv' WITH CSV delimiter as ','; "
#				sql += "INSERT INTO stocks SELECT DISTINCT ON (t.stock,t.date) * FROM tmp_table t where t.close <> 0 ORDER BY (t.stock,t.date); ";
				sql += "delete from tmp_table t where t.close = 0 or t.high = 0 or t.low = 0 or t.volume = 0 ; "
				sql += "delete from tmp_table t1 "\
    				"where exists (select 1 from tmp_table t2 "\
                  			"where t2.stock = t1.stock and t2.date = t1.date and t2.ctid > t1.ctid) ;"
				sql += "INSERT INTO stocks SELECT * FROM tmp_table t where "\
					" not exists (select 1 from stocks s where s.date = t.date and s.stock = t.stock) ;"
# 					"ORDER BY (t.stock,t.date); ";
#				sql += "commit; ";

 				print "SQL='{0}'...".format(sql)
# 				print "PGHOST=" + PGHOST
				subprocess.call('export PGPASSWORD=\'postgres\';psql -U postgres -d postgres -c "' + sql + '"', shell=True)
 				print "			...Done"
			# here a downloaded stock file has been processed
		# here a row in cursor for stocks and types been processed
			
	# here is done all stocks
	# V2: Stop doing sync as moving to a different processing work flow in V2
	#sql="delete from stocks where close = 0"
	#subprocess.call('export PGPASSWORD=\'postgres\';psql -U postgres -d postgres -c "' + sql + '"', shell=True)

# 	print "Synchronising aggregations..."
# 	curSync = conn.cursor()
# 	curSync.execute("select sync_aggr((now() - interval '3 months')::date)")
# 	print "Synchronised " + str(curSync.fetchone()[0]) + " rows"

def uploadInvestorDotComDataToDb():
	print "Uploading to DB..."
	sql = '''
--	TRUNCATE table tmp_table;
	TRUNCATE table stocks;
	DROP TABLE IF EXISTS tmp_table;
	create table tmp_table (stock text,date date,close float,open float,high float,low float,volume float);
	SET datestyle = 'ISO,MDY';
	COPY tmp_table (stock,date,close,open,high,low,volume) FROM STDIN WITH CSV delimiter as ';' ; 
	delete from tmp_table t where t.close = 0 or t.high = 0 or t.low = 0;-- or t.volume = 0 ;
	delete from tmp_table t1 where exists 
		(select 1 from tmp_table t2 where t2.stock = t1.stock and t2.date = t1.date and t2.ctid > t1.ctid) ;
	INSERT INTO stocks (stock,date,close,open,high,low,volume,\\\"Adj Close\\\") 
		SELECT stock,date,close,open,high,low,volume,close FROM tmp_table t where not exists 
			(select 1 from stocks s where s.date = t.date and s.stock = t.stock) ;
	'''
	print "SQL='{0}'...".format(sql)
	subprocess.call('export PGPASSWORD=\'postgres\';psql -U postgres -d postgres -c "' + sql + '"', shell=True)
 	print "        ...Done"
