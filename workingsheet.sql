
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
    v2.chngDiv('^SSMI',  s.date, '1 day') AS ssmiDaily,     v2.chngDiv('^SSMI',  s.date, '1 week') AS ssmiWeekly,     v2.chngDiv('^SSMI',  s.date, '1 month') AS ssmiMonthly,
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
