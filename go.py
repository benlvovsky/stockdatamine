#!/usr/bin/env python

import sys
import psycopg2
import common
import subprocess
from common import *
from datetime import datetime
#import time

#OLDIFS=$IFS
#IFS=,
cv=10
limit=480
offset=20
dataminestocksViewName="dataminestocks_py"
startNu=0.00000001
initialStepNu=0.1

def optimiseNuAll():
	print "optimiseNu"
	query="select stockname, excludedattributes from "+ dataminestocksViewName + " where active=true and excludedattributes is not NULL and excludedattributes<>'' and bestnu is NULL order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	curUp = conn.cursor()
	cur.execute(query)
	for row in cur:
		stockname=row[0]
		excludedattributes=row[1]
		extractdata = extractData(stockname)
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, startNu, 1, 0.1)
		print "11111111111111111111111111111111111111111"
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, nu-0.1, 1, 0.01)
		print "22222222222222222222222222222222222222222"
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, nu-0.01, 1, 0.001)
		print "33333333333333333333333333333333333333333"
		(nu, corr)=optimiseNu(stockname, excludedattributes, extractdata, nu-0.001, 1, 0.0001)
		#psql -h localhost -U postgres -d postgres -c "update dataminestocks set bestnu='${best}', bestCorrelation=$bestCorrelation where stockname='${stockName}'"
		curUp.execute("update {0} set bestnu={1}, bestCorrelation={2} where stockname='{3}'".format(dataminestocksViewName, nu-startNu, corr, stockname))
#		sys.exit()

	conn.commit()
	conn.close()
	print "finished all"

def optimiseNu(stockname, excludedattributes, extractdata, start, stop, step):
	print "Stock " + stockname

	tryNu=start
	bestNu=tryNu
	(trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, tryNu)
	print "Starting correlation={0}, with nu={1}".format(trialCorrelation, bestNu)
	bestCorrelation=trialCorrelation

	tryNu = start + step
	while tryNu < stop:
		print "Trial Nu={0}".format(tryNu)
		(trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, tryNu)
		print "Result: correlation={0} for trial Nu={1} with current bestCorrelation={2}".format(trialCorrelation, tryNu, bestCorrelation)
		if trialCorrelation >= bestCorrelation:
			bestCorrelation = trialCorrelation
			bestNu = tryNu
			print "Found better or same correlation="+str(bestCorrelation) + " with Nu={0}".format(bestNu)
		else:
			print "Not better. Best nu={0} with correlation={1}".format(bestNu, bestCorrelation)
			break
		tryNu=tryNu+step
	
	return (bestNu, bestCorrelation)

def optimiseattrall():
	print "optimiseattrall"
	query="select stockname, bestnu, bestcost from " + dataminestocksViewName + " where active=true and optimiseattr=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	cur.execute(query)
	for row in cur:
		optimiseattr(row[0], row[1])
	conn.close()
	print "finished all"

def optimiseattr(stockname, nu):
	print "Optimising attributes for {0}".format(stockname)
	extractdata = extractData(stockname)
	header=extractdata.splitlines()[0]
	hdrArray=header.split(",")
	hlen=len(hdrArray)
	print "array len={0}, class is last title={1}".format(hlen, hdrArray[hlen-1])
	(bestError, bestCorr, bestAttrCsv) = lsCalcModel(stockname, "-", cv, extractdata, nu)
	bestExcludeCsv=""
	trialExcludeCsv=""
	delim=""
	for colIdx in range(len(hdrArray) - 1):
		trialExcludeCsv=bestExcludeCsv+delim+"{0}".format(colIdx+1)
		(trialError, trialCorr, trailAttrCsv) = lsCalcModel(stockname, trialExcludeCsv, cv, extractdata)
		if trialCorr>bestCorr:
			print stockname + " found better correlation " + trialCorr
			bestCorr=trialCorr
			bestError=trialError
			bestExcludeCsv=trialExcludeCsv
			bestAttrCsv=trailAttrCsv
			delim=","

	print 'error=' + bestError + ', corr=' + bestCorr
	cmd="psql -h localhost -U postgres -d postgres -c \"update dataminestocks_py set bestattributes='{0}', excludedattributes='{1}', bestCorrelation={2}, error={3} where stockname='{4}'\"".format(bestAttrCsv, bestExcludeCsv, bestCorr, bestError, stockName)
	res = subprocess.check_output(cmd, shell=True)
	print res + ". " + stockname + " stock optimisation finished"

def buildModels(runtype='cv'):
	print "buildModels"
	query="select stockname, excludedattributes, bestcost, bestnu from "+ dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	
	curDate = conn.cursor()
	cur.execute(query)
	for row in cur:

		stockname=row[0]
		excludedattributes=row[1]
		bestcost=row[2]
		nu=row[3]
		extractdata = extractData(stockname)

		curDate.execute("select date FROM datamining_stocks_view where stockName='{0}' limit 1".format(stockname))
		for dateRow in curDate:
			date=str(dateRow[0])
			print 'date='+date

		(error, corr, attrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, nu)

		if runtype == 'cv':
			curUp = conn.cursor()
			curUp.execute("update {0} set correlation=%s, error=%s, corrdate=%s where stockname=%s".format(dataminestocksViewName), (corr, error, date, stockname))
			print 'DB updated with corrdate="{0}"'.format(date)
			conn.commit()

	conn.close()
	print "finished all"

def doPredictions1():
	print "Predicting"
	query="select stockname, excludedattributes, bestcost, bestnu from "+ dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()
	
	curDate = conn.cursor()
	cur.execute(query)
	for row in cur:

		stockname=row[0]
		excludedattributes=row[1]
		bestcost=row[2]
		nu=row[3]
		extractdata = extractData(stockname, 0, 1)

		curDate.execute("select date FROM datamining_stocks_view where stockName='{0}' limit 1".format(stockname))
		records = curDate.fetchall()
		rec=records[0]
		date=str(rec[0])
#		print 'date='+date
		(prediction, trainres, errorres) = lsPredict(stockname, excludedattributes, extractdata, nu)
		curUp = conn.cursor()
		curUp.execute("update {0} set prediction=%s, preddate=%s where stockname=%s".format(dataminestocksViewName), (prediction, date, stockname))

	conn.commit()
	conn.close()

def doPredictions():
	print "Predicting"
	query="select stockname, excludedattributes, bestcost, bestnu from "+ dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
	conn = psycopg2.connect("dbname = 'postgres' user = 'postgres' host = 'localhost' password = 'postgres'")
	cur = conn.cursor()	
	curUp = conn.cursor()	
	cur.execute(query)
	
	for row in cur:
		stockname=row[0]
		excludedattributes=row[1]
		bestcost=row[2]
		nu=row[3]

		sql="COPY (SELECT * from datamine_extra('{0}') offset 0 limit 7) TO STDOUT DELIMITER ',' CSV HEADER".format(stockname)
		print sql
		extracolsdata = subprocess.check_output("export PGPASSWORD='postgres';psql -h localhost -U postgres -d postgres -c \"{0}\"".format(sql), shell=True)
		proc = subprocess.Popen("cut --complement -d, -f 1,2", shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
		extractdata = proc.communicate(input=extracolsdata)[0]
#		print extractdata

		dateAr = []
		priceAr = []
		alldataAr = extracolsdata.splitlines()
		for i, val in enumerate(alldataAr):
			if i > 0:
				ar=val.split(",")
				dateAr.append(datetime.strptime(ar[0], "%Y-%m-%d").date())
				priceAr.append(float(ar[1]))
		
		print 'date array='+str(dateAr)
		print 'price array='+str(priceAr)
		(predictionAr, trainres, errorres) = lsPredictMulti(stockname, excludedattributes, extractdata, nu)
		print 'predictions array='+str(predictionAr)
		curUp.execute("select updatePredictions(%s, %s, %s, %s)", (stockname, dateAr, priceAr, predictionAr))

	conn.commit()
	
	#read predictions and email report
	cur.execute("select * from predictions")
	records = cur.fetchall()
	rec=records[0]
	rundate=str(rec[0])
	tbls="<table style='font-size:16px;font-family:Arial;border-collapse: collapse;border-spacing: 0;width: 100%;'>"
	tds="<td style='border: 1px solid #ddd;text-align: left;padding: 8px;'>"
	trs="<tr style='tr:nth-child(even){background-color: #f2f2f2}'>"
	ths="<th style='padding-top: 11px;padding-bottom: 11px;background-color: #4CAF50;color: white;border: 1px solid #ddd;text-align: left;padding: 8px;'>"

#	msg = "<head><title>SVM Results from " + rundate + "</title>"
#	msg += """
#	<style type="text/css">
#		table  {
#			font-size:16px;
#			font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
#			border-collapse: collapse;
#			border-spacing: 0;
#			width: 100%;
#		}
#		td, th {
#			border: 1px solid #ddd;
#			text-align: left;
#			padding: 8px;
#		}
#
#		tr:nth-child(even){background-color: #f2f2f2}
#
#		th {
#			padding-top: 11px;
#			padding-bottom: 11px;
#			background-color: #4CAF50;
#			color: white;
#		}
#		</style></head><body>
#	"""
	style=""#"style=\"font-size:16px;font-family: 'Trebuchet MS', Arial, Helvetica, sans-serif;border-collapse: collapse;border-spacing: 0;width: 100%;\""
	msg = "<!DOCTYPE html><div><b>Predictions from run date " + rundate + "</b></div><div>"

	for row in records:
		msg += "<div><br></br><br></br><b><span>"+stockname+"</span></b></div><div>" + tbls + trs
		msg += ths + "<span>Prediction Date</span></th>" + ths + "<span>Original price</span></th>" + ths + "<span>Prediction %</span></th>" + ths + "<span>Predicted price</span></th></tr>"
		stockname=row[1]
		datear=row[2]
		origprice=row[3]
		prediction=row[4]
		for i, val in enumerate(datear):
			msg += trs
			msg += tds + "<span>" + str(datear[i])+"</span></td>"
			msg += tds + "<span>" + str(origprice[i])+"</span></td>"
			msg += tds + "<span>" + str(prediction[i])+"</span></td>"
			msg += tds + "<span>" + str(origprice[i]*(1+prediction[i]))+"</span></td>"
			msg += "</tr>"
			
		msg += "</table></div>"

	msg += "</div>"

	text_file = open("./mail.html", "w")
	text_file.write(msg)
	text_file.close()

	cmd = "mail -a \"MIME-Version: 1.0\" -a \"Content-type: text/html\" -s \"SVM Results from " + rundate + "\" ben@lvovsky.com < ./mail.html"
#	cmd = "mail -s \"SVM Results from " + rundate + "\" ben@lvovsky.com"
	print cmd
	proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	(outputdata, errdata) = proc.communicate()

	print outputdata
	if errdata != None:
		print errdata
	
	conn.close()

def main():
	if len(sys.argv) >= 2:
		timeStart = datetime.now()
		if sys.argv[1] == 'attr':
			optimiseattrall()
		elif sys.argv[1] == 'nu':
			optimiseNuAll()
		elif sys.argv[1] == 'bm':
			if len(sys.argv) < 3:
				par=None
			else:
				par=sys.argv[2]
			buildModels(par)
		elif sys.argv[1] == 'pr':
			doPredictions()
		timeEnd = datetime.now()
		print "Done, it took {0}".format(timeEnd-timeStart)

	else:
		print "Allowed commands: 'attr', 'nu', 'bm [crossValNumber]', 'pr'"

if __name__ == "__main__":
	main()
