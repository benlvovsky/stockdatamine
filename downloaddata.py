import os
import sys
import csv
import psycopg2
import subprocess
from datetime import *
from common import *

downlUrlDict = {"YAHOO" : r"http://real-chart.finance.yahoo.com/table.csv?s={0}&a={1}&b={2}&c={3}&d=11&e=4&f=2025&g=d&ignore=.csv",
				"FM"    : r"http://195.128.78.52/{0}.csv?market=5\&em=181410\&code={0}\&df={2}\&mf={1}\&yf={3}\&from={2}.{4}.{3}\&dt=31\&mt=11\&yt=2025\&to=31.12.2025\&p=8\&f={0}\&e=.csv\&cn={0}\&dtf=1\&tmf=4\&MSOR=0\&mstimever=0\&sep=1\&sep2=3\&datf=5\&at=1"}

def fmDownlParseFunc(csvrow):
	(date, time, openV, high, low, close, vol) = tuple(csvrow)
	adjclose = close
	vol = vol.strip()
	dateFixed = date[0:4] + "-" + date[4:6] + "-" + date[6:8]
	return (dateFixed, openV, high, low, close, vol, adjclose)

def yahooDownlParseFunc(csvrow):
	return tuple(csvrow)

downlParseFuncDict = {"YAHOO": yahooDownlParseFunc, "FM": fmDownlParseFunc}

def downloadInstruments():
	print "downloadInstruments..."
	query="select instrument, type from downloadinstruments"# where type='YAHOO'"
	conn = getdbcon()
	cur = conn.cursor()
	curDate = conn.cursor()
	cur.execute(query)
	print "cur.rowcount=" + str(cur.rowcount)
	for row in cur:
		stockName = row[0]
		downlType = row[1]
		print "Downloading " + stockName
		subprocess.call("rm downloads/"+stockName+"*.csv", shell=True)

		curDate.execute("select max(date + interval '1 day') from stocks where stock='" + stockName + "'")
		maxdaterow = curDate.fetchone()
		print "maxdaterow=" + str(maxdaterow)
		date = datetime.strptime("2000-01-01", "%Y-%m-%d").date()
		if maxdaterow and maxdaterow[0]:
			date = maxdaterow[0]

		print "date from=" + str(date) + " = " + str(date.day) + "/" + str(date.month)  + "/" + str(date.year)

		url = downlUrlDict[downlType].format(stockName, date.month-1, date.day, date.year, date.month)
		print "url=" + url

		cmd="curl -o downloads/"+stockName+".csv '" + url + "'"
		print "cmd=" + cmd
		proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		(stdoutdata, stderrdata) = proc.communicate()
		print stdoutdata

		with open("downloads/"+stockName+".csv", 'rb') as inf, open("downloads/"+stockName+"_fixed.csv", 'w') as outf:
			reader = csv.reader(inf, delimiter=",")
			writer = csv.writer(outf, delimiter=",")
			reader.next() # skip header
			for csvrow in reader:
				(date, openV, high, low, close, vol, adjclose) = downlParseFuncDict[downlType](csvrow)
				writer.writerow((stockName, date, openV, high, low, close, vol, adjclose))

		sql="COPY stocks (stock,date,open,high,low,close,volume,\\\"Adj Close\\\") FROM '" + str(os.getcwd()) \
			+ "/downloads/"+stockName+"_fixed.csv' WITH CSV delimiter as ','"
		print "SQL=" + sql
		subprocess.call('psql -h localhost -U postgres -d postgres -c "' + sql + '"', shell=True)
