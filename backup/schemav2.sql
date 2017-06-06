--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.2

-- Started on 2017-06-06 16:55:44 AEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 8 (class 2615 OID 1093208)
-- Name: v2; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA v2;


ALTER SCHEMA v2 OWNER TO postgres;

--
-- TOC entry 2223 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA v2; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA v2 IS 'Version 2 approach';


SET search_path = v2, pg_catalog;

--
-- TOC entry 239 (class 1255 OID 1095820)
-- Name: chngdiv(text, date, text); Type: FUNCTION; Schema: v2; Owner: postgres
--

CREATE FUNCTION chngdiv(stockname text, dt date, intr text) RETURNS double precision
    LANGUAGE plpgsql
    AS $$

DECLARE ret double precision;
DECLARE firstAvailableCloseInterval double precision;
DECLARE firstAvailableClose double precision;
	BEGIN
	-- find first available close. Maybe it is not available by that date. Then take the first available below that date
	select "Adj Close" into firstAvailableClose from stocks
	  where
	    stock = stockname and
	    date <= dt
	  order by date desc
	  limit 1;

	-- find first available close in interval. Then take the first available below that date
	select "Adj Close" into firstAvailableCloseInterval from stocks
	  where
	    stock = stockname and
	    date <= dt - intr::interval
	    order by date desc
	  limit 1;

	ret = 0;
	if firstAvailableCloseInterval <> 0 then
		select firstAvailableClose / firstAvailableCloseInterval into ret;
	end if;
    
	return ret;
END;

$$;


ALTER FUNCTION v2.chngdiv(stockname text, dt date, intr text) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 1095900)
-- Name: chngdivfuture(text, date, text); Type: FUNCTION; Schema: v2; Owner: postgres
--

CREATE FUNCTION chngdivfuture(stockname text, dt date, intr text) RETURNS double precision
    LANGUAGE plpgsql
    AS $$

DECLARE ret double precision;
DECLARE firstAvailableCloseInterval double precision;
DECLARE firstAvailableClose double precision;
	BEGIN
	-- find first available close. Maybe it is not available by that date. Then take the first available below that date
	select "Adj Close" into firstAvailableClose from stocks
	  where
	    stock = stockname and
	    date <= dt
	  order by date desc
	  limit 1;

	-- find first available close in interval. Then take the first available below that date
    -- (intr::interval / 4) is to get a date around the interval if exact date record doesn't exist 
	select "Adj Close" into firstAvailableCloseInterval from stocks
	  where
	    stock = stockname and
	    date between dt + (intr::interval / 4) and dt + intr::interval
	    order by date desc
	  limit 1;

	ret = 0;
	if firstAvailableCloseInterval <> 0 then
		select firstAvailableClose / firstAvailableCloseInterval into ret;
	end if;
    
	return ret;
END;

$$;


ALTER FUNCTION v2.chngdivfuture(stockname text, dt date, intr text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 202 (class 1259 OID 1093225)
-- Name: instrumentsprops; Type: TABLE; Schema: v2; Owner: postgres
--

CREATE TABLE instrumentsprops (
    symbol text NOT NULL,
    correlation double precision,
    corrdate date,
    prediction double precision,
    preddate date,
    bestattributes text,
    bestcorrelation double precision,
    excludedattributes text,
    active boolean DEFAULT false NOT NULL,
    topredict boolean DEFAULT false NOT NULL,
    optimiseattr boolean DEFAULT false NOT NULL,
    error double precision,
    bestgamma double precision,
    bestcost double precision,
    bestnu double precision,
    classifierdump bytea
);


ALTER TABLE instrumentsprops OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 1095901)
-- Name: datamining_aggr_view; Type: VIEW; Schema: v2; Owner: postgres
--

CREATE VIEW datamining_aggr_view AS
 SELECT s.date,
    s.stock AS instrument,
    chngdiv(s.stock, s.date, '1 day'::text) AS instrdaily,
    chngdiv(s.stock, s.date, '1 week'::text) AS instrweekly,
    chngdiv(s.stock, s.date, '1 month'::text) AS instrmonthly,
    chngdiv('^AORD'::text, s.date, '1 day'::text) AS aorddaily,
    chngdiv('^AORD'::text, s.date, '1 week'::text) AS aordweekly,
    chngdiv('^AORD'::text, s.date, '1 month'::text) AS aordmonthly,
    chngdiv('^N225'::text, s.date, '1 day'::text) AS n225daily,
    chngdiv('^N225'::text, s.date, '1 week'::text) AS n225weekly,
    chngdiv('^N225'::text, s.date, '1 month'::text) AS n225monthly,
    chngdiv('^NDX'::text, s.date, '1 day'::text) AS ndxdaily,
    chngdiv('^NDX'::text, s.date, '1 week'::text) AS ndxweekly,
    chngdiv('^NDX'::text, s.date, '1 month'::text) AS ndxmonthly,
    chngdiv('^GDAXI'::text, s.date, '1 day'::text) AS gdaxidaily,
    chngdiv('^GDAXI'::text, s.date, '1 week'::text) AS gdaxiweekly,
    chngdiv('^GDAXI'::text, s.date, '1 month'::text) AS gdaximonthly,
    chngdiv('^SSEC'::text, s.date, '1 day'::text) AS ssecdaily,
    chngdiv('^SSEC'::text, s.date, '1 week'::text) AS ssecweekly,
    chngdiv('^SSEC'::text, s.date, '1 month'::text) AS ssecmonthly,
    chngdiv('^HSI'::text, s.date, '1 day'::text) AS hsidaily,
    chngdiv('^HSI'::text, s.date, '1 week'::text) AS hsiweekly,
    chngdiv('^HSI'::text, s.date, '1 month'::text) AS hsimonthly,
    chngdiv('^BSESN'::text, s.date, '1 day'::text) AS bsesndaily,
    chngdiv('^BSESN'::text, s.date, '1 week'::text) AS bsesnweekly,
    chngdiv('^BSESN'::text, s.date, '1 month'::text) AS bsesnmonthly,
    chngdiv('^JKSE'::text, s.date, '1 day'::text) AS jksedaily,
    chngdiv('^JKSE'::text, s.date, '1 week'::text) AS jkseweekly,
    chngdiv('^JKSE'::text, s.date, '1 month'::text) AS jksemonthly,
    chngdiv('^KLSE'::text, s.date, '1 day'::text) AS klsedaily,
    chngdiv('^KLSE'::text, s.date, '1 week'::text) AS klseweekly,
    chngdiv('^KLSE'::text, s.date, '1 month'::text) AS klsemonthly,
    chngdiv('^NZ50'::text, s.date, '1 day'::text) AS nz50daily,
    chngdiv('^NZ50'::text, s.date, '1 week'::text) AS nz50weekly,
    chngdiv('^NZ50'::text, s.date, '1 month'::text) AS nz50monthly,
    chngdiv('^STI'::text, s.date, '1 day'::text) AS stidaily,
    chngdiv('^STI'::text, s.date, '1 week'::text) AS stiweekly,
    chngdiv('^STI'::text, s.date, '1 month'::text) AS stimonthly,
    chngdiv('^KS11'::text, s.date, '1 day'::text) AS ks11daily,
    chngdiv('^KS11'::text, s.date, '1 week'::text) AS ks11weekly,
    chngdiv('^KS11'::text, s.date, '1 month'::text) AS ks11monthly,
    chngdiv('^TWII'::text, s.date, '1 day'::text) AS twiidaily,
    chngdiv('^TWII'::text, s.date, '1 week'::text) AS twiiweekly,
    chngdiv('^TWII'::text, s.date, '1 month'::text) AS twiimonthly,
    chngdiv('^BVSP'::text, s.date, '1 day'::text) AS bvspdaily,
    chngdiv('^BVSP'::text, s.date, '1 week'::text) AS bvspweekly,
    chngdiv('^BVSP'::text, s.date, '1 month'::text) AS bvspmonthly,
    chngdiv('^GSPTSE'::text, s.date, '1 day'::text) AS gsptsedaily,
    chngdiv('^GSPTSE'::text, s.date, '1 week'::text) AS gsptseweekly,
    chngdiv('^GSPTSE'::text, s.date, '1 month'::text) AS gsptsemonthly,
    chngdiv('^MXX'::text, s.date, '1 day'::text) AS mxxdaily,
    chngdiv('^MXX'::text, s.date, '1 week'::text) AS mxxweekly,
    chngdiv('^MXX'::text, s.date, '1 month'::text) AS mxxmonthly,
    chngdiv('^GSPC'::text, s.date, '1 day'::text) AS gspcdaily,
    chngdiv('^GSPC'::text, s.date, '1 week'::text) AS gspcweekly,
    chngdiv('^GSPC'::text, s.date, '1 month'::text) AS gspcmonthly,
    chngdiv('^ATX'::text, s.date, '1 day'::text) AS atxdaily,
    chngdiv('^ATX'::text, s.date, '1 week'::text) AS atxweekly,
    chngdiv('^ATX'::text, s.date, '1 month'::text) AS atxmonthly,
    chngdiv('^BFX'::text, s.date, '1 day'::text) AS bfxdaily,
    chngdiv('^BFX'::text, s.date, '1 week'::text) AS bfxweekly,
    chngdiv('^BFX'::text, s.date, '1 month'::text) AS bfxmonthly,
    chngdiv('^FCHI'::text, s.date, '1 day'::text) AS fchidaily,
    chngdiv('^FCHI'::text, s.date, '1 week'::text) AS fchiweekly,
    chngdiv('^FCHI'::text, s.date, '1 month'::text) AS fchimonthly,
    chngdiv('^OSEAX'::text, s.date, '1 day'::text) AS oseaxdaily,
    chngdiv('^OSEAX'::text, s.date, '1 week'::text) AS oseaxweekly,
    chngdiv('^OSEAX'::text, s.date, '1 month'::text) AS oseaxmonthly,
    chngdiv('^OMXSPI'::text, s.date, '1 day'::text) AS omxspidaily,
    chngdiv('^OMXSPI'::text, s.date, '1 week'::text) AS omxspiweekly,
    chngdiv('^OMXSPI'::text, s.date, '1 month'::text) AS omxspimonthly,
    chngdiv('^SSMI'::text, s.date, '1 day'::text) AS ssmidaily,
    chngdiv('^SSMI'::text, s.date, '1 week'::text) AS ssmiweekly,
    chngdiv('^SSMI'::text, s.date, '1 month'::text) AS ssmimonthly,
    chngdiv('FXA'::text, s.date, '1 day'::text) AS fxadaily,
    chngdiv('FXA'::text, s.date, '1 week'::text) AS fxaweekly,
    chngdiv('FXA'::text, s.date, '1 month'::text) AS fxamonthly,
    chngdiv('FXB'::text, s.date, '1 day'::text) AS fxbdaily,
    chngdiv('FXB'::text, s.date, '1 week'::text) AS fxbweekly,
    chngdiv('FXB'::text, s.date, '1 month'::text) AS fxbmonthly,
    chngdiv('FXC'::text, s.date, '1 day'::text) AS fxcdaily,
    chngdiv('FXC'::text, s.date, '1 week'::text) AS fxcweekly,
    chngdiv('FXC'::text, s.date, '1 month'::text) AS fxcmonthly,
    chngdiv('FXE'::text, s.date, '1 day'::text) AS fxedaily,
    chngdiv('FXE'::text, s.date, '1 week'::text) AS fxeweekly,
    chngdiv('FXE'::text, s.date, '1 month'::text) AS fxemonthly,
    chngdiv('FXF'::text, s.date, '1 day'::text) AS fxfdaily,
    chngdiv('FXF'::text, s.date, '1 week'::text) AS fxfweekly,
    chngdiv('FXF'::text, s.date, '1 month'::text) AS fxfmonthly,
    chngdiv('FXS'::text, s.date, '1 day'::text) AS fxsdaily,
    chngdiv('FXS'::text, s.date, '1 week'::text) AS fxsweekly,
    chngdiv('FXS'::text, s.date, '1 month'::text) AS fxsmonthly,
    chngdiv('FXY'::text, s.date, '1 day'::text) AS fxydaily,
    chngdiv('FXY'::text, s.date, '1 week'::text) AS fxyweekly,
    chngdiv('FXY'::text, s.date, '1 month'::text) AS fxymonthly,
    chngdiv('CHOC'::text, s.date, '1 day'::text) AS cmdchocdaily,
    chngdiv('CHOC'::text, s.date, '1 week'::text) AS cmdchocweekly,
    chngdiv('CHOC'::text, s.date, '1 month'::text) AS cmdchocmonthly,
    chngdiv('CORN'::text, s.date, '1 day'::text) AS cmdcorndaily,
    chngdiv('CORN'::text, s.date, '1 week'::text) AS cmdcornweekly,
    chngdiv('CORN'::text, s.date, '1 month'::text) AS cmdcornmonthly,
    chngdiv('CTNN'::text, s.date, '1 day'::text) AS cmdctnndaily,
    chngdiv('CTNN'::text, s.date, '1 week'::text) AS cmdctnnweekly,
    chngdiv('CTNN'::text, s.date, '1 month'::text) AS cmdctnnmonthly,
    chngdiv('CUPM'::text, s.date, '1 day'::text) AS cmdcupmdaily,
    chngdiv('CUPM'::text, s.date, '1 week'::text) AS cmdcupmweekly,
    chngdiv('CUPM'::text, s.date, '1 month'::text) AS cmdcupmmonthly,
    chngdiv('FOIL'::text, s.date, '1 day'::text) AS "cmdfoildaīly",
    chngdiv('FOIL'::text, s.date, '1 week'::text) AS cmdfoilweekly,
    chngdiv('FOIL'::text, s.date, '1 month'::text) AS cmdfoilmonthly,
    chngdiv('GAZ'::text, s.date, '1 day'::text) AS cmdgazdaily,
    chngdiv('GAZ'::text, s.date, '1 week'::text) AS cmdgazweekly,
    chngdiv('GAZ'::text, s.date, '1 month'::text) AS cmdgazmonthly,
    chngdiv('GLD'::text, s.date, '1 day'::text) AS cmdglddaily,
    chngdiv('GLD'::text, s.date, '1 week'::text) AS cmdgldweekly,
    chngdiv('GLD'::text, s.date, '1 month'::text) AS cmdgldmonthly,
    chngdiv('HEVY'::text, s.date, '1 day'::text) AS cmdhevydaily,
    chngdiv('HEVY'::text, s.date, '1 week'::text) AS cmdhevyweekly,
    chngdiv('HEVY'::text, s.date, '1 month'::text) AS cmdhevymonthly,
    chngdiv('LEDD'::text, s.date, '1 day'::text) AS cmdledddaily,
    chngdiv('LEDD'::text, s.date, '1 week'::text) AS cmdleddweekly,
    chngdiv('LEDD'::text, s.date, '1 month'::text) AS cmdleddmonthly,
    chngdiv('LSTK'::text, s.date, '1 day'::text) AS cmdlstkdaily,
    chngdiv('LSTK'::text, s.date, '1 week'::text) AS cmdlstkweekly,
    chngdiv('LSTK'::text, s.date, '1 month'::text) AS cmdlstkmonthly,
    chngdiv('NINI'::text, s.date, '1 day'::text) AS cmdninidaily,
    chngdiv('NINI'::text, s.date, '1 week'::text) AS cmdniniweekly,
    chngdiv('NINI'::text, s.date, '1 month'::text) AS cmdninimonthly,
    chngdiv('OIL'::text, s.date, '1 day'::text) AS cmdoildaily,
    chngdiv('OIL'::text, s.date, '1 week'::text) AS cmdoilweekly,
    chngdiv('OIL'::text, s.date, '1 month'::text) AS cmdoilmonthly,
    chngdiv('PALL'::text, s.date, '1 day'::text) AS cmdpalldaily,
    chngdiv('PALL'::text, s.date, '1 week'::text) AS cmdpallweekly,
    chngdiv('PALL'::text, s.date, '1 month'::text) AS cmdpallmonthly,
    chngdiv('PPLT'::text, s.date, '1 day'::text) AS cmdppltdaily,
    chngdiv('PPLT'::text, s.date, '1 week'::text) AS cmdppltweekly,
    chngdiv('PPLT'::text, s.date, '1 month'::text) AS cmdppltmonthly,
    chngdiv('SGAR'::text, s.date, '1 day'::text) AS cmdsgardaily,
    chngdiv('SGAR'::text, s.date, '1 week'::text) AS cmdsgarweekly,
    chngdiv('SGAR'::text, s.date, '1 month'::text) AS cmdsgarmonthly,
    chngdiv('SLV'::text, s.date, '1 day'::text) AS cmdslvdaily,
    chngdiv('SLV'::text, s.date, '1 week'::text) AS cmdslvweekly,
    chngdiv('SLV'::text, s.date, '1 month'::text) AS cmdslvmonthly,
    chngdiv('SOYB'::text, s.date, '1 day'::text) AS cmdsoybdaily,
    chngdiv('SOYB'::text, s.date, '1 week'::text) AS cmdsoybweekly,
    chngdiv('SOYB'::text, s.date, '1 month'::text) AS cmdsoybmonthly,
    chngdiv('UHN'::text, s.date, '1 day'::text) AS cmduhndaily,
    chngdiv('UHN'::text, s.date, '1 week'::text) AS cmduhnweekly,
    chngdiv('UHN'::text, s.date, '1 month'::text) AS cmduhnmonthly,
    chngdivfuture(s.stock, s.date, '1 month'::text) AS prediction
   FROM (public.stocks s
     JOIN instrumentsprops d ON ((d.symbol = s.stock)))
  WHERE (d.active = true)
  ORDER BY s.stock, s.date DESC;


ALTER TABLE datamining_aggr_view OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 1095843)
-- Name: downloadinstruments; Type: TABLE; Schema: v2; Owner: postgres
--

CREATE TABLE downloadinstruments (
    instrument text NOT NULL,
    type text
);


ALTER TABLE downloadinstruments OWNER TO postgres;

--
-- TOC entry 2096 (class 2606 OID 1095850)
-- Name: downloadinstruments downloadinstruments_pkey; Type: CONSTRAINT; Schema: v2; Owner: postgres
--

ALTER TABLE ONLY downloadinstruments
    ADD CONSTRAINT downloadinstruments_pkey PRIMARY KEY (instrument);


--
-- TOC entry 2094 (class 2606 OID 1093235)
-- Name: instrumentsprops pk_dataminestocks_py; Type: CONSTRAINT; Schema: v2; Owner: postgres
--

ALTER TABLE ONLY instrumentsprops
    ADD CONSTRAINT pk_dataminestocks_py PRIMARY KEY (symbol);


-- Completed on 2017-06-06 16:55:46 AEST

--
-- PostgreSQL database dump complete
--

