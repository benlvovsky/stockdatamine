
-- View: public.datamining_aggr_view
DROP VIEW v2.datamining_aggr_view;

CREATE OR REPLACE VIEW v2.datamining_aggr_view AS
 SELECT s.date,
    s.stock AS instrument,
    v2.chngDiv(s.stock,  s.date, '1 day') AS instrDaily,    v2.chngDiv(s.stock,  s.date, '1 week') AS instrWeekly,    v2.chngDiv(s.stock,  s.date, '1 month') AS instrMonthly,
    v2.chngDiv('^AORD',  s.date, '1 day') AS aordDaily,     v2.chngDiv('^AORD',  s.date, '1 week') AS aordWeekly,     v2.chngDiv('^AORD',  s.date, '1 month') AS aordMonthly,
    v2.chngDiv('^N225',  s.date, '1 day') AS n225Daily,     v2.chngDiv('^N225',  s.date, '1 week') AS n225Weekly,     v2.chngDiv('^N225',  s.date, '1 month') AS n225Monthly,
    v2.chngDiv('^NDX',   s.date, '1 day') AS ndxDaily,      v2.chngDiv('^NDX',   s.date, '1 week') AS ndxWeekly,      v2.chngDiv('^NDX',   s.date, '1 month') AS ndxMonthly,
--    v2.chngDiv('^DJI',   s.date, '1 day') AS djiDaily,      v2.chngDiv('^DJI',   s.date, '1 week') AS djiWeekly,      v2.chngDiv('^DJI',   s.date, '1 month') AS djiMonthly,
--    v2.chngDiv('^FTSE',  s.date, '1 day') AS ftseDaily,     v2.chngDiv('^FTSE',  s.date, '1 week') AS ftseWeekly,     v2.chngDiv('^FTSE',  s.date, '1 month') AS ftseMonthly,
    v2.chngDiv('^GDAXI', s.date, '1 day') AS gdaxiDaily,    v2.chngDiv('^GDAXI', s.date, '1 week') AS gdaxiWeekly,    v2.chngDiv('^GDAXI', s.date, '1 month') AS gdaxiMonthly,
    v2.chngDiv('^SSEC',  s.date, '1 day') AS ssecDaily,     v2.chngDiv('^SSEC',  s.date, '1 week') AS ssecWeekly,     v2.chngDiv('^SSEC',  s.date, '1 month') AS ssecMonthly,
    v2.chngDiv('^HSI',   s.date, '1 day') AS hsiDaily,      v2.chngDiv('^HSI',   s.date, '1 week') AS hsiWeekly,      v2.chngDiv('^HSI',   s.date, '1 month') AS hsiMonthly,
    v2.chngDiv('^BSESN', s.date, '1 day') AS bsesnDaily,    v2.chngDiv('^BSESN', s.date, '1 week') AS bsesnWeekly,    v2.chngDiv('^BSESN', s.date, '1 month') AS bsesnMonthly,
    v2.chngDiv('^JKSE',  s.date, '1 day') AS jkseDaily,     v2.chngDiv('^JKSE',  s.date, '1 week') AS jkseWeekly,     v2.chngDiv('^JKSE',  s.date, '1 month') AS jkseMonthly,
    v2.chngDiv('^KLSE',  s.date, '1 day') AS klseDaily,     v2.chngDiv('^KLSE',  s.date, '1 week') AS klseWeekly,     v2.chngDiv('^KLSE',  s.date, '1 month') AS klseMonthly,
    v2.chngDiv('^NZ50',  s.date, '1 day') AS nz50Daily,     v2.chngDiv('^NZ50',  s.date, '1 week') AS nz50Weekly,     v2.chngDiv('^NZ50',  s.date, '1 month') AS nz50Monthly,
    v2.chngDiv('^STI',   s.date, '1 day') AS stiDaily,      v2.chngDiv('^STI',   s.date, '1 week') AS stiWeekly,      v2.chngDiv('^STI',   s.date, '1 month') AS stiMonthly,
    v2.chngDiv('^KS11',  s.date, '1 day') AS ks11Daily,     v2.chngDiv('^KS11',  s.date, '1 week') AS ks11Weekly,     v2.chngDiv('^KS11',  s.date, '1 month') AS ks11Monthly,
    v2.chngDiv('^TWII',  s.date, '1 day') AS twiiDaily,     v2.chngDiv('^TWII',  s.date, '1 week') AS twiiWeekly,     v2.chngDiv('^TWII',  s.date, '1 month') AS twiiMonthly,
    v2.chngDiv('^BVSP',  s.date, '1 day') AS bvspDaily,     v2.chngDiv('^BVSP',  s.date, '1 week') AS bvspWeekly,     v2.chngDiv('^BVSP',  s.date, '1 month') AS bvspMonthly,
    v2.chngDiv('^GSPTSE',s.date, '1 day') AS gsptseDaily,   v2.chngDiv('^GSPTSE',s.date, '1 week') AS gsptseWeekly,   v2.chngDiv('^GSPTSE',s.date, '1 month') AS gsptseMonthly,
    v2.chngDiv('^MXX',   s.date, '1 day') AS mxxDaily,      v2.chngDiv('^MXX',   s.date, '1 week') AS mxxWeekly,      v2.chngDiv('^MXX',   s.date, '1 month') AS mxxMonthly,
    v2.chngDiv('^GSPC',  s.date, '1 day') AS gspcDaily,     v2.chngDiv('^GSPC',  s.date, '1 week') AS gspcWeekly,     v2.chngDiv('^GSPC',  s.date, '1 month') AS gspcMonthly,
    v2.chngDiv('^ATX',   s.date, '1 day') AS atxDaily,      v2.chngDiv('^ATX',   s.date, '1 week') AS atxWeekly,      v2.chngDiv('^ATX',   s.date, '1 month') AS atxMonthly,
    v2.chngDiv('^BFX',   s.date, '1 day') AS bfxDaily,      v2.chngDiv('^BFX',   s.date, '1 week') AS bfxWeekly,      v2.chngDiv('^BFX',   s.date, '1 month') AS bfxMonthly,
    v2.chngDiv('^FCHI',  s.date, '1 day') AS fchiDaily,     v2.chngDiv('^FCHI',  s.date, '1 week') AS fchiWeekly,     v2.chngDiv('^FCHI',  s.date, '1 month') AS fchiMonthly,
    v2.chngDiv('^OSEAX', s.date, '1 day') AS oseaxDaily,    v2.chngDiv('^OSEAX', s.date, '1 week') AS oseaxWeekly,    v2.chngDiv('^OSEAX', s.date, '1 month') AS oseaxMonthly,
    v2.chngDiv('^OMXSPI',s.date, '1 day') AS omxspiDaily,   v2.chngDiv('^OMXSPI',s.date, '1 week') AS omxspiWeekly,   v2.chngDiv('^OMXSPI',s.date, '1 month') AS omxspiMonthly,
--    v2.chngDiv('^SSMI',  s.date, '1 day') AS ssmiDaily,     v2.chngDiv('^SSMI',  s.date, '1 week') AS ssmiWeekly,     v2.chngDiv('^SSMI',  s.date, '1 month') AS ssmiMonthly,
--    v2.chngDiv('GD.AT',  s.date, '1 day') AS gdDaily,       v2.chngDiv('GD.AT',  s.date, '1 week') AS gdWeekly,       v2.chngDiv('GD.AT',  s.date, '1 month') AS gdMonthly,

    v2.chngDiv('FXA',    s.date, '1 day') AS fxaDaily,      v2.chngDiv('FXA',    s.date, '1 week') AS fxaWeekly,      v2.chngDiv('FXA',    s.date, '1 month') AS fxaMonthly,
    v2.chngDiv('FXB',    s.date, '1 day') AS fxbDaily,      v2.chngDiv('FXB',    s.date, '1 week') AS fxbWeekly,      v2.chngDiv('FXB',    s.date, '1 month') AS fxbMonthly,
    v2.chngDiv('FXC',    s.date, '1 day') AS fxcDaily,      v2.chngDiv('FXC',    s.date, '1 week') AS fxcWeekly,      v2.chngDiv('FXC',    s.date, '1 month') AS fxcMonthly,
    v2.chngDiv('FXE',    s.date, '1 day') AS fxeDaily,      v2.chngDiv('FXE',    s.date, '1 week') AS fxeWeekly,      v2.chngDiv('FXE',    s.date, '1 month') AS fxeMonthly,
    v2.chngDiv('FXF',    s.date, '1 day') AS fxfDaily,      v2.chngDiv('FXF',    s.date, '1 week') AS fxfWeekly,      v2.chngDiv('FXF',    s.date, '1 month') AS fxfMonthly,
    v2.chngDiv('FXS',    s.date, '1 day') AS fxsDaily,      v2.chngDiv('FXS',    s.date, '1 week') AS fxsWeekly,      v2.chngDiv('FXS',    s.date, '1 month') AS fxsMonthly,
    v2.chngDiv('FXY',    s.date, '1 day') AS fxyDaily,      v2.chngDiv('FXY',    s.date, '1 week') AS fxyWeekly,      v2.chngDiv('FXY',    s.date, '1 month') AS fxyMonthly,

    v2.chngDiv('CHOC',   s.date, '1 day') AS cmdChocDaily,  v2.chngDiv('CHOC',   s.date, '1 week') AS cmdChocWeekly,  v2.chngDiv('CHOC',   s.date, '1 month') AS cmdChocMonthly,
    v2.chngDiv('CORN',   s.date, '1 day') AS cmdCornDaily,  v2.chngDiv('CORN',   s.date, '1 week') AS cmdCornWeekly,  v2.chngDiv('CORN',   s.date, '1 month') AS cmdCornMonthly,
    v2.chngDiv('CTNN',   s.date, '1 day') AS cmdCtnnDaily,  v2.chngDiv('CTNN',   s.date, '1 week') AS cmdCtnnWeekly,  v2.chngDiv('CTNN',   s.date, '1 month') AS cmdCtnnMonthly,
    v2.chngDiv('CUPM',   s.date, '1 day') AS cmdCupmDaily,  v2.chngDiv('CUPM',   s.date, '1 week') AS cmdCupmWeekly,  v2.chngDiv('CUPM',   s.date, '1 month') AS cmdCupmMonthly,
    v2.chngDiv('FOIL',   s.date, '1 day') AS cmdFoilDaīly,  v2.chngDiv('FOIL',   s.date, '1 week') AS cmdFoilWeekly,  v2.chngDiv('FOIL',   s.date, '1 month') AS cmdFoilMonthly,
    v2.chngDiv('GAZ',    s.date, '1 day') AS cmdGazDaily,   v2.chngDiv('GAZ',    s.date, '1 week') AS cmdGazWeekly,   v2.chngDiv('GAZ',    s.date, '1 month') AS cmdGazMonthly,
    v2.chngDiv('GLD',    s.date, '1 day') AS cmdGldDaily,   v2.chngDiv('GLD',    s.date, '1 week') AS cmdGldWeekly,   v2.chngDiv('GLD',    s.date, '1 month') AS cmdGldMonthly,
    v2.chngDiv('HEVY',   s.date, '1 day') AS cmdHevyDaily,  v2.chngDiv('HEVY',   s.date, '1 week') AS cmdHevyWeekly,  v2.chngDiv('HEVY',   s.date, '1 month') AS cmdHevyMonthly,
    v2.chngDiv('LEDD',   s.date, '1 day') AS cmdLeddDaily,  v2.chngDiv('LEDD',   s.date, '1 week') AS cmdLeddWeekly,  v2.chngDiv('LEDD',   s.date, '1 month') AS cmdLeddMonthly,
    v2.chngDiv('LSTK',   s.date, '1 day') AS cmdLstkDaily,  v2.chngDiv('LSTK',   s.date, '1 week') AS cmdLstkWeekly,  v2.chngDiv('LSTK',   s.date, '1 month') AS cmdLstkMonthly,
    v2.chngDiv('NINI',   s.date, '1 day') AS cmdNiniDaily,  v2.chngDiv('NINI',   s.date, '1 week') AS cmdNiniWeekly,  v2.chngDiv('NINI',   s.date, '1 month') AS cmdNiniMonthly,
    v2.chngDiv('OIL',    s.date, '1 day') AS cmdOilDaily,   v2.chngDiv('OIL',    s.date, '1 week') AS cmdOilWeekly,   v2.chngDiv('OIL',    s.date, '1 month') AS cmdOilMonthly,
    v2.chngDiv('PALL',   s.date, '1 day') AS cmdPallDaily,  v2.chngDiv('PALL',   s.date, '1 week') AS cmdPallWeekly,  v2.chngDiv('PALL',   s.date, '1 month') AS cmdPallMonthly,
    v2.chngDiv('PPLT',   s.date, '1 day') AS cmdPpltDaily,  v2.chngDiv('PPLT',   s.date, '1 week') AS cmdPpltWeekly,  v2.chngDiv('PPLT',   s.date, '1 month') AS cmdPpltMonthly,
    v2.chngDiv('SGAR',   s.date, '1 day') AS cmdSgarDaily,  v2.chngDiv('SGAR',   s.date, '1 week') AS cmdSgarWeekly,  v2.chngDiv('SGAR',   s.date, '1 month') AS cmdSgarMonthly,
    v2.chngDiv('SLV',    s.date, '1 day') AS cmdSlvDaily,   v2.chngDiv('SLV',    s.date, '1 week') AS cmdSlvWeekly,   v2.chngDiv('SLV',    s.date, '1 month') AS cmdSlvMonthly,
    v2.chngDiv('SOYB',   s.date, '1 day') AS cmdSoybDaily,  v2.chngDiv('SOYB',   s.date, '1 week') AS cmdSoybWeekly,  v2.chngDiv('SOYB',   s.date, '1 month') AS cmdSoybMonthly,
    v2.chngDiv('UHN',    s.date, '1 day') AS cmdUhnDaily,   v2.chngDiv('UHN',    s.date, '1 week') AS cmdUhnWeekly,   v2.chngDiv('UHN',    s.date, '1 month') AS cmdUhnMonthly,
    v2.chngDivFuture(s.stock,  s.date, '1 month') AS prediction
   FROM stocks s
     JOIN v2.instrumentsprops d ON d.stockname = s.stock
  WHERE d.active = true
  ORDER BY s.stock, s.date DESC;

ALTER TABLE v2.datamining_aggr_view
    OWNER TO postgres;

INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXDJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXSJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXEJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXFJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXXJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXHJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXNJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXIJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXMJ', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXMM', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXJR', 'YAHOO');
INSERT INTO v2.downloadinstruments(instrument, type) VALUES ('^AXUJ', 'YAHOO');

INSERT INTO v2.instrumentsprops(symbol, active) select '^AXDJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXDJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXSJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXSJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXEJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXEJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXFJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXFJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXXJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXXJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXHJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXHJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXNJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXNJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXIJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXIJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXMJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXMJ');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXMM', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXMM');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXJR', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXJR');
INSERT INTO v2.instrumentsprops(symbol, active) select '^AXUJ', true where not exists (select symbol from v2.instrumentsprops where symbol='^AXUJ');

./go.py v2GammaCost ^AXDJ False
./go.py v2GammaCost ^AXSJ False
./go.py v2GammaCost ^AXEJ False
./go.py v2GammaCost ^AXFJ False
./go.py v2GammaCost ^AXXJ False
./go.py v2GammaCost ^AXHJ False
./go.py v2GammaCost ^AXNJ False
./go.py v2GammaCost ^AXIJ False
./go.py v2GammaCost ^AXMJ False
./go.py v2GammaCost ^AXMM False
./go.py v2GammaCost ^AXJR False
./go.py v2GammaCost ^AXUJ False

./go.py v2Features ^AXDJ
./go.py v2Features ^AXSJ
./go.py v2Features ^AXEJ
./go.py v2Features ^AXFJ
./go.py v2Features ^AXXJ
./go.py v2Features ^AXHJ
./go.py v2Features ^AXNJ
./go.py v2Features ^AXIJ
./go.py v2Features ^AXMJ
./go.py v2Features ^AXMM
./go.py v2Features ^AXJR
./go.py v2Features ^AXUJ

./go.py v2GammaCost ^AXDJ True
./go.py v2GammaCost ^AXSJ True
./go.py v2GammaCost ^AXEJ True
./go.py v2GammaCost ^AXFJ True
./go.py v2GammaCost ^AXXJ True
./go.py v2GammaCost ^AXHJ True
./go.py v2GammaCost ^AXNJ True
./go.py v2GammaCost ^AXIJ True
./go.py v2GammaCost ^AXMJ True
#./go.py v2GammaCost ^AXMM True
./go.py v2GammaCost ^AXJR True
./go.py v2GammaCost ^AXUJ True

./go.py v2TestPerf ^AXDJ
./go.py v2TestPerf ^AXSJ
./go.py v2TestPerf ^AXEJ
./go.py v2TestPerf ^AXFJ
./go.py v2TestPerf ^AXXJ
./go.py v2TestPerf ^AXHJ
./go.py v2TestPerf ^AXNJ
./go.py v2TestPerf ^AXIJ
./go.py v2TestPerf ^AXMJ
#./go.py v2TestPerf ^AXMM
./go.py v2TestPerf ^AXJR
./go.py v2TestPerf ^AXUJ

./go.py v2FitAndSave ^AORD,^AXDJ,^AXSJ,^AXEJ,^AXFJ,^AXXJ,^AXHJ,^AXNJ,^AXIJ,^AXMJ,^AXJR,^AXUJ True
./go.py v2GammaCost  ^AORD,^AXDJ,^AXSJ,^AXEJ,^AXFJ,^AXXJ,^AXHJ,^AXNJ,^AXIJ,^AXMJ,^AXJR,^AXUJ True
./go.py v2Predict    ^AORD,^AXDJ,^AXSJ,^AXEJ,^AXFJ,^AXXJ,^AXHJ,^AXNJ,^AXIJ,^AXMJ,^AXJR,^AXUJ 0 True
./go.py v2Features   ^AORD,^AXDJ,^AXSJ,^AXEJ,^AXFJ,^AXXJ,^AXHJ,^AXNJ,^AXIJ,^AXMJ,^AXJR,^AXUJ True
./go.py v2TestPerf   ^AORD,^AXDJ,^AXSJ,^AXEJ,^AXFJ,^AXXJ,^AXHJ,^AXNJ,^AXIJ,^AXMJ,^AXJR,^AXUJ

./v2preml.sh 20 > predictions.html

node investing-get.js -l -a -s 01/01/2015 -e 07/07/2017 -d >> a.txt
node investing-get.js -l -a -s 01/01/2013 -e 01/01/2015 -d >> a.txt
node investing-get.js -l -a -s 01/01/2011 -e 01/01/2013 -d >> a.txt
node investing-get.js -l -a -s 01/01/2009 -e 01/01/2011 -d >> a.txt
node investing-get.js -l -a -s 01/01/2007 -e 01/01/2009 -d >> a.txt
node investing-get.js -l -a -s 01/01/2005 -e 01/01/2007 -d >> a.txt
node investing-get.js -l -a -s 01/01/2003 -e 01/01/2005 -d >> a.txt
node investing-get.js -l -a -s 01/01/2001 -e 01/01/2003 -d >> a.txt
node investing-get.js -l -a -s 01/01/1999 -e 01/01/2001 -d >> a.txt
node investing-get.js -l -a -s 01/01/1997 -e 01/01/1999 -d >> a.txt
node investing-get.js -l -a -s 01/01/1995 -e 01/01/1997 -d >> a.txt
node investing-get.js -l -a -s 01/01/1993 -e 01/01/1995 -d >> a.txt
node investing-get.js -l -a -s 01/01/1991 -e 01/01/1993 -d >> a.txt
node investing-get.js -l -a -s 01/01/1989 -e 01/01/1991 -d >> a.txt
node investing-get.js -l -a -s 01/01/1987 -e 01/01/1989 -d >> a.txt
node investing-get.js -l -a -s 01/01/1985 -e 01/01/1987 -d >> a.txt
node investing-get.js -l -a -s 01/01/1983 -e 01/01/1985 -d >> a.txt
node investing-get.js -l -a -s 01/01/1981 -e 01/01/1983 -d >> a.txt
