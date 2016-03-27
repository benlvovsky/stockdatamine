"""common module for other modules."""

import os
import sys
import csv
import psycopg2
import subprocess
import cStringIO

svmCost = "100"
svmNuDefault = 0.556015
offset = 50
limit = 480
cv = 10
dataminestocksViewName = "dataminestocks_py"
startNu = 0.00000001
initialStepNu = 0.1

LSLIB = "libsvm-3.21"

os.environ['PGDATABASE'] = os.getenv('PGDATABASE', "postgres")
os.environ['PGHOST'] = os.getenv('PGHOST', "localhost")
os.environ['PGUSER'] = os.getenv('PGUSER', "postgres")
os.environ['PGPASSWORD'] = os.getenv('PGPASSWORD', "postgres")
os.environ['PGPORT'] = os.getenv('PGPORT', "5432")

def getdbcon():
    """staddartased DB connection."""
    return psycopg2.connect("dbname='{0}' user='{1}' host='{2}' password='{3}'".format(os.getenv('PGDATABASE'),
                            os.getenv('PGUSER'), os.getenv('PGHOST'), os.getenv('PGPASSWORD')))

def construct_line(label, line):
    """construct line for csv2libsvm format."""
    new_line = []
    if float(label) == 0.0:
        label = "0"
    new_line.append(label)

    for i, item in enumerate(line):
        if item == '' or float(item) == 0.0:
            continue
        new_item = "%s:%s" % (i + 1, item)
        new_line.append(new_item)
    new_line = " ".join(new_line)
    new_line += "\n"
    return new_line


def csv2libsvm(iStr, output_file, label_index, skip_headers):
    """convert csv to libsvm."""
    i = cStringIO.StringIO(iStr)
    o = open(output_file, 'wb')

    reader = csv.reader(i)

    if skip_headers:
        headers = reader.next()

    for line in reader:
        if label_index == -1:
            label = '1'
        else:
            label = line.pop(label_index)

        new_line = construct_line(label, line)
        o.write(new_line)

    o.close()
    i.close()


# calculate model with crossvalidating, saves into models/${1}.model
# used for building models mostly for calculation of best attributes and other parameters
def lsCalcModel(stockname, exclude, cvNum, data, nu=svmNuDefault, extraTrainParam=""):
    """calculate models."""
    #    print "stockname='{0}', cv='{1}', cost='{2}', excludeAttrs={3}".format(stockname, cvNum, svmCost, exclude)
    print "stockname='{0}', cv='{1}', cost='{2}', nu={3}, extraTrainParam='{4}'".\
        format(stockname, cvNum, svmCost, nu, extraTrainParam)
    svmNu = "{0}".format(nu)

    if (not cvNum) or (cvNum == ""):
        cvOption = ""
    else:
        cvOption = "-v {0}".format(cvNum)

    sys.stdout.write("cvOption=" + cvOption + ", len(data)={0}. ".format(len(data)))

    if (exclude is not None) and (exclude != "-") and (exclude != ""):
        cmd = "cut --complement -d, -f {0}".format(exclude)
    else:
        cmd = "cat"

#   sys.stdout.write(", cmd='{0}', ".format(cmd))
    proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    extractdata = proc.communicate(input=data)[0]

    header = extractdata.splitlines()[0]
    hdrArray = header.split(",")
    hlen = len(hdrArray)
    sys.stdout.write("array len={0}, class is last title={1}\n".format(hlen, hdrArray[hlen - 1]))
    csv2libsvm(extractdata, "extracts/{0}.ls".format(stockname), hlen - 1, True)

    cmd = LSLIB + '/svm-scale -s "extracts/{0}.range"  "extracts/{0}.ls" > "extracts/{0}.ls.scaled"'.format(stockname)
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        errdata = proc.communicate()[1]
#        if errdata != None:
#            print "" + errdata
    except:
        True
#    sys.stdout.write("...scaling finished\n")

    # setting cost option
    if "-c" not in extraTrainParam:
        costParam = "-c " + str(svmCost)
    else:
        costParam = ""

    if "-n" not in extraTrainParam:
        nuParam = "-n " + str(svmNu)
    else:
        nuParam = ""  # take from extraParam

    cmd = LSLIB + '/svm-train -s 4 -t 2 ' + costParam + ' ' + nuParam + ' ' + extraTrainParam + ' ' + \
        cvOption + ' extracts/{0}.ls.scaled models/{0}.ls.model'.format(stockname)
    sys.stdout.write("Training... command='" + cmd + "'\n")
    # sys.stdout.write("Training...")
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (trainres, errdata) = proc.communicate()
#   sys.stdout.write("Train output:\n" + trainres + '\n')
    try:
        if errdata is not None and len(errdata) > 0:
            print "        Train error: '" + errdata + "'"
    except:
        True
#    sys.stdout.write("...training finished\n")

    if cvOption != "":
        error = trainres.splitlines()[-2].split(" = ")[1]
        corr = trainres.splitlines()[-1].split(" = ")[1]
        print "Mean Squared Error='" + error + "'"
        print "Correlation=       '" + corr + "'"
    else:
        error = 0
        corr = 0

    return (float(error), float(corr), header)


def lsPredict(stockname, exclude, data):
    """do prediction process."""
    cmd = LSLIB + "/svm-predict extracts/{0}.ls.scaled models/{0}.ls.model models/{0}.ls.prediction".format(stockname)
    cmdScale = LSLIB + \
        '/svm-scale -r "extracts/{0}.range"  "extracts/{0}.ls" > "extracts/{0}.ls.scaled"'.format(stockname)
#    print "Command:"+cmd
    (odata, edata) = extractScaleRunCmd(stockname, exclude, data, cmd, cmdScale)
#    print "odata=:"+odata
    f = open("models/{0}.ls.prediction".format(stockname), "r")
    prStr = f.read()
    prFloat = float(prStr)
    print "prFloat={0}".format(prFloat)
#    sys.exit(99)
    return (prFloat, odata, edata)


def lsPredictMulti(stockname, exclude, data):
    """predict multiple dates."""
    cmd = LSLIB + "/svm-predict extracts/{0}.ls.scaled models/{0}.ls.model models/{0}.ls.prediction".format(stockname)
    cmdScale = LSLIB + \
        '/svm-scale -r "extracts/{0}.range"  "extracts/{0}.ls" > "extracts/{0}.ls.scaled"'.format(stockname)

    (odata, edata) = extractScaleRunCmd(stockname, exclude, data, cmd, cmdScale)
    f = open("models/{0}.ls.prediction".format(stockname), "r")
    prStr = f.read()
    fltAr = []
    for s in prStr.splitlines():
        fltAr.append(float(s))
        # print "pr={0}".format(s)
    return (fltAr, odata, edata)


def extractScaleRunCmd(stockname, exclude, data, cmdProc, cmdScale):
    """helper method combining several processes."""
    if (exclude is not None) and (exclude != "-") and (exclude != ""):
        cmd = "cut --complement -d, -f {0}".format(exclude)
    else:
        cmd = "cat"

    proc = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    extractdata = proc.communicate(input=data)[0]
    header = extractdata.splitlines()[0]
    hdrArray = header.split(",")
    hlen = len(hdrArray)
    sys.stdout.write("array len={0}, class is last title={1}\n".format(hlen, hdrArray[hlen - 1]))
    csv2libsvm(extractdata, "extracts/{0}.ls".format(stockname), hlen - 1, True)

    # scale
    proc = subprocess.Popen(cmdScale, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        errdata = proc.communicate()[1]
#        if errdata != None:
#            print "" + errdata
    except:
        True

    sys.stdout.write("Next command='" + cmdProc + "'\n")
    # process scaled data
    proc = subprocess.Popen(cmdProc, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (outputdata, errdata) = proc.communicate()
    try:
        if errdata is not None and len(errdata) > 0:
            print "Error: {" + errdata + "}"
    except:
        True

    return (outputdata, errdata)


def extractData(stockname, offsetPar=offset, limitPar=limit):
    """extract DB Data as CSV into STDOUT with header."""
    sql = "COPY (SELECT * from datamine1('{0}') offset {1} limit {2}) TO STDOUT DELIMITER ',' CSV HEADER".format(
        stockname, offsetPar, limitPar)
    extractdata = subprocess.check_output(psqlCommand(sql), shell=True)
    return extractdata


def psqlCommand(sql):
    """psql command line to execute using global parameters."""
    return "psql -c \"{0}\"".format(sql)
