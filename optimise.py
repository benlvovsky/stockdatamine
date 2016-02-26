#!/usr/bin/env python
"""optimisation of any argument."""
import common


def optimiseAll(startPar, stopPar, stepPar, dbCol, paramOption):
    """loop requested stocks for optimisation."""
    print "optimisation of parameter '{0}'".format(paramOption)

    query = "select stockname, excludedattributes, bestnu, bestcost, gamma from {0} " \
        + "where active=true and excludedattributes is not NULL and " \
        + "excludedattributes<>'' and {1} is NULL order by stockname asc"
    query = query.format(common.dataminestocksViewName, dbCol)
    print "query=" + query

    conn = common.getdbcon()
    cur = conn.cursor()
    curUp = conn.cursor()
    cur.execute(query)

    for row in cur:
        curStep = stepPar
        curStart = startPar
        curStop = stopPar
        stockname = row[0]
        dataExtract = common.extractData(stockname)

        for i in range(0, 3):
            print "Trying: step {0}. curStart = {1}, curStop = {2}, curStep = {3}".format(i, curStart, curStop, curStep)
            (optParam, corr, error) = optimiseOne(paramOption, row, dataExtract, curStart, curStop, curStep)
            curStart = optParam - curStep  # 1 step earlier
            curStep = curStep / 10         # 10 times finer
            print "{0}-------------------- bestCorrelation={1}, error={2}".format(i, corr, error)
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
    bestCost = row[3]
    gamma = row[4]

    crossValNum = 5

    tryParam = start
    bestParam = tryParam
    extraParam = "{0} {1}".format(paramOption, tryParam)
    print "extraParam='{0}".format(extraParam)
    (trialError, trialCorrelation, trailAttrCsv) = common.lsCalcModel(
        stockname, exclAttribs, crossValNum, extractdata, bestNu, extraParam)

    print "Starting correlation={0}, with param={1}".format(trialCorrelation, bestParam)
    bestCorrelation = trialCorrelation
    bestError = trialError

    tryParam = start + step
    while tryParam < stop:
        # print "Trial {0}={1}".format(paramOption, tryParam)
        extraParam = "{0} {1}".format(paramOption, tryParam)

        if gamma is not None:
            extraParam += " -g {0}".format(gamma)

        if bestCost is not None:
            extraParam += " -c {0}".format(bestCost)

        print "extraParam='{0}".format(extraParam)
        (trialError, trialCorrelation, trailAttrCsv) = common.lsCalcModel(
            stockname, exclAttribs, crossValNum, extractdata, bestNu, extraParam)

        print "Result: correlation={0} error={3} for trial TrialParam = {1} with current bestCorrelation={2}".\
              format(trialCorrelation, tryParam, bestCorrelation, trialError)
        if trialCorrelation/trialError > bestCorrelation/bestError:
            bestCorrelation = trialCorrelation
            bestError = trialError
            bestParam = tryParam
            print "Found better correlation/error={1}/{2} with Param={0}".format(bestParam, bestCorrelation, bestError)
        else:
            print "Not better. Best parameter value = {0} with correlation={1}/{2}".\
                format(bestParam, bestCorrelation, bestError)
            break

        tryParam = tryParam + step
        print "tryParam={0}".format(tryParam)

    print "Result correlation/error={1}/{2} with Param={0}".format(bestParam, bestCorrelation, bestError)
    return (bestParam, bestCorrelation, bestError)
