--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.10
-- Dumped by pg_dump version 9.3.10
-- Started on 2016-01-24 21:43:42 AEDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2045 (class 1262 OID 12066)
-- Dependencies: 2044
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 182 (class 3079 OID 11787)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2048 (class 0 OID 0)
-- Dependencies: 182
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 181 (class 3079 OID 17387)
-- Name: plpythonu; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpythonu WITH SCHEMA pg_catalog;


--
-- TOC entry 2049 (class 0 OID 0)
-- Dependencies: 181
-- Name: EXTENSION plpythonu; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpythonu IS 'PL/PythonU untrusted procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 549 (class 1247 OID 41426)
-- Name: avg_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE avg_type AS (
	a1 double precision,
	a2 double precision,
	a3 double precision,
	a4 double precision,
	a5 double precision,
	a6 double precision
);


ALTER TYPE public.avg_type OWNER TO postgres;

--
-- TOC entry 206 (class 1255 OID 42037)
-- Name: change(text, date, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION change(stockname text, dt date, intr interval) RETURNS double precision
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
	    date <= dt + intr
	    order by date desc
	  limit 1;

	select (firstAvailableCloseInterval - firstAvailableClose) / firstAvailableClose into ret;

	return ret * 100;
END;
$$;


ALTER FUNCTION public.change(stockname text, dt date, intr interval) OWNER TO postgres;

--
-- TOC entry 200 (class 1255 OID 41455)
-- Name: forexavgdif(text, date, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION forexavgdif(pair text, dt date, intr interval) RETURNS double precision
    LANGUAGE plpgsql
    AS $_$
DECLARE ret double precision;
DECLARE avg_v double precision;
DECLARE firstAvailableClose double precision;
	BEGIN
	-- find first available close. Maybe it is not available by that date. Then take the first available below that date
	execute
		format('select %I from forex where date <= $1 order by date desc limit 1', pair)
		into firstAvailableClose
		using dt;

	execute
		format('select avg(%I) from forex where date >= ($1 - $2) and date < $1', pair)
		into avg_v
		using dt, intr;

	select (firstAvailableClose - avg_v) / avg_v into ret;

	return ret * 100;
END;
$_$;


ALTER FUNCTION public.forexavgdif(pair text, dt date, intr interval) OWNER TO postgres;

--
-- TOC entry 202 (class 1255 OID 41456)
-- Name: forexavgdiffset(text, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION forexavgdiffset(forex text, dt date) RETURNS avg_type
    LANGUAGE plpgsql
    AS $$

DECLARE
  result_record avg_type;

BEGIN
  SELECT 
	forexavgdif(forex, dt, interval '5 days')
,	forexavgdif(forex, dt, interval '10 days')
,	forexavgdif(forex, dt, interval '15 days')
,	forexavgdif(forex, dt, interval '20 days')
,	forexavgdif(forex, dt, interval '25 days')
,	forexavgdif(forex, dt, interval '30 days')
 INTO result_record.a1, result_record.a2, result_record.a3, result_record.a4, result_record.a5, result_record.a6;

  RETURN result_record;

END
$$;


ALTER FUNCTION public.forexavgdiffset(forex text, dt date) OWNER TO postgres;

--
-- TOC entry 195 (class 1255 OID 41206)
-- Name: h_bigint(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION h_bigint(text) RETURNS bigint
    LANGUAGE sql
    AS $_$
 select ('x'||substr(md5($1),1,16))::bit(64)::bigint;
$_$;


ALTER FUNCTION public.h_bigint(text) OWNER TO postgres;

--
-- TOC entry 196 (class 1255 OID 41207)
-- Name: h_int(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION h_int(text) RETURNS integer
    LANGUAGE sql
    AS $_$
 select ('x'||substr(md5($1),1,8))::bit(32)::int;
$_$;


ALTER FUNCTION public.h_int(text) OWNER TO postgres;

--
-- TOC entry 205 (class 1255 OID 42001)
-- Name: islastthurthday(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION islastthurthday(dt date) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE
  nextweekmonth integer;
  curweekmonth integer;

BEGIN
	nextweekmonth := EXTRACT(month from dt + interval '1 week');
	curweekmonth := EXTRACT(month from dt);
	if EXTRACT(dow FROM dt)=4 and nextweekmonth != curweekmonth then
		return 1;
	else 
		return 0;
	end if;

  RETURN 1;

END
$$;


ALTER FUNCTION public.islastthurthday(dt date) OWNER TO postgres;

--
-- TOC entry 203 (class 1255 OID 41478)
-- Name: nextavgdif(text, date, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION nextavgdif(stockname text, dt date, intr interval) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE ret double precision;
DECLARE avg_v double precision;
DECLARE firstAvailableClose double precision;
	BEGIN
	-- find first available close. Maybe it is not available by that date. Then take the first available below that date
	select "Adj Close" into firstAvailableClose from stocks
	  where
	    stock = stockname and
	    date <= dt
	  order by date desc
	  limit 1;

	select avg(s1."Adj Close") into avg_v from stocks s1
	  where
	    s1.stock = stockname and
	    s1.date <= dt + intr and
	    s1.date > dt;

	select (avg_v - firstAvailableClose) / firstAvailableClose into ret;

	return ret * 100;
END;
$$;


ALTER FUNCTION public.nextavgdif(stockname text, dt date, intr interval) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 170 (class 1259 OID 41196)
-- Name: stocks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE stocks (
    date date,
    volume bigint,
    stock text,
    open double precision,
    high double precision,
    low double precision,
    close double precision,
    "Adj Close" double precision,
    id integer NOT NULL
);


ALTER TABLE public.stocks OWNER TO postgres;

--
-- TOC entry 197 (class 1255 OID 41208)
-- Name: nextrec(date, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION nextrec(dt date, diff integer, code text) RETURNS SETOF stocks
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	--RAISE NOTICE 'hello, world!';
	RETURN QUERY 
	SELECT * from (
		SELECT * from stocksvol s
		where s.code = $3 and s.date > dt
		order by s.date asc
		limit diff
		) d
	order by d.date desc
	limit 1;
	return;
END;
$_$;


ALTER FUNCTION public.nextrec(dt date, diff integer, code text) OWNER TO postgres;

--
-- TOC entry 198 (class 1255 OID 41209)
-- Name: prevrec(date, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION prevrec(dt date, diff integer, code text) RETURNS SETOF stocks
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	RETURN QUERY 
	SELECT * from (
		SELECT * from stocksvol s
		where s.code = $3 and s.date < dt
		order by s.date desc
		limit diff
		) d
	order by d.date asc
	limit 1;
	return;
END;
$_$;


ALTER FUNCTION public.prevrec(dt date, diff integer, code text) OWNER TO postgres;

--
-- TOC entry 199 (class 1255 OID 41383)
-- Name: stockavg(text, date, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION stockavg(stockname text, dt date, intr interval) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE ret double precision;
	BEGIN
	select avg(s1."Adj Close") into ret from stocks s1
where
s1.stock = stockname and
s1.date > dt - intr and
s1.date <= dt;
	return ret;
END;
$$;


ALTER FUNCTION public.stockavg(stockname text, dt date, intr interval) OWNER TO postgres;

--
-- TOC entry 207 (class 1255 OID 41415)
-- Name: stockavgdif(text, date, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION stockavgdif(stockname text, dt date, intr interval) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE ret double precision;
DECLARE avg_v double precision;
DECLARE firstAvailableClose double precision;
	BEGIN
	-- find first available close. Maybe it is not available by that date. Then take the first available below that date
	select "Adj Close" into firstAvailableClose from stocks
	  where
	    stock = stockname and
	    date <= dt
	  order by date desc
	  limit 1;
	    
	select avg(s1."Adj Close") into avg_v from stocks s1
	  where
	    s1.stock = stockname and
	    s1.date >= dt - intr and
	    s1.date < dt;

	select (firstAvailableClose - avg_v) / avg_v into ret;

	if ret is null then
		ret = 0;
	end if;
	return ret * 100;
END;
$$;


ALTER FUNCTION public.stockavgdif(stockname text, dt date, intr interval) OWNER TO postgres;

--
-- TOC entry 204 (class 1255 OID 41429)
-- Name: stockavgdiffset(text, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION stockavgdiffset(stock text, dt date) RETURNS avg_type
    LANGUAGE plpgsql
    AS $$

DECLARE
  result_record avg_type;

BEGIN
  SELECT 
	stockavgdif(stock, dt, interval '7 days')
,	stockavgdif(stock, dt, interval '14 days')
,	stockavgdif(stock, dt, interval '21 days')
,	stockavgdif(stock, dt, interval '28 days')
,	stockavgdif(stock, dt, interval '35 days')
,	stockavgdif(stock, dt, interval '42 days')
 INTO result_record.a1, result_record.a2, result_record.a3, result_record.a4, result_record.a5, result_record.a6;

  RETURN result_record;

END
$$;


ALTER FUNCTION public.stockavgdiffset(stock text, dt date) OWNER TO postgres;

--
-- TOC entry 201 (class 1255 OID 41428)
-- Name: stockavgdiffset(text, date, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION stockavgdiffset(stock text, dt date, intr interval) RETURNS avg_type
    LANGUAGE plpgsql
    AS $$

DECLARE
  result_record avg_type;

BEGIN
  SELECT 
	stockavgdif(stock, dt, interval '5 days')
,	stockavgdif(stock, dt, interval '10 days')
,	stockavgdif(stock, dt, interval '15 days')
,	stockavgdif(stock, dt, interval '20 days')
,	stockavgdif(stock, dt, interval '25 days')
 INTO result_record.a1, result_record.a2, result_record.a3, result_record.a4, result_record.a5;

  RETURN result_record;

END
$$;


ALTER FUNCTION public.stockavgdiffset(stock text, dt date, intr interval) OWNER TO postgres;

--
-- TOC entry 176 (class 1259 OID 41738)
-- Name: dataminestocks; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dataminestocks (
    stockname text NOT NULL,
    correlation double precision,
    corrdate date,
    prediction double precision,
    preddate date,
    bestattributes text,
    bestcorrelation double precision,
    excludedattributes text,
    active boolean DEFAULT false NOT NULL,
    bestcost text,
    bestnu text,
    topredict boolean DEFAULT false NOT NULL,
    optimiseattr boolean DEFAULT false NOT NULL,
    error double precision
);


ALTER TABLE public.dataminestocks OWNER TO postgres;

--
-- TOC entry 2050 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.corrdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.corrdate IS 'date correlation was calculated';


--
-- TOC entry 2051 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.preddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.preddate IS 'date of last data prediction based on';


--
-- TOC entry 2052 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.active IS 'is stock active like used in calcultions';


--
-- TOC entry 179 (class 1259 OID 42032)
-- Name: datamining_avg_stocks_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datamining_avg_stocks_view AS
 SELECT s.date,
    s.stock AS stockname,
    s."Adj Close" AS price,
    stockavgdiffset(s.stock, s.date) AS stockavg,
    stockavgdiffset('^AORD'::text, s.date) AS aord,
    stockavgdiffset('^N225'::text, s.date) AS n225,
    stockavgdiffset('^NDX'::text, s.date) AS ndx,
    stockavgdiffset('^DJI'::text, s.date) AS dji,
    stockavgdiffset('^FTSE'::text, s.date) AS ftse,
    stockavgdiffset('^GDAXI'::text, s.date) AS gdaxi,
    stockavgdiffset('^SSEC'::text, s.date) AS ssec,
    stockavgdiffset('^HSI'::text, s.date) AS hsi,
    stockavgdiffset('^BSESN'::text, s.date) AS bsesn,
    stockavgdiffset('^JKSE'::text, s.date) AS jkse,
    stockavgdiffset('^KLSE'::text, s.date) AS klse,
    stockavgdiffset('^NZ50'::text, s.date) AS nz50,
    stockavgdiffset('^STI'::text, s.date) AS sti,
    stockavgdiffset('^KS11'::text, s.date) AS ks11,
    stockavgdiffset('^TWII'::text, s.date) AS twii,
    stockavgdiffset('^BVSP'::text, s.date) AS bvsp,
    stockavgdiffset('^GSPTSE'::text, s.date) AS gsptse,
    stockavgdiffset('^MXX'::text, s.date) AS mxx,
    stockavgdiffset('^GSPC'::text, s.date) AS gspc,
    stockavgdiffset('^ATX'::text, s.date) AS atx,
    stockavgdiffset('^BFX'::text, s.date) AS bfx,
    stockavgdiffset('^FCHI'::text, s.date) AS fchi,
    stockavgdiffset('^OSEAX'::text, s.date) AS oseax,
    stockavgdiffset('^OMXSPI'::text, s.date) AS omxspi,
    stockavgdiffset('^SSMI'::text, s.date) AS ssmi,
    stockavgdiffset('GD.AT'::text, s.date) AS gd,
    stockavgdiffset('EURUSD'::text, s.date) AS eurusd,
    stockavgdiffset('USDJPY'::text, s.date) AS usdjpy,
    stockavgdiffset('USDCHF'::text, s.date) AS usdchf,
    stockavgdiffset('GBPUSD'::text, s.date) AS gbpusd,
    stockavgdiffset('USDCAD'::text, s.date) AS usdcad,
    stockavgdiffset('EURGBP'::text, s.date) AS eurgbp,
    stockavgdiffset('EURJPY'::text, s.date) AS eurjpy,
    stockavgdiffset('EURCHF'::text, s.date) AS eurchf,
    stockavgdiffset('AUDUSD'::text, s.date) AS audusd,
    stockavgdiffset('GBPJPY'::text, s.date) AS gbpjpy,
    stockavgdiffset('CHFJPY'::text, s.date) AS chfjpy,
    stockavgdiffset('GBPCHF'::text, s.date) AS gbpchf,
    stockavgdiffset('NZDUSD'::text, s.date) AS nzdusd,
    stockavgdiffset('CHOC'::text, s.date) AS cmd_choc,
    stockavgdiffset('CORN'::text, s.date) AS cmd_corn,
    stockavgdiffset('CTNN'::text, s.date) AS cmd_ctnn,
    stockavgdiffset('CUPM'::text, s.date) AS cmd_cupm,
    stockavgdiffset('FOIL'::text, s.date) AS cmd_foil,
    stockavgdiffset('GAZ'::text, s.date) AS cmd_gaz,
    stockavgdiffset('GLD'::text, s.date) AS cmd_gld,
    stockavgdiffset('HEVY'::text, s.date) AS cmd_hevy,
    stockavgdiffset('LEDD'::text, s.date) AS cmd_ledd,
    stockavgdiffset('LSTK'::text, s.date) AS cmd_lstk,
    stockavgdiffset('NINI'::text, s.date) AS cmd_nini,
    stockavgdiffset('OIL'::text, s.date) AS cmd_oil,
    stockavgdiffset('PALL'::text, s.date) AS cmd_pall,
    stockavgdiffset('PPLT'::text, s.date) AS cmd_pplt,
    stockavgdiffset('SGAR'::text, s.date) AS cmd_sgar,
    stockavgdiffset('SLV'::text, s.date) AS cmd_slv,
    stockavgdiffset('SOYB'::text, s.date) AS cmd_soyb,
    stockavgdiffset('UHN'::text, s.date) AS cmd_uhn,
    date_part('dow'::text, s.date) AS dow,
    date_part('week'::text, s.date) AS week,
    islastthurthday(s.date) AS optexpday,
    nextavgdif(s.stock, s.date, '7 days'::interval) AS next5
   FROM stocks s
  ORDER BY s.stock, s.date DESC;


ALTER TABLE public.datamining_avg_stocks_view OWNER TO postgres;

--
-- TOC entry 180 (class 1259 OID 42038)
-- Name: datamining_stocks_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datamining_stocks_view AS
 SELECT s.date,
    s.stock AS stockname,
    s."Adj Close" AS price,
    stockavgdiffset(s.stock, s.date) AS stockavg,
    stockavgdiffset('^AORD'::text, s.date) AS aord,
    stockavgdiffset('^N225'::text, s.date) AS n225,
    stockavgdiffset('^NDX'::text, s.date) AS ndx,
    stockavgdiffset('^DJI'::text, s.date) AS dji,
    stockavgdiffset('^FTSE'::text, s.date) AS ftse,
    stockavgdiffset('^GDAXI'::text, s.date) AS gdaxi,
    stockavgdiffset('^SSEC'::text, s.date) AS ssec,
    stockavgdiffset('^HSI'::text, s.date) AS hsi,
    stockavgdiffset('^BSESN'::text, s.date) AS bsesn,
    stockavgdiffset('^JKSE'::text, s.date) AS jkse,
    stockavgdiffset('^KLSE'::text, s.date) AS klse,
    stockavgdiffset('^NZ50'::text, s.date) AS nz50,
    stockavgdiffset('^STI'::text, s.date) AS sti,
    stockavgdiffset('^KS11'::text, s.date) AS ks11,
    stockavgdiffset('^TWII'::text, s.date) AS twii,
    stockavgdiffset('^BVSP'::text, s.date) AS bvsp,
    stockavgdiffset('^GSPTSE'::text, s.date) AS gsptse,
    stockavgdiffset('^MXX'::text, s.date) AS mxx,
    stockavgdiffset('^GSPC'::text, s.date) AS gspc,
    stockavgdiffset('^ATX'::text, s.date) AS atx,
    stockavgdiffset('^BFX'::text, s.date) AS bfx,
    stockavgdiffset('^FCHI'::text, s.date) AS fchi,
    stockavgdiffset('^OSEAX'::text, s.date) AS oseax,
    stockavgdiffset('^OMXSPI'::text, s.date) AS omxspi,
    stockavgdiffset('^SSMI'::text, s.date) AS ssmi,
    stockavgdiffset('GD.AT'::text, s.date) AS gd,
    stockavgdiffset('EURUSD'::text, s.date) AS eurusd,
    stockavgdiffset('USDJPY'::text, s.date) AS usdjpy,
    stockavgdiffset('USDCHF'::text, s.date) AS usdchf,
    stockavgdiffset('GBPUSD'::text, s.date) AS gbpusd,
    stockavgdiffset('USDCAD'::text, s.date) AS usdcad,
    stockavgdiffset('EURGBP'::text, s.date) AS eurgbp,
    stockavgdiffset('EURJPY'::text, s.date) AS eurjpy,
    stockavgdiffset('EURCHF'::text, s.date) AS eurchf,
    stockavgdiffset('AUDUSD'::text, s.date) AS audusd,
    stockavgdiffset('GBPJPY'::text, s.date) AS gbpjpy,
    stockavgdiffset('CHFJPY'::text, s.date) AS chfjpy,
    stockavgdiffset('GBPCHF'::text, s.date) AS gbpchf,
    stockavgdiffset('NZDUSD'::text, s.date) AS nzdusd,
    stockavgdiffset('CHOC'::text, s.date) AS cmd_choc,
    stockavgdiffset('CORN'::text, s.date) AS cmd_corn,
    stockavgdiffset('CTNN'::text, s.date) AS cmd_ctnn,
    stockavgdiffset('CUPM'::text, s.date) AS cmd_cupm,
    stockavgdiffset('FOIL'::text, s.date) AS cmd_foil,
    stockavgdiffset('GAZ'::text, s.date) AS cmd_gaz,
    stockavgdiffset('GLD'::text, s.date) AS cmd_gld,
    stockavgdiffset('HEVY'::text, s.date) AS cmd_hevy,
    stockavgdiffset('LEDD'::text, s.date) AS cmd_ledd,
    stockavgdiffset('LSTK'::text, s.date) AS cmd_lstk,
    stockavgdiffset('NINI'::text, s.date) AS cmd_nini,
    stockavgdiffset('OIL'::text, s.date) AS cmd_oil,
    stockavgdiffset('PALL'::text, s.date) AS cmd_pall,
    stockavgdiffset('PPLT'::text, s.date) AS cmd_pplt,
    stockavgdiffset('SGAR'::text, s.date) AS cmd_sgar,
    stockavgdiffset('SLV'::text, s.date) AS cmd_slv,
    stockavgdiffset('SOYB'::text, s.date) AS cmd_soyb,
    stockavgdiffset('UHN'::text, s.date) AS cmd_uhn,
    date_part('dow'::text, s.date) AS dow,
    date_part('week'::text, s.date) AS week,
    islastthurthday(s.date) AS optexpday,
    change(s.stock, s.date, '7 days'::interval) AS prediction
   FROM stocks s
  ORDER BY s.stock, s.date DESC;


ALTER TABLE public.datamining_stocks_view OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 41542)
-- Name: datamining_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datamining_view AS
 SELECT s.date,
    s.stock AS stockname,
    s."Adj Close" AS price,
    stockavgdiffset(s.stock, s.date) AS stockavg,
    stockavgdiffset('^AORD'::text, s.date) AS aord,
    stockavgdiffset('^N225'::text, s.date) AS n225,
    stockavgdiffset('^NDX'::text, s.date) AS ndx,
    stockavgdiffset('^DJI'::text, s.date) AS dji,
    stockavgdiffset('^FTSE'::text, s.date) AS ftse,
    stockavgdiffset('^GDAXI'::text, s.date) AS gdaxi,
    stockavgdiffset('^SSEC'::text, s.date) AS ssec,
    stockavgdiffset('^HSI'::text, s.date) AS hsi,
    stockavgdiffset('^BSESN'::text, s.date) AS bsesn,
    stockavgdiffset('^JKSE'::text, s.date) AS jkse,
    stockavgdiffset('^KLSE'::text, s.date) AS klse,
    stockavgdiffset('^NZ50'::text, s.date) AS nz50,
    stockavgdiffset('^STI'::text, s.date) AS sti,
    stockavgdiffset('^KS11'::text, s.date) AS ks11,
    stockavgdiffset('^TWII'::text, s.date) AS twii,
    stockavgdiffset('^BVSP'::text, s.date) AS bvsp,
    stockavgdiffset('^GSPTSE'::text, s.date) AS gsptse,
    stockavgdiffset('^MXX'::text, s.date) AS mxx,
    stockavgdiffset('^GSPC'::text, s.date) AS gspc,
    stockavgdiffset('^ATX'::text, s.date) AS atx,
    stockavgdiffset('^BFX'::text, s.date) AS bfx,
    stockavgdiffset('^FCHI'::text, s.date) AS fchi,
    stockavgdiffset('^OSEAX'::text, s.date) AS oseax,
    stockavgdiffset('^OMXSPI'::text, s.date) AS omxspi,
    stockavgdiffset('^SSMI'::text, s.date) AS ssmi,
    stockavgdiffset('GD.AT'::text, s.date) AS gd,
    forexavgdiffset('EUR/USD_Close'::text, s.date) AS eurusd,
    forexavgdiffset('USD/JPY_Close'::text, s.date) AS usdjpy,
    forexavgdiffset('USD/CHF_Close'::text, s.date) AS usdchf,
    forexavgdiffset('GBP/USD_Close'::text, s.date) AS gbpusd,
    forexavgdiffset('USD/CAD_Close'::text, s.date) AS usdcad,
    forexavgdiffset('EUR/GBP_Close'::text, s.date) AS eurgbp,
    forexavgdiffset('EUR/JPY_Close'::text, s.date) AS eurjpy,
    forexavgdiffset('EUR/CHF_Close'::text, s.date) AS eurchf,
    forexavgdiffset('AUD/USD_Close'::text, s.date) AS audusd,
    forexavgdiffset('GBP/JPY_Close'::text, s.date) AS gbpjpy,
    forexavgdiffset('CHF/JPY_Close'::text, s.date) AS chfjpy,
    forexavgdiffset('GBP/CHF_Close'::text, s.date) AS gbpchf,
    forexavgdiffset('NZD/USD_Close'::text, s.date) AS nzdusd,
    nextavgdif(s.stock, s.date, '5 days'::interval) AS next5
   FROM stocks s
  ORDER BY s.stock, s.date DESC;


ALTER TABLE public.datamining_view OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 41750)
-- Name: downloadinstruments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE downloadinstruments (
    instrument text NOT NULL,
    type text
);


ALTER TABLE public.downloadinstruments OWNER TO postgres;

--
-- TOC entry 171 (class 1259 OID 41277)
-- Name: forex; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE forex (
    date date,
    "EUR/USD_Close" numeric(12,5),
    "EUR/USD_High" numeric(12,5),
    "EUR/USD_Low" numeric(12,5),
    "USD/JPY_Close" numeric(10,3),
    "USD/JPY_High" numeric(10,3),
    "USD/JPY_Low" numeric(10,3),
    "USD/CHF_Close" numeric(12,5),
    "USD/CHF_High" numeric(12,5),
    "USD/CHF_Low" numeric(12,5),
    "GBP/USD_Close" numeric(12,5),
    "GBP/USD_High" numeric(12,5),
    "GBP/USD_Low" numeric(12,5),
    "USD/CAD_Close" numeric(12,5),
    "USD/CAD_High" numeric(12,5),
    "USD/CAD_Low" numeric(12,5),
    "EUR/GBP_Close" numeric(12,5),
    "EUR/GBP_High" numeric(12,5),
    "EUR/GBP_Low" numeric(12,5),
    "EUR/JPY_Close" numeric(10,3),
    "EUR/JPY_High" numeric(10,3),
    "EUR/JPY_Low" numeric(10,3),
    "EUR/CHF_Close" numeric(12,5),
    "EUR/CHF_High" numeric(12,5),
    "EUR/CHF_Low" numeric(12,5),
    "AUD/USD_Close" numeric(12,5),
    "AUD/USD_High" numeric(12,5),
    "AUD/USD_Low" numeric(12,5),
    "GBP/JPY_Close" numeric(10,3),
    "GBP/JPY_High" numeric(10,3),
    "GBP/JPY_Low" numeric(10,3),
    "CHF/JPY_Close" numeric(10,3),
    "CHF/JPY_High" numeric(10,3),
    "CHF/JPY_Low" numeric(10,3),
    "GBP/CHF_Close" numeric(12,5),
    "GBP/CHF_High" numeric(12,5),
    "GBP/CHF_Low" numeric(12,5),
    "NZD/USD_Close" numeric(12,5),
    "NZD/USD_High" numeric(12,5),
    "NZD/USD_Low" numeric(12,5),
    id integer NOT NULL
);


ALTER TABLE public.forex OWNER TO postgres;

--
-- TOC entry 174 (class 1259 OID 41468)
-- Name: forex_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE forex_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forex_id_seq OWNER TO postgres;

--
-- TOC entry 2053 (class 0 OID 0)
-- Dependencies: 174
-- Name: forex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE forex_id_seq OWNED BY forex.id;


--
-- TOC entry 172 (class 1259 OID 41397)
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stocks_id_seq OWNER TO postgres;

--
-- TOC entry 2054 (class 0 OID 0)
-- Dependencies: 172
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stocks_id_seq OWNED BY stocks.id;


--
-- TOC entry 178 (class 1259 OID 41782)
-- Name: tmpinstr; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tmpinstr (
    instrument text
);


ALTER TABLE public.tmpinstr OWNER TO postgres;

--
-- TOC entry 1913 (class 2604 OID 41470)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forex ALTER COLUMN id SET DEFAULT nextval('forex_id_seq'::regclass);


--
-- TOC entry 1912 (class 2604 OID 41399)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stocks ALTER COLUMN id SET DEFAULT nextval('stocks_id_seq'::regclass);


--
-- TOC entry 1929 (class 2606 OID 41894)
-- Name: PK_instrument; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY downloadinstruments
    ADD CONSTRAINT "PK_instrument" PRIMARY KEY (instrument);


--
-- TOC entry 1925 (class 2606 OID 41476)
-- Name: forex_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY forex
    ADD CONSTRAINT forex_pkey PRIMARY KEY (id);


--
-- TOC entry 1927 (class 2606 OID 41766)
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dataminestocks
    ADD CONSTRAINT id PRIMARY KEY (stockname);


--
-- TOC entry 1920 (class 2606 OID 41407)
-- Name: stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- TOC entry 1923 (class 1259 OID 41467)
-- Name: forex_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX forex_date_idx ON forex USING btree (date);


--
-- TOC entry 1917 (class 1259 OID 42015)
-- Name: stocks_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_date_idx ON stocks USING btree (date);


--
-- TOC entry 1918 (class 1259 OID 41408)
-- Name: stocks_date_stock_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_date_stock_idx ON stocks USING btree (date, stock);


--
-- TOC entry 1921 (class 1259 OID 41414)
-- Name: stocks_stock_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_stock_date_idx ON stocks USING btree (stock, date);


--
-- TOC entry 1922 (class 1259 OID 42014)
-- Name: stocks_stock_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_stock_idx ON stocks USING btree (stock);


--
-- TOC entry 2047 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-01-24 21:43:42 AEDT

--
-- PostgreSQL database dump complete
--

