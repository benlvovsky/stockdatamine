#!/usr/bin/env python

import v2.v2ops as v2ops
import tradeindicators as ti
from common import *
from downloaddata import *

availableCommands = """Allowed commands:
   'attr':                                for attributes optimization                                       
   'nu':                                  for nu optimization                                               
   'bm [cv]':                             to build models                                                   
   'pr':                                  for predictions                                                   
   'downloaddata':                        to download data                                                  
   'syncaggr':                            to synchronize averages for past 3 years                          
                                           - usually to prime DB after first download                       

   'v2' <symbol>:                         v2 functions                                                      
   'v2GammaCost <symbol> [isBF=False]':   calculate Gamma and Cost and save to DB. 'Set isBF to 'True'      
                                               to use pre-calculated Best Features from DB                  
   'v2FitAndSave <symbolCSV>':            fit and save serialized estimator into DB                         
   'v2Features <symbol>':                 exclude noisy features and save to DB                             
   'v2TestPerf <symbol>':                 test performance of symbol with previously calculated parameters
   'v2Predict <symbolCSV> <offset=0>':    predict, can specify offset for 'back to future' predict
   
   The work flow would normally be like:
       1. v2GammaCost on all features
       2. v2Features
       3. v2FitAndSave on best features
       4. v2TestPerf (optional)
       5. v2Predict
   """

def optimiseNuAll():
    print "optimiseNu"
    query = "select stockname, excludedattributes from " + dataminestocksViewName +\
        " where active=true and excludedattributes is not NULL and excludedattributes<>'' and bestnu is NULL order by stockname asc"
    conn = getdbcon()
    cur = conn.cursor()
    curUp = conn.cursor()
    cur.execute(query)
    for row in cur:
        stockname = row[0]
        excludedattributes = row[1]
        extractdata = extractData(stockname)
        (nu, corr) = optimiseNu(stockname, excludedattributes, extractdata, startNu, 1, 0.1)
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
            dataminestocksViewName, nu - startNu, corr, stockname))
#        sys.exit()

    conn.commit()
    conn.close()
    print "finished all"


def commonForOptimise(optimiseFunc, startPar, stopPar, stepPar, updFld):
    query = "select stockname, excludedattributes from " + dataminestocksViewName + \
        " where active=true and excludedattributes is not NULL and excludedattributes<>'' and bestnu is NULL order by stockname asc"
    conn = getdbcon()
    cur = conn.cursor()
    curUp = conn.cursor()
    cur.execute(query)
    for row in cur:
        stockname = row[0]
        excludedattributes = row[1]
        extractdata = extractData(stockname)
        (nu, corr) = optimiseFunc(stockname, excludedattributes, extractdata, startPar, stopPar, stepPar)
        print "1---------------------------------------------"
        (nu, corr) = optimiseFunc(stockname, excludedattributes, extractdata, nu - 0.1, 1, 0.01)
        print "2---------------------------------------------"
        (nu, corr) = optimiseFunc(stockname, excludedattributes, extractdata, nu - 0.01, 1, 0.001)
        print "3---------------------------------------------"
        (nu, corr) = optimiseFunc(stockname, excludedattributes, extractdata, nu - 0.001, 1, 0.0001)
        curUp.execute("update {0} set {4}={1}, bestCorrelation={2} where stockname='{3}'".format(
            dataminestocksViewName, nu - startNu, corr, stockname, updFld))

    conn.commit()
    conn.close()
    print "finished all"


def optimiseNu(stockname, excludedattributes, extractdata, start, stop, step):
    print "Stock " + stockname

    tryNu = start
    bestNu = tryNu
    (trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(stockname, excludedattributes, cv, extractdata, tryNu)
    print "Starting correlation={0}, with nu={1}".format(trialCorrelation, bestNu)
    bestCorrelation = trialCorrelation

    tryNu = start + step
    while tryNu < stop:
        print "Trial Nu={0}".format(tryNu)
        (trialError, trialCorrelation, trailAttrCsv) = lsCalcModel(
            stockname, excludedattributes, cv, extractdata, tryNu)
        print "Result: correlation={0} for trial Nu={1} with current bestCorrelation={2}".format(trialCorrelation, tryNu, bestCorrelation)
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
    print "optimiseattrall"
    query = "select stockname, bestnu, bestcost from " + dataminestocksViewName + \
        " where active=true and optimiseattr=true order by stockname asc"
    conn = getdbcon()
    cur = conn.cursor()
    cur.execute(query)
    for row in cur:
        optimiseattr(row[0], row[1])
    conn.close()
    print "finished all"


def optimiseattr(stockname, nu):
    print "Optimising attributes for {0}".format(stockname)
    if nu is None or nu == '':
        nu = common.svmNuDefault
        print "using default Nu ={0}".format(nu)

    extractdata = extractData(stockname)
#     print "extracrdata={0}".format(extractdata)
    header = extractdata.splitlines()[0]
    hdrArray = header.split(",")
    hlen = len(hdrArray)
    print "array len={0}, class is last title={1}".format(hlen, hdrArray[hlen - 1])
    (bestError, bestCorr, bestAttrCsv) = lsCalcModel(stockname, "-", cv, extractdata, nu)
    bestExcludeCsv = ""
    trialExcludeCsv = ""
    delim = ""
    for colIdx in range(len(hdrArray) - 1):
        trialExcludeCsv = bestExcludeCsv + delim + "{0}".format(colIdx + 1)
        (trialError, trialCorr, trailAttrCsv) = lsCalcModel(stockname, trialExcludeCsv, cv, extractdata, nu)
        if trialCorr > bestCorr:
            print stockname + " found better correlation " + str(trialCorr)
            bestCorr = trialCorr
            bestError = trialError
            bestExcludeCsv = trialExcludeCsv
            bestAttrCsv = trailAttrCsv
            delim = ","

    print 'error=' + str(bestError) + ', corr=' + str(bestCorr)
    cmd = "psql -U postgres -d postgres -c \"update dataminestocks_py set bestattributes='{0}', excludedattributes='{1}', bestCorrelation={2}, error={3} where stockname='{4}'\"" \
        .format(bestAttrCsv, bestExcludeCsv, bestCorr, bestError, stockname)
    res = subprocess.check_output(cmd, shell=True)
    print res + ". " + stockname + " stock optimisation finished"


def buildModels(runtype):
    print "buildModels"
    query = "select stockname, excludedattributes, bestcost, bestnu from " + \
        dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
    conn = getdbcon()
    cur = conn.cursor()

    cvArg = ''
    if runtype == 'cv':
        cvArg = cv
        print "only correlation calculation with crossvalidation = " + str(cv)
    elif runtype is None or runtype == '' or runtype == 'build':
        print "Building models, no correlation calculation"
    else:
        print "Allowed parameter for 'go bm' only 'cv' for correlation calculation with crossvalidation or empty for building models"
        sys.exit(99)

    curDate = conn.cursor()
    cur.execute(query)
    for row in cur:

        stockname = row[0]
        excludedattributes = row[1]
        bestcost = row[2]
        nu = row[3]
        extractdata = extractData(stockname)

        curDate.execute("select date FROM datamining_stocks_view where stockName='{0}' limit 1".format(stockname))
        for dateRow in curDate:
            date = str(dateRow[0])
            print 'date=' + date

        (error, corr, attrCsv) = lsCalcModel(stockname, excludedattributes, cvArg, extractdata, nu)

        if runtype == 'cv':
            curUp = conn.cursor()
            curUp.execute("update {0} set correlation=%s, error=%s, corrdate=%s where stockname=%s".format(
                dataminestocksViewName), (corr, error, date, stockname))
            print 'DB updated with corrdate="{0}"'.format(date)
            conn.commit()

    conn.close()
    print "finished all"


def doPredictions1():
    print "Predicting"
    query = "select stockname, excludedattributes, bestcost, bestnu from " + \
        dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
    conn = getdbcon()
    cur = conn.cursor()

    curDate = conn.cursor()
    cur.execute(query)
    for row in cur:

        stockname = row[0]
        excludedattributes = row[1]
#        bestcost = row[2]
        nu = row[3]
        extractdata = extractData(stockname, 0, 1)

        curDate.execute("select date FROM datamining_stocks_view where stockName='{0}' limit 1".format(stockname))
        records = curDate.fetchall()
        rec = records[0]
        date = str(rec[0])
#        print 'date='+date
        (prediction, trainres, errorres) = lsPredict(stockname, excludedattributes, extractdata, nu)
        curUp = conn.cursor()
        sql = "update {0} set prediction={1}, preddate={2} where stockname={3}".\
            format(dataminestocksViewName, prediction, date, stockname)
        print sql
        curUp.execute(sql)

    curUp.commit()
    conn.commit()
    conn.close()


def doPredictions():
    print "Predicting"
    query = "select stockname, excludedattributes, bestcost, bestnu from " + \
        dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
    conn = getdbcon()
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
            "export PGPASSWORD='postgres';psql -U postgres -d postgres -c \"{0}\"".format(sql), shell=True)
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
        (predictionAr, trainres, errorres) = lsPredictMulti(stockname, excludedattributes, extractdata, nu)
        print 'predictions array=' + str(predictionAr)
        curUp.execute("select updatePredictions(%s, %s, %s, %s)", (stockname, dateAr, priceAr, predictionAr))
        sql = "update {0} set prediction={1}, preddate='{2}' where stockname='{3}'".\
            format(dataminestocksViewName, priceAr[0], dateAr[0], stockname)
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
    ths = "<th style='padding-top: 11px;padding-bottom: 11px;background-color: #4CAF50;color: white;border: 1px solid #ddd;text-align: left;padding: 8px;'>"

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
    if errdata != None:
        print errdata

    conn.close()

def syncaggr():
    print "synchronizing averages for 3 years"
    sql = "select sync_aggr((now() - interval '3 years')::date)"
    extracolsdata = subprocess.check_output(
            "export PGPASSWORD='postgres';psql -U postgres -d postgres -c \"{0}\"".format(sql), shell=True)

def getDefaultArg(argNum, dflt):
    if len(sys.argv) < argNum + 1:
        par = dflt
#         print 'As argument number {0} was not supplied the default \'{1}\' is used'.format(argNum, dflt)
    else:
        par = sys.argv[argNum]
    return par;

def main():
    global availableCommands

    if os.environ.get('PGHOST') is None:
        os.environ['PGHOST'] = PGHOST # visible in this process + all children

#     print 'PGHOST={0}'.format(os.environ.get('PGHOST'))
    v2ops.init()

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
        elif sys.argv[1] == 'upload':
            uploadInvestorDotComDataToDb()
        elif sys.argv[1] == 'syncaggr':
            syncaggr()
        elif sys.argv[1] == 'v2':
            v2ops.v2analysis(getDefaultArg(2, '^AORD'))
        elif sys.argv[1] == 'v2GammaCost':
            v2ops.gammaCostCalc(getDefaultArg(2, '^AORD'), getDefaultArg(3, 'False') == 'True')
        elif sys.argv[1] == 'v2Features':
            v2ops.optimiseFeautures(getDefaultArg(2, '^AORD'))
        elif sys.argv[1] == 'v2TestPerf':
            v2ops.testPerformance(getDefaultArg(2, '^AORD'))
        elif sys.argv[1] == 'v2FitAndSave':
            v2ops.fitAndSave(getDefaultArg(2, '^AORD'), getDefaultArg(3, 'True') == 'True')
        elif sys.argv[1] == 'v2Predict':
            v2ops.predict(getDefaultArg(2, '^AORD'), getDefaultArg(3, '0'))
        elif sys.argv[1] == 'v2mvc':
            (colNames, X_allDataSet, y_allPredictions, dateList) = ti.loadDataSet('^AORD', False, 30, 2000)
            print colNames, X_allDataSet, y_allPredictions, dateList
        else:
            print "There is no command '{0}'\n{1}".format(sys.argv[1], availableCommands)

        timeEnd = datetime.now()
        print "Done, it took {0}".format(timeEnd - timeStart)

    else:
        print availableCommands
        
if __name__ == "__main__":
    main()
