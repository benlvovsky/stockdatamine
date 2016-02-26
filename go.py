#!/usr/bin/env python
"""Main module to process all stat calculation tasks."""

import sys
import common
import optimise
import subprocess
from downloaddata import downloadInstruments
# from common import *
from datetime import datetime
from datetime import timedelta


def optimiseNuAll():
    """optimisa Nu process. TODO: move into optimise module."""
    print "optimiseNu"
    query = "select stockname, excludedattributes from " + common.dataminestocksViewName +\
        " where active=true and excludedattributes is not NULL and excludedattributes<>'' "
    "and bestnu is NULL order by stockname asc"
    conn = common.getdbcon()
    cur = conn.cursor()
    curUp = conn.cursor()
    cur.execute(query)
    for row in cur:
        stockname = row[0]
        excludedattributes = row[1]
        extractdata = common.extractData(stockname)
        (nu, corr) = optimiseNu(stockname, excludedattributes, extractdata, common.startNu, 1, 0.1)
        print "11111111111111111111111111111111111111111"
        (nu, corr) = optimiseNu(stockname, excludedattributes, extractdata, nu - 0.1, 1, 0.01)
        print "22222222222222222222222222222222222222222"
        (nu, corr) = optimiseNu(stockname, excludedattributes, extractdata, nu - 0.01, 1, 0.001)
        print "33333333333333333333333333333333333333333"
        (nu, corr) = optimiseNu(stockname, excludedattributes, extractdata, nu - 0.001, 1, 0.0001)
        # psql -h localhost -U postgres -d postgres -c "update dataminestocks set
        # bestnu='${best}', bestCorrelation=$bestCorrelation where
        # stockname='${stockName}'"
        curUp.execute("update {0} set bestnu={1}, bestCorrelation={2} where stockname='{3}'".format(
            common.dataminestocksViewName, nu - common.startNu, corr, stockname))
#        sys.exit()

    conn.commit()
    conn.close()
    print "finished all"


def optimiseNu(stockname, excludedattributes, extractdata, start, stop, step):
    """optimise Nu for one stock. TODO: move to optimise module."""
    print "Stock " + stockname

    tryNu = start
    bestNu = tryNu
    (trialError, trialCorrelation, trailAttrCsv) = common.lsCalcModel(stockname, excludedattributes, common.cv,
                                                                      extractdata, tryNu)
    print "Starting correlation={0}, with nu={1}".format(trialCorrelation, bestNu)
    bestCorrelation = trialCorrelation

    tryNu = start + step
    while tryNu < stop:
        print "Trial Nu={0}".format(tryNu)
        (trialError, trialCorrelation, trailAttrCsv) = common.lsCalcModel(
            stockname, excludedattributes, common.cv, extractdata, tryNu)
        print "Result: correlation={0} for trial Nu={1} with current bestCorrelation={2}".\
            format(trialCorrelation, tryNu, bestCorrelation)
        if trialCorrelation >= bestCorrelation:
            bestCorrelation = trialCorrelation
            bestNu = tryNu
            print "Found better or same correlation=" + str(bestCorrelation) + " with Nu={0}".format(bestNu)
        else:
            print "Not better. Best nu={0} with correlation={1}".format(bestNu, bestCorrelation)
            break
        tryNu = tryNu + step

    return (bestNu, bestCorrelation)


def optimiseattrall():
    """optimise all attributes. TODO: move to optimise module."""
    print "optimiseattrall"
    query = "select stockname, bestnu, bestcost from " + common.dataminestocksViewName + \
        " where active=true and optimiseattr=true order by stockname asc"
    conn = common.getdbcon()
    cur = conn.cursor()
    cur.execute(query)
    for row in cur:
        optimiseattr(row[0], row[1])
    conn.close()
    print "finished all"


def optimiseattr(stockname, nu):
    """optimise attributes for one stock. TODO: move to optimise module."""
    print "Optimising attributes for {0}".format(stockname)
    if nu is None or nu == '':
        nu = common.svmNuDefault
        print "using default Nu ={0}".format(nu)

    extractdata = common.extractData(stockname)
    header = extractdata.splitlines()[0]
    hdrArray = header.split(",")
    hlen = len(hdrArray)
    print "array len={0}, class is last title={1}".format(hlen, hdrArray[hlen - 1])
    (bestError, bestCorr, bestAttrCsv) = common.lsCalcModel(stockname, "-", common.cv, extractdata, nu)
    bestExcludeCsv = ""
    trialExcludeCsv = ""
    delim = ""
    for colIdx in range(len(hdrArray) - 1):
        trialExcludeCsv = bestExcludeCsv + delim + "{0}".format(colIdx + 1)
        (trialError, trialCorr, trailAttrCsv) = common.lsCalcModel(stockname, trialExcludeCsv, common.cv,
                                                                   extractdata, nu)
        if trialCorr > bestCorr:
            print stockname + " found better correlation " + str(trialCorr)
            bestCorr = trialCorr
            bestError = trialError
            bestExcludeCsv = trialExcludeCsv
            bestAttrCsv = trailAttrCsv
            delim = ","

    print 'error=' + str(bestError) + ', corr=' + str(bestCorr)
    cmd = "psql -h localhost -U postgres -d postgres -c \"update dataminestocks_py set bestattributes='{0}', "
    "excludedattributes='{1}', bestCorrelation={2}, error={3} where stockname='{4}'\"".format(
        bestAttrCsv, bestExcludeCsv, bestCorr, bestError, stockname)
    res = subprocess.check_output(cmd, shell=True)
    print res + ". " + stockname + " stock optimisation finished"


def buildModels(runtype):
    """build models process."""
    print "buildModels"
    query = "select stockname, excludedattributes, bestcost, bestnu, gamma from " + \
        common.dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
    conn = common.getdbcon()
    cur = conn.cursor()

    cvArg = ''
    if runtype == 'cv':
        cvArg = common.cv
        print "only correlation calculation with crossvalidation = " + str(cvArg)
    elif runtype is None or runtype == '' or runtype == 'build':
        print "Building models, no correlation calculation"
    else:
        print "Allowed parameter for 'go bm' only 'cv' for correlation calculation with crossvalidation or empty "
        "for building models"
        sys.exit(99)

    curDate = conn.cursor()
    cur.execute(query)
    for row in cur:
        stockname = row[0]
        excludedattributes = row[1]
        bestcost = row[2]
        nu = row[3]
        gamma = row[4]
        extractdata = common.extractData(stockname)

        curDate.execute("select date FROM datamining_stocks_view where stockName='{0}' limit 1".format(stockname))
        for dateRow in curDate:
            date = str(dateRow[0])
            print 'date=' + date

        extraparam = ""
        if bestcost is not None:
            extraparam += " -c {0}".format(bestcost)

        if gamma is not None:
            extraparam += " -g {0}".format(gamma)

        (error, corr, attrCsv) = common.lsCalcModel(stockname, excludedattributes, cvArg, extractdata, nu, extraparam)

        if runtype == 'cv':
            curUp = conn.cursor()
            curUp.execute("update {0} set correlation=%s, error=%s, corrdate=%s where stockname=%s".format(
                common.dataminestocksViewName), (corr, error, date, stockname))
            print 'DB updated with corrdate="{0}"'.format(date)
            conn.commit()

    conn.close()
    print "finished all"


def doPredictions1():
    """deprecated predictions process for one date."""
    print "Predicting"
    query = "select stockname, excludedattributes, bestcost, bestnu from " + \
        common.dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
    conn = common.getdbcon()
    cur = conn.cursor()

    curDate = conn.cursor()
    cur.execute(query)
    for row in cur:

        stockname = row[0]
        excludedattributes = row[1]
#        bestcost = row[2]
        nu = row[3]
        extractdata = common.extractData(stockname, 0, 1)

        curDate.execute("select date FROM datamining_stocks_view where stockName='{0}' limit 1".format(stockname))
        records = curDate.fetchall()
        rec = records[0]
        date = str(rec[0])
#        print 'date='+date
        (prediction, trainres, errorres) = common.lsPredict(stockname, excludedattributes, extractdata, nu)
        curUp = conn.cursor()
        sql = "update {0} set prediction={1}, preddate={2} where stockname={3}".\
            format(common.dataminestocksViewName, prediction, date, stockname)
        print sql
        curUp.execute(sql)

    curUp.commit()
    conn.commit()
    conn.close()


def doPredictions():
    """multiple days predictions and reporting."""
    print "Predicting"
    query = "select stockname, excludedattributes, bestcost, bestnu from " + \
        common.dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
    conn = common.getdbcon()
    cur = conn.cursor()
    curUp = conn.cursor()
    cur.execute(query)

    for row in cur:
        stockname = row[0]
        excludedattributes = row[1]
#        bestcost = row[2]
        nu = row[3]

        sql = "COPY (SELECT * from datamine_extra('{0}') where date >= (now()::date - interval '7 days') )"\
            " TO STDOUT DELIMITER ',' CSV HEADER".format(stockname)
        print sql
        extracolsdata = subprocess.check_output(
            "export PGPASSWORD='postgres';psql -h localhost -U postgres -d postgres -c \"{0}\"".format(sql), shell=True)
        proc = subprocess.Popen("cut --complement -d, -f 1,2", shell=True,
                                stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        extractdata = proc.communicate(input=extracolsdata)[0]
#        print extractdata

        dateAr = []
        priceAr = []
        alldataAr = extracolsdata.splitlines()
        for i, val in enumerate(alldataAr):
            if i > 0:
                ar = val.split(",")
                dateAr.append(datetime.strptime(ar[0], "%Y-%m-%d").date())
                priceAr.append(float(ar[1]))

        print 'date array=' + str(dateAr)
        print 'price array=' + str(priceAr)
        (predictionAr, trainres, errorres) = common.lsPredictMulti(stockname, excludedattributes, extractdata, nu)
        print 'predictions array=' + str(predictionAr)
        curUp.execute("select updatePredictions(%s, %s, %s, %s)", (stockname, dateAr, priceAr, predictionAr))
        sql = "update {0} set prediction={1}, preddate='{2}' where stockname='{3}'".\
            format(common.dataminestocksViewName, priceAr[0], dateAr[0], stockname)
        curUp.execute(sql)

    conn.commit()

    # read predictions and email report
    cur.execute("select p.*, d.correlation, d.error from predictions p join "
                "dataminestocks_py d on d.stockname=p.stockname where rundate = now()::date "
                "order by correlation/error desc")
    records = cur.fetchall()
    rec = records[0]
    rundate = str(rec[0])
    tbls = "<table style='font-size:16px;font-family:Arial;border-collapse: collapse;border-spacing: 0;width: 100%;'>"
    tds = "<td style='border: 1px solid #ddd;text-align: left;padding: 8px;'>"
    trs = "<tr style='tr:nth-child(even){background-color: #f2f2f2}'>"
    ths = "<th style='padding-top: 11px;padding-bottom: 11px;background-color: #4CAF50;color: white;border: 1px solid"\
        + " #ddd;text-align: left;padding: 8px;'>"

#    style = ""
    msg = "<!DOCTYPE html><div><b>Predictions from run date " + rundate + "</b></div><div>\n"

    for row in records:
        stockname = row[1]
        datear = row[2]
        origprice = row[3]
        prediction = row[4]
        correlation = row[5]
        error = row[6]

        msg += "<div><br></br><br></br><b><span>" + stockname + ". Correlation=" + \
            str(correlation) + ", Error=" + str(error) + "</span></b></div><div>" + tbls + trs
        msg += "\n" + ths + "<span>Prediction record date</span></th>"
        msg += ths + "<span>Prediction for Date</span></th>" + ths + "<span>Original price</span></th>"
        msg += ths + "<span>Prediction %</span></th>" + ths + "<span>Predicted price</span></th>"
        msg += "\n</tr>\n"

        for i, val in enumerate(datear):
            msg += trs
            msg += tds + "<span>" + str(datear[i]) + "</span></td>\n"
            for_date = datear[i] + timedelta(days=7)
            msg += tds + "<span>" + str(for_date) + "</span></td>\n"
            msg += tds + "<span>" + str(origprice[i]) + "</span></td>\n"
            msg += tds + "<span>" + str(prediction[i]) + "</span></td>\n"
            msg += tds + "<span>" + str(origprice[i] * (1 + (prediction[i] / 100))) + "</span></td>\n"
            msg += "</tr>\n"

        msg += "</table></div>\n"

    msg += "</div>"

    text_file = open("./mail.html", "w")
    text_file.write(msg)
    text_file.close()

    cmd = "mail -a \"MIME-Version: 1.0\" -a \"Content-type: text/html\" -s \"SVM Results from " + \
        rundate + "\" ben@lvovsky.com < ./mail.html"
    print cmd
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (outputdata, errdata) = proc.communicate()

    print outputdata
    if errdata is not None:
        print errdata

    conn.close()


def main():
    """main entry."""
    if len(sys.argv) >= 2:
        timeStart = datetime.now()
        if sys.argv[1] == 'attr':
            optimiseattrall()
        elif sys.argv[1] == 'nu':
            optimiseNuAll()
        elif sys.argv[1] == 'bm':
            if len(sys.argv) < 3:
                par = 'build'
            else:
                par = sys.argv[2]
            buildModels(par)
        elif sys.argv[1] == 'pr':
            doPredictions()
        elif sys.argv[1] == 'downloaddata':
            downloadInstruments()
        elif sys.argv[1] == 'optgamma':
            optimise.optimiseAll(0.0001, 1, 0.1, "gamma", "-g")
        elif sys.argv[1] == 'optcost':
            optimise.optimiseAll(1, 1000, 10, "bestcost", "-c")

        timeEnd = datetime.now()
        print "Done, it took {0}".format(timeEnd - timeStart)

    else:
        print "Allowed commands: 'attr', 'bm [cv]', 'pr', 'downloaddata', 'nu', 'optgamma', 'optcost'"

if __name__ == "__main__":
    main()
