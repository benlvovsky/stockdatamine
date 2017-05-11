#!/usr/bin/env python
"""optimisation of any argument."""
import common


def genOptimiseAll(startPar, stopPar, stepPar, dbCol, paramOption):
    """loop requested stocks for optimisation."""
    print "optimisation of parameter '{0}'".format(paramOption)

    query = "select stockname, excludedattributes, bestnu from {0} "
    "where active=true and excludedattributes is not NULL and "
    "excludedattributes<>'' and {1} is NULL order by stockname asc".format(common.dataminestocksViewName, dbCol)

    conn = common.getdbcon()
    cur = conn.cursor()
    curUp = conn.cursor()
    cur.execute(query)
    curStep = stepPar
    curStart = startPar
    curStop = stopPar

    for row in cur:
        stockname = row[0]
        dataExtract = common.extractData(stockname)

        for i in range(0, 4):
            print "Trying: step {0}. curStart = {1}, curStop = {2}, curStep = {3}".format(i, curStart, curStop, curStep)
            (optParam, corr) = optimiseOne(paramOption, row, dataExtract, curStart, curStop, curStep)
            curStart = optParam - curStep  # 1 step earlier
            curStep = curStep / 10         # 10 times finer

        curUp.execute("update {0} set {4}={1}, bestCorrelation={2} where stockname='{3}'".
                      format(common.dataminestocksViewName, curStart, corr, stockname, dbCol))

    conn.commit()
    conn.close()
    print "optimisation finished"


def optimiseOne(paramOption, row, extractdata, start, stop, step):
    """optimisation for 1 Stock."""
    stockname = row[0]
    exclAttribs = row[1]
    bestNu = row[2]

    tryParam = start
    bestParam = tryParam
    (trialError, trialCorrelation, trailAttrCsv) = common.lsCalcModel(
        stockname, exclAttribs, common.cv, extractdata, bestNu, "{0} {1}".format(paramOption, tryParam))

    print "Starting correlation={0}, with param={1}".format(trialCorrelation, bestParam)
    bestCorrelation = trialCorrelation

    tryParam = start + step
    while tryParam < stop:
        print "Trial {0}={1}".format(paramOption, tryParam)
        (trialError, trialCorrelation, trailAttrCsv) = common.lsCalcModel(
            stockname, exclAttribs, common.cv, extractdata, tryParam)
        print "Result: correlation={0} for trial Nu={1} with current bestCorrelation={2}".\
              format(trialCorrelation, tryParam, bestCorrelation)
        if trialCorrelation >= bestCorrelation:
            bestCorrelation = trialCorrelation
            bestParam = tryParam
            print "Found better or same correlation=" + str(bestCorrelation) + " with Nu={0}".format(bestParam)
        else:
            print "Not better. Best parameter value = {0} with correlation={1}".format(bestParam, bestCorrelation)
            break

        tryParam = tryParam + step

    return (bestParam, bestCorrelation)
