"""module for predictions functionalities ."""

import common
import subprocess
from datetime import datetime

def doPredictionsAccuracy():
    """multiple days predictions with accuracy."""
    print "Predicting with accuracy"
    query = "select stockname, excludedattributes, bestcost, bestnu from " + \
        common.dataminestocksViewName + " where active=true and topredict=true order by stockname asc"
    conn = common.getdbcon()
    cur = conn.cursor()
    cur.execute(query)

    for row in cur:
        stockname = row[0]
        excludedattributes = row[1]

        sql = "COPY (SELECT * from datamine_extra('{0}') order by date desc offset 480 limit 10)"\
              " TO STDOUT DELIMITER ',' CSV HEADER".format(stockname)

        extracolsdata = subprocess.check_output(
            "export PGPASSWORD='postgres';psql -h localhost -U postgres -d postgres -c \"{0}\"".format(sql), shell=True)
        proc = subprocess.Popen("cut --complement -d, -f 1,2", shell=True,
                                stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        extractdata = proc.communicate(input=extracolsdata)[0]

        dateAr = []
        priceAr = []
        alldataAr = extracolsdata.splitlines()
        for i, val in enumerate(alldataAr):
            if i > 0:
                ar = val.split(",")
                dateAr.append(datetime.strptime(ar[0], "%Y-%m-%d").date())
                priceAr.append(float(ar[1]))

        (predictionAr, output, errorres) = common.lsPredictMulti(stockname, excludedattributes, extractdata)
        error = output.splitlines()[-2].split(" = ")[1]
        corr = output.splitlines()[-1].split(" = ")[1]
        print stockname + ": Mean Squared Error=" + error + ", Squared correlation coefficient=" + corr
