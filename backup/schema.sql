--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.11
-- Dumped by pg_dump version 9.3.11
-- Started on 2016-02-16 23:17:40 AEDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 2090 (class 1262 OID 12066)
-- Dependencies: 2089
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 1 (class 3079 OID 11787)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2093 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 561 (class 1247 OID 41426)
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
-- TOC entry 577 (class 1247 OID 42116)
-- Name: dm_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE dm_type AS (
	a1 double precision,
	a2 double precision,
	a3 double precision,
	a4 double precision,
	a5 double precision,
	a6 double precision,
	aord_a1 double precision,
	aord_a2 double precision,
	aord_a3 double precision,
	aord_a4 double precision,
	aord_a5 double precision,
	aord_a6 double precision,
	n225_a1 double precision,
	n225_a2 double precision,
	n225_a3 double precision,
	n225_a4 double precision,
	n225_a5 double precision,
	n225_a6 double precision,
	ndx_a1 double precision,
	ndx_a2 double precision,
	ndx_a3 double precision,
	ndx_a4 double precision,
	ndx_a5 double precision,
	ndx_a6 double precision,
	dji_a1 double precision,
	dji_a2 double precision,
	dji_a3 double precision,
	dji_a4 double precision,
	dji_a5 double precision,
	dji_a6 double precision,
	ftse_a1 double precision,
	ftse_a2 double precision,
	ftse_a3 double precision,
	ftse_a4 double precision,
	ftse_a5 double precision,
	ftse_a6 double precision,
	gdaxi_a1 double precision,
	gdaxi_a2 double precision,
	gdaxi_a3 double precision,
	gdaxi_a4 double precision,
	gdaxi_a5 double precision,
	gdaxi_a6 double precision,
	ssec_a1 double precision,
	ssec_a2 double precision,
	ssec_a3 double precision,
	ssec_a4 double precision,
	ssec_a5 double precision,
	ssec_a6 double precision,
	hsi_a1 double precision,
	hsi_a2 double precision,
	hsi_a3 double precision,
	hsi_a4 double precision,
	hsi_a5 double precision,
	hsi_a6 double precision,
	bsesn_a1 double precision,
	bsesn_a2 double precision,
	bsesn_a3 double precision,
	bsesn_a4 double precision,
	bsesn_a5 double precision,
	bsesn_a6 double precision,
	jkse_a1 double precision,
	jkse_a2 double precision,
	jkse_a3 double precision,
	jkse_a4 double precision,
	jkse_a5 double precision,
	jkse_a6 double precision,
	nz50_a1 double precision,
	nz50_a2 double precision,
	nz50_a3 double precision,
	nz50_a4 double precision,
	nz50_a5 double precision,
	nz50_a6 double precision,
	sti_a1 double precision,
	sti_a2 double precision,
	sti_a3 double precision,
	sti_a4 double precision,
	sti_a5 double precision,
	sti_a6 double precision,
	ks11_a1 double precision,
	ks11_a2 double precision,
	ks11_a3 double precision,
	ks11_a4 double precision,
	ks11_a5 double precision,
	ks11_a6 double precision,
	twii_a1 double precision,
	twii_a2 double precision,
	twii_a3 double precision,
	twii_a4 double precision,
	twii_a5 double precision,
	twii_a6 double precision,
	bvsp_a1 double precision,
	bvsp_a2 double precision,
	bvsp_a3 double precision,
	bvsp_a4 double precision,
	bvsp_a5 double precision,
	bvsp_a6 double precision,
	gsptse_a1 double precision,
	gsptse_a2 double precision,
	gsptse_a3 double precision,
	gsptse_a4 double precision,
	gsptse_a5 double precision,
	gsptse_a6 double precision,
	mxx_a1 double precision,
	mxx_a2 double precision,
	mxx_a3 double precision,
	mxx_a4 double precision,
	mxx_a5 double precision,
	mxx_a6 double precision,
	gspc_a1 double precision,
	gspc_a2 double precision,
	gspc_a3 double precision,
	gspc_a4 double precision,
	gspc_a5 double precision,
	gspc_a6 double precision,
	atx_a1 double precision,
	atx_a2 double precision,
	atx_a3 double precision,
	atx_a4 double precision,
	atx_a5 double precision,
	atx_a6 double precision,
	bfx_a1 double precision,
	bfx_a2 double precision,
	bfx_a3 double precision,
	bfx_a4 double precision,
	bfx_a5 double precision,
	bfx_a6 double precision,
	fchi_a1 double precision,
	fchi_a2 double precision,
	fchi_a3 double precision,
	fchi_a4 double precision,
	fchi_a5 double precision,
	fchi_a6 double precision,
	ssmi_a1 double precision,
	ssmi_a2 double precision,
	ssmi_a3 double precision,
	ssmi_a4 double precision,
	ssmi_a5 double precision,
	ssmi_a6 double precision,
	gd_a1 double precision,
	gd_a2 double precision,
	gd_a3 double precision,
	gd_a4 double precision,
	gd_a5 double precision,
	gd_a6 double precision,
	eurusd_a1 double precision,
	eurusd_a2 double precision,
	eurusd_a3 double precision,
	eurusd_a4 double precision,
	eurusd_a5 double precision,
	eurusd_a6 double precision,
	usdjpy_a1 double precision,
	usdjpy_a2 double precision,
	usdjpy_a3 double precision,
	usdjpy_a4 double precision,
	usdjpy_a5 double precision,
	usdjpy_a6 double precision,
	usdchf_a1 double precision,
	usdchf_a2 double precision,
	usdchf_a3 double precision,
	usdchf_a4 double precision,
	usdchf_a5 double precision,
	usdchf_a6 double precision,
	gbpusd_a1 double precision,
	gbpusd_a2 double precision,
	gbpusd_a3 double precision,
	gbpusd_a4 double precision,
	gbpusd_a5 double precision,
	gbpusd_a6 double precision,
	usdcad_a1 double precision,
	usdcad_a2 double precision,
	usdcad_a3 double precision,
	usdcad_a4 double precision,
	usdcad_a5 double precision,
	usdcad_a6 double precision,
	eurgbp_a1 double precision,
	eurgbp_a2 double precision,
	eurgbp_a3 double precision,
	eurgbp_a4 double precision,
	eurgbp_a5 double precision,
	eurgbp_a6 double precision,
	eurjpy_a1 double precision,
	eurjpy_a2 double precision,
	eurjpy_a3 double precision,
	eurjpy_a4 double precision,
	eurjpy_a5 double precision,
	eurjpy_a6 double precision,
	eurchf_a1 double precision,
	eurchf_a2 double precision,
	eurchf_a3 double precision,
	eurchf_a4 double precision,
	eurchf_a5 double precision,
	eurchf_a6 double precision,
	audusd_a1 double precision,
	audusd_a2 double precision,
	audusd_a3 double precision,
	audusd_a4 double precision,
	audusd_a5 double precision,
	audusd_a6 double precision,
	gbpjpy_a1 double precision,
	gbpjpy_a2 double precision,
	gbpjpy_a3 double precision,
	gbpjpy_a4 double precision,
	gbpjpy_a5 double precision,
	gbpjpy_a6 double precision,
	chfjpy_a1 double precision,
	chfjpy_a2 double precision,
	chfjpy_a3 double precision,
	chfjpy_a4 double precision,
	chfjpy_a5 double precision,
	chfjpy_a6 double precision,
	gbpchf_a1 double precision,
	gbpchf_a2 double precision,
	gbpchf_a3 double precision,
	gbpchf_a4 double precision,
	gbpchf_a5 double precision,
	gbpchf_a6 double precision,
	nzdusd_a1 double precision,
	nzdusd_a2 double precision,
	nzdusd_a3 double precision,
	nzdusd_a4 double precision,
	nzdusd_a5 double precision,
	nzdusd_a6 double precision,
	cmd_choc_a1 double precision,
	cmd_choc_a2 double precision,
	cmd_choc_a3 double precision,
	cmd_choc_a4 double precision,
	cmd_choc_a5 double precision,
	cmd_choc_a6 double precision,
	cmd_corn_a1 double precision,
	cmd_corn_a2 double precision,
	cmd_corn_a3 double precision,
	cmd_corn_a4 double precision,
	cmd_corn_a5 double precision,
	cmd_corn_a6 double precision,
	cmd_ctnn_a1 double precision,
	cmd_ctnn_a2 double precision,
	cmd_ctnn_a3 double precision,
	cmd_ctnn_a4 double precision,
	cmd_ctnn_a5 double precision,
	cmd_ctnn_a6 double precision,
	cmd_cupm_a1 double precision,
	cmd_cupm_a2 double precision,
	cmd_cupm_a3 double precision,
	cmd_cupm_a4 double precision,
	cmd_cupm_a5 double precision,
	cmd_cupm_a6 double precision,
	cmd_foil_a1 double precision,
	cmd_foil_a2 double precision,
	cmd_foil_a3 double precision,
	cmd_foil_a4 double precision,
	cmd_foil_a5 double precision,
	cmd_foil_a6 double precision,
	cmd_gaz_a1 double precision,
	cmd_gaz_a2 double precision,
	cmd_gaz_a3 double precision,
	cmd_gaz_a4 double precision,
	cmd_gaz_a5 double precision,
	cmd_gaz_a6 double precision,
	cmd_gld_a1 double precision,
	cmd_gld_a2 double precision,
	cmd_gld_a3 double precision,
	cmd_gld_a4 double precision,
	cmd_gld_a5 double precision,
	cmd_gld_a6 double precision,
	cmd_hevy_a1 double precision,
	cmd_hevy_a2 double precision,
	cmd_hevy_a3 double precision,
	cmd_hevy_a4 double precision,
	cmd_hevy_a5 double precision,
	cmd_hevy_a6 double precision,
	cmd_ledd_a1 double precision,
	cmd_ledd_a2 double precision,
	cmd_ledd_a3 double precision,
	cmd_ledd_a4 double precision,
	cmd_ledd_a5 double precision,
	cmd_ledd_a6 double precision,
	cmd_lstk_a1 double precision,
	cmd_lstk_a2 double precision,
	cmd_lstk_a3 double precision,
	cmd_lstk_a4 double precision,
	cmd_lstk_a5 double precision,
	cmd_lstk_a6 double precision,
	cmd_nini_a1 double precision,
	cmd_nini_a2 double precision,
	cmd_nini_a3 double precision,
	cmd_nini_a4 double precision,
	cmd_nini_a5 double precision,
	cmd_nini_a6 double precision,
	cmd_oil_a1 double precision,
	cmd_oil_a2 double precision,
	cmd_oil_a3 double precision,
	cmd_oil_a4 double precision,
	cmd_oil_a5 double precision,
	cmd_oil_a6 double precision,
	cmd_pall_a1 double precision,
	cmd_pall_a2 double precision,
	cmd_pall_a3 double precision,
	cmd_pall_a4 double precision,
	cmd_pall_a5 double precision,
	cmd_pall_a6 double precision,
	cmd_pplt_a1 double precision,
	cmd_pplt_a2 double precision,
	cmd_pplt_a3 double precision,
	cmd_pplt_a4 double precision,
	cmd_pplt_a5 double precision,
	cmd_pplt_a6 double precision,
	cmd_sgar_a1 double precision,
	cmd_sgar_a2 double precision,
	cmd_sgar_a3 double precision,
	cmd_sgar_a4 double precision,
	cmd_sgar_a5 double precision,
	cmd_sgar_a6 double precision,
	cmd_slv_a1 double precision,
	cmd_slv_a2 double precision,
	cmd_slv_a3 double precision,
	cmd_slv_a4 double precision,
	cmd_slv_a5 double precision,
	cmd_slv_a6 double precision,
	cmd_soyb_a1 double precision,
	cmd_soyb_a2 double precision,
	cmd_soyb_a3 double precision,
	cmd_soyb_a4 double precision,
	cmd_soyb_a5 double precision,
	cmd_soyb_a6 double precision,
	cmd_uhn_a1 double precision,
	cmd_uhn_a2 double precision,
	cmd_uhn_a3 double precision,
	cmd_uhn_a4 double precision,
	cmd_uhn_a5 double precision,
	cmd_uhn_a6 double precision,
	dow double precision,
	week double precision,
	optexpday integer,
	prediction double precision
);


ALTER TYPE public.dm_type OWNER TO postgres;

--
-- TOC entry 211 (class 1255 OID 21934022)
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
	select "close" into firstAvailableClose from stocks
	  where
	    stock = stockname and
	    date <= dt
	  order by date desc
	  limit 1;

	-- find first available close in interval. Then take the first available below that date
	select "close" into firstAvailableCloseInterval from stocks
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
-- TOC entry 212 (class 1255 OID 21934023)
-- Name: datamine(character varying, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION datamine(stcknm character varying, ofst bigint, lmt bigint) RETURNS TABLE(a1 double precision, a2 double precision, a3 double precision, a4 double precision, a5 double precision, a6 double precision, aord_a1 double precision, aord_a2 double precision, aord_a3 double precision, aord_a4 double precision, aord_a5 double precision, aord_a6 double precision, n225_a1 double precision, n225_a2 double precision, n225_a3 double precision, n225_a4 double precision, n225_a5 double precision, n225_a6 double precision, ndx_a1 double precision, ndx_a2 double precision, ndx_a3 double precision, ndx_a4 double precision, ndx_a5 double precision, ndx_a6 double precision, dji_a1 double precision, dji_a2 double precision, dji_a3 double precision, dji_a4 double precision, dji_a5 double precision, dji_a6 double precision, ftse_a1 double precision, ftse_a2 double precision, ftse_a3 double precision, ftse_a4 double precision, ftse_a5 double precision, ftse_a6 double precision, gdaxi_a1 double precision, gdaxi_a2 double precision, gdaxi_a3 double precision, gdaxi_a4 double precision, gdaxi_a5 double precision, gdaxi_a6 double precision, ssec_a1 double precision, ssec_a2 double precision, ssec_a3 double precision, ssec_a4 double precision, ssec_a5 double precision, ssec_a6 double precision, hsi_a1 double precision, hsi_a2 double precision, hsi_a3 double precision, hsi_a4 double precision, hsi_a5 double precision, hsi_a6 double precision, bsesn_a1 double precision, bsesn_a2 double precision, bsesn_a3 double precision, bsesn_a4 double precision, bsesn_a5 double precision, bsesn_a6 double precision, jkse_a1 double precision, jkse_a2 double precision, jkse_a3 double precision, jkse_a4 double precision, jkse_a5 double precision, jkse_a6 double precision, nz50_a1 double precision, nz50_a2 double precision, nz50_a3 double precision, nz50_a4 double precision, nz50_a5 double precision, nz50_a6 double precision, sti_a1 double precision, sti_a2 double precision, sti_a3 double precision, sti_a4 double precision, sti_a5 double precision, sti_a6 double precision, ks11_a1 double precision, ks11_a2 double precision, ks11_a3 double precision, ks11_a4 double precision, ks11_a5 double precision, ks11_a6 double precision, twii_a1 double precision, twii_a2 double precision, twii_a3 double precision, twii_a4 double precision, twii_a5 double precision, twii_a6 double precision, bvsp_a1 double precision, bvsp_a2 double precision, bvsp_a3 double precision, bvsp_a4 double precision, bvsp_a5 double precision, bvsp_a6 double precision, gsptse_a1 double precision, gsptse_a2 double precision, gsptse_a3 double precision, gsptse_a4 double precision, gsptse_a5 double precision, gsptse_a6 double precision, mxx_a1 double precision, mxx_a2 double precision, mxx_a3 double precision, mxx_a4 double precision, mxx_a5 double precision, mxx_a6 double precision, gspc_a1 double precision, gspc_a2 double precision, gspc_a3 double precision, gspc_a4 double precision, gspc_a5 double precision, gspc_a6 double precision, atx_a1 double precision, atx_a2 double precision, atx_a3 double precision, atx_a4 double precision, atx_a5 double precision, atx_a6 double precision, bfx_a1 double precision, bfx_a2 double precision, bfx_a3 double precision, bfx_a4 double precision, bfx_a5 double precision, bfx_a6 double precision, fchi_a1 double precision, fchi_a2 double precision, fchi_a3 double precision, fchi_a4 double precision, fchi_a5 double precision, fchi_a6 double precision, ssmi_a1 double precision, ssmi_a2 double precision, ssmi_a3 double precision, ssmi_a4 double precision, ssmi_a5 double precision, ssmi_a6 double precision, gd_a1 double precision, gd_a2 double precision, gd_a3 double precision, gd_a4 double precision, gd_a5 double precision, gd_a6 double precision, eurusd_a1 double precision, eurusd_a2 double precision, eurusd_a3 double precision, eurusd_a4 double precision, eurusd_a5 double precision, eurusd_a6 double precision, usdjpy_a1 double precision, usdjpy_a2 double precision, usdjpy_a3 double precision, usdjpy_a4 double precision, usdjpy_a5 double precision, usdjpy_a6 double precision, usdchf_a1 double precision, usdchf_a2 double precision, usdchf_a3 double precision, usdchf_a4 double precision, usdchf_a5 double precision, usdchf_a6 double precision, gbpusd_a1 double precision, gbpusd_a2 double precision, gbpusd_a3 double precision, gbpusd_a4 double precision, gbpusd_a5 double precision, gbpusd_a6 double precision, usdcad_a1 double precision, usdcad_a2 double precision, usdcad_a3 double precision, usdcad_a4 double precision, usdcad_a5 double precision, usdcad_a6 double precision, eurgbp_a1 double precision, eurgbp_a2 double precision, eurgbp_a3 double precision, eurgbp_a4 double precision, eurgbp_a5 double precision, eurgbp_a6 double precision, eurjpy_a1 double precision, eurjpy_a2 double precision, eurjpy_a3 double precision, eurjpy_a4 double precision, eurjpy_a5 double precision, eurjpy_a6 double precision, eurchf_a1 double precision, eurchf_a2 double precision, eurchf_a3 double precision, eurchf_a4 double precision, eurchf_a5 double precision, eurchf_a6 double precision, audusd_a1 double precision, audusd_a2 double precision, audusd_a3 double precision, audusd_a4 double precision, audusd_a5 double precision, audusd_a6 double precision, gbpjpy_a1 double precision, gbpjpy_a2 double precision, gbpjpy_a3 double precision, gbpjpy_a4 double precision, gbpjpy_a5 double precision, gbpjpy_a6 double precision, chfjpy_a1 double precision, chfjpy_a2 double precision, chfjpy_a3 double precision, chfjpy_a4 double precision, chfjpy_a5 double precision, chfjpy_a6 double precision, gbpchf_a1 double precision, gbpchf_a2 double precision, gbpchf_a3 double precision, gbpchf_a4 double precision, gbpchf_a5 double precision, gbpchf_a6 double precision, nzdusd_a1 double precision, nzdusd_a2 double precision, nzdusd_a3 double precision, nzdusd_a4 double precision, nzdusd_a5 double precision, nzdusd_a6 double precision, cmd_choc_a1 double precision, cmd_choc_a2 double precision, cmd_choc_a3 double precision, cmd_choc_a4 double precision, cmd_choc_a5 double precision, cmd_choc_a6 double precision, cmd_corn_a1 double precision, cmd_corn_a2 double precision, cmd_corn_a3 double precision, cmd_corn_a4 double precision, cmd_corn_a5 double precision, cmd_corn_a6 double precision, cmd_ctnn_a1 double precision, cmd_ctnn_a2 double precision, cmd_ctnn_a3 double precision, cmd_ctnn_a4 double precision, cmd_ctnn_a5 double precision, cmd_ctnn_a6 double precision, cmd_cupm_a1 double precision, cmd_cupm_a2 double precision, cmd_cupm_a3 double precision, cmd_cupm_a4 double precision, cmd_cupm_a5 double precision, cmd_cupm_a6 double precision, cmd_foil_a1 double precision, cmd_foil_a2 double precision, cmd_foil_a3 double precision, cmd_foil_a4 double precision, cmd_foil_a5 double precision, cmd_foil_a6 double precision, cmd_gaz_a1 double precision, cmd_gaz_a2 double precision, cmd_gaz_a3 double precision, cmd_gaz_a4 double precision, cmd_gaz_a5 double precision, cmd_gaz_a6 double precision, cmd_gld_a1 double precision, cmd_gld_a2 double precision, cmd_gld_a3 double precision, cmd_gld_a4 double precision, cmd_gld_a5 double precision, cmd_gld_a6 double precision, cmd_hevy_a1 double precision, cmd_hevy_a2 double precision, cmd_hevy_a3 double precision, cmd_hevy_a4 double precision, cmd_hevy_a5 double precision, cmd_hevy_a6 double precision, cmd_ledd_a1 double precision, cmd_ledd_a2 double precision, cmd_ledd_a3 double precision, cmd_ledd_a4 double precision, cmd_ledd_a5 double precision, cmd_ledd_a6 double precision, cmd_lstk_a1 double precision, cmd_lstk_a2 double precision, cmd_lstk_a3 double precision, cmd_lstk_a4 double precision, cmd_lstk_a5 double precision, cmd_lstk_a6 double precision, cmd_nini_a1 double precision, cmd_nini_a2 double precision, cmd_nini_a3 double precision, cmd_nini_a4 double precision, cmd_nini_a5 double precision, cmd_nini_a6 double precision, cmd_oil_a1 double precision, cmd_oil_a2 double precision, cmd_oil_a3 double precision, cmd_oil_a4 double precision, cmd_oil_a5 double precision, cmd_oil_a6 double precision, cmd_pall_a1 double precision, cmd_pall_a2 double precision, cmd_pall_a3 double precision, cmd_pall_a4 double precision, cmd_pall_a5 double precision, cmd_pall_a6 double precision, cmd_pplt_a1 double precision, cmd_pplt_a2 double precision, cmd_pplt_a3 double precision, cmd_pplt_a4 double precision, cmd_pplt_a5 double precision, cmd_pplt_a6 double precision, cmd_sgar_a1 double precision, cmd_sgar_a2 double precision, cmd_sgar_a3 double precision, cmd_sgar_a4 double precision, cmd_sgar_a5 double precision, cmd_sgar_a6 double precision, cmd_slv_a1 double precision, cmd_slv_a2 double precision, cmd_slv_a3 double precision, cmd_slv_a4 double precision, cmd_slv_a5 double precision, cmd_slv_a6 double precision, cmd_soyb_a1 double precision, cmd_soyb_a2 double precision, cmd_soyb_a3 double precision, cmd_soyb_a4 double precision, cmd_soyb_a5 double precision, cmd_soyb_a6 double precision, cmd_uhn_a1 double precision, cmd_uhn_a2 double precision, cmd_uhn_a3 double precision, cmd_uhn_a4 double precision, cmd_uhn_a5 double precision, cmd_uhn_a6 double precision, dow double precision, week double precision, optexpday integer, prediction double precision)
    LANGUAGE sql
    AS $$
      SELECT 
		(stockavg).a1 as a1,
		(stockavg).a2 as a2,
		(stockavg).a3 as a3,
		(stockavg).a4 as a4,
		(stockavg).a5 as a5,
		(stockavg).a6 as a6,
		(aord).a1 as aord_a1,
		(aord).a2 as aord_a2,
		(aord).a3 as aord_a3,
		(aord).a4 as aord_a4,
		(aord).a5 as aord_a5,
		(aord).a6 as aord_a6,
		(n225).a1 as n225_a1,
		(n225).a2 as n225_a2,
		(n225).a3 as n225_a3,
		(n225).a4 as n225_a4,
		(n225).a5 as n225_a5,
		(n225).a6 as n225_a6,
		(ndx).a1 as ndx_a1,
		(ndx).a2 as ndx_a2,
		(ndx).a3 as ndx_a3,
		(ndx).a4 as ndx_a4,
		(ndx).a5 as ndx_a5,
		(ndx).a6 as ndx_a6,
		(dji).a1 as dji_a1,
		(dji).a2 as dji_a2,
		(dji).a3 as dji_a3,
		(dji).a4 as dji_a4,
		(dji).a5 as dji_a5,
		(dji).a6 as dji_a6,
		(ftse).a1 as ftse_a1,
		(ftse).a2 as ftse_a2,
		(ftse).a3 as ftse_a3,
		(ftse).a4 as ftse_a4,
		(ftse).a5 as ftse_a5,
		(ftse).a6 as ftse_a6,
		(gdaxi).a1 as gdaxi_a1,
		(gdaxi).a2 as gdaxi_a2,
		(gdaxi).a3 as gdaxi_a3,
		(gdaxi).a4 as gdaxi_a4,
		(gdaxi).a5 as gdaxi_a5,
		(gdaxi).a6 as gdaxi_a6,
		(ssec).a1 as ssec_a1,
		(ssec).a2 as ssec_a2,
		(ssec).a3 as ssec_a3,
		(ssec).a4 as ssec_a4,
		(ssec).a5 as ssec_a5,
		(ssec).a6 as ssec_a6,
		(hsi).a1 as hsi_a1,
		(hsi).a2 as hsi_a2,
		(hsi).a3 as hsi_a3,
		(hsi).a4 as hsi_a4,
		(hsi).a5 as hsi_a5,
		(hsi).a6 as hsi_a6,
		(bsesn).a1 as bsesn_a1,
		(bsesn).a2 as bsesn_a2,
		(bsesn).a3 as bsesn_a3,
		(bsesn).a4 as bsesn_a4,
		(bsesn).a5 as bsesn_a5,
		(bsesn).a6 as bsesn_a6,
		(jkse).a1 as jkse_a1,
		(jkse).a2 as jkse_a2,
		(jkse).a3 as jkse_a3,
		(jkse).a4 as jkse_a4,
		(jkse).a5 as jkse_a5,
		(jkse).a6 as jkse_a6,
		(nz50).a1 as nz50_a1,
		(nz50).a2 as nz50_a2,
		(nz50).a3 as nz50_a3,
		(nz50).a4 as nz50_a4,
		(nz50).a5 as nz50_a5,
		(nz50).a6 as nz50_a6,
		(sti).a1 as sti_a1,
		(sti).a2 as sti_a2,
		(sti).a3 as sti_a3,
		(sti).a4 as sti_a4,
		(sti).a5 as sti_a5,
		(sti).a6 as sti_a6,
		(ks11).a1 as ks11_a1,
		(ks11).a2 as ks11_a2,
		(ks11).a3 as ks11_a3,
		(ks11).a4 as ks11_a4,
		(ks11).a5 as ks11_a5,
		(ks11).a6 as ks11_a6,
		(twii).a1 as twii_a1,
		(twii).a2 as twii_a2,
		(twii).a3 as twii_a3,
		(twii).a4 as twii_a4,
		(twii).a5 as twii_a5,
		(twii).a6 as twii_a6,
		(bvsp).a1 as bvsp_a1,
		(bvsp).a2 as bvsp_a2,
		(bvsp).a3 as bvsp_a3,
		(bvsp).a4 as bvsp_a4,
		(bvsp).a5 as bvsp_a5,
		(bvsp).a6 as bvsp_a6,
		(gsptse).a1 as gsptse_a1,
		(gsptse).a2 as gsptse_a2,
		(gsptse).a3 as gsptse_a3,
		(gsptse).a4 as gsptse_a4,
		(gsptse).a5 as gsptse_a5,
		(gsptse).a6 as gsptse_a6,
		(mxx).a1 as mxx_a1,
		(mxx).a2 as mxx_a2,
		(mxx).a3 as mxx_a3,
		(mxx).a4 as mxx_a4,
		(mxx).a5 as mxx_a5,
		(mxx).a6 as mxx_a6,
		(gspc).a1 as gspc_a1,
		(gspc).a2 as gspc_a2,
		(gspc).a3 as gspc_a3,
		(gspc).a4 as gspc_a4,
		(gspc).a5 as gspc_a5,
		(gspc).a6 as gspc_a6,
		(atx).a1 as atx_a1,
		(atx).a2 as atx_a2,
		(atx).a3 as atx_a3,
		(atx).a4 as atx_a4,
		(atx).a5 as atx_a5,
		(atx).a6 as atx_a6,
		(bfx).a1 as bfx_a1,
		(bfx).a2 as bfx_a2,
		(bfx).a3 as bfx_a3,
		(bfx).a4 as bfx_a4,
		(bfx).a5 as bfx_a5,
		(bfx).a6 as bfx_a6,
		(fchi).a1 as fchi_a1,
		(fchi).a2 as fchi_a2,
		(fchi).a3 as fchi_a3,
		(fchi).a4 as fchi_a4,
		(fchi).a5 as fchi_a5,
		(fchi).a6 as fchi_a6,
		(ssmi).a1 as ssmi_a1,
		(ssmi).a2 as ssmi_a2,
		(ssmi).a3 as ssmi_a3,
		(ssmi).a4 as ssmi_a4,
		(ssmi).a5 as ssmi_a5,
		(ssmi).a6 as ssmi_a6,
		(gd).a1 as gd_a1,
		(gd).a2 as gd_a2,
		(gd).a3 as gd_a3,
		(gd).a4 as gd_a4,
		(gd).a5 as gd_a5,
		(gd).a6 as gd_a6,
		(eurusd).a1 as eurusd_a1,
		(eurusd).a2 as eurusd_a2,
		(eurusd).a3 as eurusd_a3,
		(eurusd).a4 as eurusd_a4,
		(eurusd).a5 as eurusd_a5,
		(eurusd).a6 as eurusd_a6,
		(usdjpy).a1 as usdjpy_a1,
		(usdjpy).a2 as usdjpy_a2,
		(usdjpy).a3 as usdjpy_a3,
		(usdjpy).a4 as usdjpy_a4,
		(usdjpy).a5 as usdjpy_a5,
		(usdjpy).a6 as usdjpy_a6,
		(usdchf).a1 as usdchf_a1,
		(usdchf).a2 as usdchf_a2,
		(usdchf).a3 as usdchf_a3,
		(usdchf).a4 as usdchf_a4,
		(usdchf).a5 as usdchf_a5,
		(usdchf).a6 as usdchf_a6,
		(gbpusd).a1 as gbpusd_a1,
		(gbpusd).a2 as gbpusd_a2,
		(gbpusd).a3 as gbpusd_a3,
		(gbpusd).a4 as gbpusd_a4,
		(gbpusd).a5 as gbpusd_a5,
		(gbpusd).a6 as gbpusd_a6,
		(usdcad).a1 as usdcad_a1,
		(usdcad).a2 as usdcad_a2,
		(usdcad).a3 as usdcad_a3,
		(usdcad).a4 as usdcad_a4,
		(usdcad).a5 as usdcad_a5,
		(usdcad).a6 as usdcad_a6,
		(eurgbp).a1 as eurgbp_a1,
		(eurgbp).a2 as eurgbp_a2,
		(eurgbp).a3 as eurgbp_a3,
		(eurgbp).a4 as eurgbp_a4,
		(eurgbp).a5 as eurgbp_a5,
		(eurgbp).a6 as eurgbp_a6,
		(eurjpy).a1 as eurjpy_a1,
		(eurjpy).a2 as eurjpy_a2,
		(eurjpy).a3 as eurjpy_a3,
		(eurjpy).a4 as eurjpy_a4,
		(eurjpy).a5 as eurjpy_a5,
		(eurjpy).a6 as eurjpy_a6,
		(eurchf).a1 as eurchf_a1,
		(eurchf).a2 as eurchf_a2,
		(eurchf).a3 as eurchf_a3,
		(eurchf).a4 as eurchf_a4,
		(eurchf).a5 as eurchf_a5,
		(eurchf).a6 as eurchf_a6,
		(audusd).a1 as audusd_a1,
		(audusd).a2 as audusd_a2,
		(audusd).a3 as audusd_a3,
		(audusd).a4 as audusd_a4,
		(audusd).a5 as audusd_a5,
		(audusd).a6 as audusd_a6,
		(gbpjpy).a1 as gbpjpy_a1,
		(gbpjpy).a2 as gbpjpy_a2,
		(gbpjpy).a3 as gbpjpy_a3,
		(gbpjpy).a4 as gbpjpy_a4,
		(gbpjpy).a5 as gbpjpy_a5,
		(gbpjpy).a6 as gbpjpy_a6,
		(chfjpy).a1 as chfjpy_a1,
		(chfjpy).a2 as chfjpy_a2,
		(chfjpy).a3 as chfjpy_a3,
		(chfjpy).a4 as chfjpy_a4,
		(chfjpy).a5 as chfjpy_a5,
		(chfjpy).a6 as chfjpy_a6,
		(gbpchf).a1 as gbpchf_a1,
		(gbpchf).a2 as gbpchf_a2,
		(gbpchf).a3 as gbpchf_a3,
		(gbpchf).a4 as gbpchf_a4,
		(gbpchf).a5 as gbpchf_a5,
		(gbpchf).a6 as gbpchf_a6,
		(nzdusd).a1 as nzdusd_a1,
		(nzdusd).a2 as nzdusd_a2,
		(nzdusd).a3 as nzdusd_a3,
		(nzdusd).a4 as nzdusd_a4,
		(nzdusd).a5 as nzdusd_a5,
		(nzdusd).a6 as nzdusd_a6,
		(cmd_choc).a1 as cmd_choc_a1,
		(cmd_choc).a2 as cmd_choc_a2,
		(cmd_choc).a3 as cmd_choc_a3,
		(cmd_choc).a4 as cmd_choc_a4,
		(cmd_choc).a5 as cmd_choc_a5,
		(cmd_choc).a6 as cmd_choc_a6,
		(cmd_corn).a1 as cmd_corn_a1,
		(cmd_corn).a2 as cmd_corn_a2,
		(cmd_corn).a3 as cmd_corn_a3,
		(cmd_corn).a4 as cmd_corn_a4,
		(cmd_corn).a5 as cmd_corn_a5,
		(cmd_corn).a6 as cmd_corn_a6,
		(cmd_ctnn).a1 as cmd_ctnn_a1,
		(cmd_ctnn).a2 as cmd_ctnn_a2,
		(cmd_ctnn).a3 as cmd_ctnn_a3,
		(cmd_ctnn).a4 as cmd_ctnn_a4,
		(cmd_ctnn).a5 as cmd_ctnn_a5,
		(cmd_ctnn).a6 as cmd_ctnn_a6,
		(cmd_cupm).a1 as cmd_cupm_a1,
		(cmd_cupm).a2 as cmd_cupm_a2,
		(cmd_cupm).a3 as cmd_cupm_a3,
		(cmd_cupm).a4 as cmd_cupm_a4,
		(cmd_cupm).a5 as cmd_cupm_a5,
		(cmd_cupm).a6 as cmd_cupm_a6,
		(cmd_foil).a1 as cmd_foil_a1,
		(cmd_foil).a2 as cmd_foil_a2,
		(cmd_foil).a3 as cmd_foil_a3,
		(cmd_foil).a4 as cmd_foil_a4,
		(cmd_foil).a5 as cmd_foil_a5,
		(cmd_foil).a6 as cmd_foil_a6,
		(cmd_gaz).a1 as cmd_gaz_a1,
		(cmd_gaz).a2 as cmd_gaz_a2,
		(cmd_gaz).a3 as cmd_gaz_a3,
		(cmd_gaz).a4 as cmd_gaz_a4,
		(cmd_gaz).a5 as cmd_gaz_a5,
		(cmd_gaz).a6 as cmd_gaz_a6,
		(cmd_gld).a1 as cmd_gld_a1,
		(cmd_gld).a2 as cmd_gld_a2,
		(cmd_gld).a3 as cmd_gld_a3,
		(cmd_gld).a4 as cmd_gld_a4,
		(cmd_gld).a5 as cmd_gld_a5,
		(cmd_gld).a6 as cmd_gld_a6,
		(cmd_hevy).a1 as cmd_hevy_a1,
		(cmd_hevy).a2 as cmd_hevy_a2,
		(cmd_hevy).a3 as cmd_hevy_a3,
		(cmd_hevy).a4 as cmd_hevy_a4,
		(cmd_hevy).a5 as cmd_hevy_a5,
		(cmd_hevy).a6 as cmd_hevy_a6,
		(cmd_ledd).a1 as cmd_ledd_a1,
		(cmd_ledd).a2 as cmd_ledd_a2,
		(cmd_ledd).a3 as cmd_ledd_a3,
		(cmd_ledd).a4 as cmd_ledd_a4,
		(cmd_ledd).a5 as cmd_ledd_a5,
		(cmd_ledd).a6 as cmd_ledd_a6,
		(cmd_lstk).a1 as cmd_lstk_a1,
		(cmd_lstk).a2 as cmd_lstk_a2,
		(cmd_lstk).a3 as cmd_lstk_a3,
		(cmd_lstk).a4 as cmd_lstk_a4,
		(cmd_lstk).a5 as cmd_lstk_a5,
		(cmd_lstk).a6 as cmd_lstk_a6,
		(cmd_nini).a1 as cmd_nini_a1,
		(cmd_nini).a2 as cmd_nini_a2,
		(cmd_nini).a3 as cmd_nini_a3,
		(cmd_nini).a4 as cmd_nini_a4,
		(cmd_nini).a5 as cmd_nini_a5,
		(cmd_nini).a6 as cmd_nini_a6,
		(cmd_oil).a1 as cmd_oil_a1,
		(cmd_oil).a2 as cmd_oil_a2,
		(cmd_oil).a3 as cmd_oil_a3,
		(cmd_oil).a4 as cmd_oil_a4,
		(cmd_oil).a5 as cmd_oil_a5,
		(cmd_oil).a6 as cmd_oil_a6,
		(cmd_pall).a1 as cmd_pall_a1,
		(cmd_pall).a2 as cmd_pall_a2,
		(cmd_pall).a3 as cmd_pall_a3,
		(cmd_pall).a4 as cmd_pall_a4,
		(cmd_pall).a5 as cmd_pall_a5,
		(cmd_pall).a6 as cmd_pall_a6,
		(cmd_pplt).a1 as cmd_pplt_a1,
		(cmd_pplt).a2 as cmd_pplt_a2,
		(cmd_pplt).a3 as cmd_pplt_a3,
		(cmd_pplt).a4 as cmd_pplt_a4,
		(cmd_pplt).a5 as cmd_pplt_a5,
		(cmd_pplt).a6 as cmd_pplt_a6,
		(cmd_sgar).a1 as cmd_sgar_a1,
		(cmd_sgar).a2 as cmd_sgar_a2,
		(cmd_sgar).a3 as cmd_sgar_a3,
		(cmd_sgar).a4 as cmd_sgar_a4,
		(cmd_sgar).a5 as cmd_sgar_a5,
		(cmd_sgar).a6 as cmd_sgar_a6,
		(cmd_slv).a1 as cmd_slv_a1,
		(cmd_slv).a2 as cmd_slv_a2,
		(cmd_slv).a3 as cmd_slv_a3,
		(cmd_slv).a4 as cmd_slv_a4,
		(cmd_slv).a5 as cmd_slv_a5,
		(cmd_slv).a6 as cmd_slv_a6,
		(cmd_soyb).a1 as cmd_soyb_a1,
		(cmd_soyb).a2 as cmd_soyb_a2,
		(cmd_soyb).a3 as cmd_soyb_a3,
		(cmd_soyb).a4 as cmd_soyb_a4,
		(cmd_soyb).a5 as cmd_soyb_a5,
		(cmd_soyb).a6 as cmd_soyb_a6,
		(cmd_uhn).a1 as cmd_uhn_a1,
		(cmd_uhn).a2 as cmd_uhn_a2,
		(cmd_uhn).a3 as cmd_uhn_a3,
		(cmd_uhn).a4 as cmd_uhn_a4,
		(cmd_uhn).a5 as cmd_uhn_a5,
		(cmd_uhn).a6 as cmd_uhn_a6,
		dow as dow,
		week as week,
		optexpday as optexpday,
		prediction as prediction
	FROM datamining_stocks_view v
		WHERE v.stockname=stcknm
		offset ofst
		limit lmt
    $$;


ALTER FUNCTION public.datamine(stcknm character varying, ofst bigint, lmt bigint) OWNER TO postgres;

--
-- TOC entry 213 (class 1255 OID 21934025)
-- Name: datamine1(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION datamine1(stcknm character varying) RETURNS TABLE(a1 double precision, a2 double precision, a3 double precision, a4 double precision, a5 double precision, a6 double precision, aord_a1 double precision, aord_a2 double precision, aord_a3 double precision, aord_a4 double precision, aord_a5 double precision, aord_a6 double precision, n225_a1 double precision, n225_a2 double precision, n225_a3 double precision, n225_a4 double precision, n225_a5 double precision, n225_a6 double precision, ndx_a1 double precision, ndx_a2 double precision, ndx_a3 double precision, ndx_a4 double precision, ndx_a5 double precision, ndx_a6 double precision, dji_a1 double precision, dji_a2 double precision, dji_a3 double precision, dji_a4 double precision, dji_a5 double precision, dji_a6 double precision, ftse_a1 double precision, ftse_a2 double precision, ftse_a3 double precision, ftse_a4 double precision, ftse_a5 double precision, ftse_a6 double precision, gdaxi_a1 double precision, gdaxi_a2 double precision, gdaxi_a3 double precision, gdaxi_a4 double precision, gdaxi_a5 double precision, gdaxi_a6 double precision, ssec_a1 double precision, ssec_a2 double precision, ssec_a3 double precision, ssec_a4 double precision, ssec_a5 double precision, ssec_a6 double precision, hsi_a1 double precision, hsi_a2 double precision, hsi_a3 double precision, hsi_a4 double precision, hsi_a5 double precision, hsi_a6 double precision, bsesn_a1 double precision, bsesn_a2 double precision, bsesn_a3 double precision, bsesn_a4 double precision, bsesn_a5 double precision, bsesn_a6 double precision, jkse_a1 double precision, jkse_a2 double precision, jkse_a3 double precision, jkse_a4 double precision, jkse_a5 double precision, jkse_a6 double precision, nz50_a1 double precision, nz50_a2 double precision, nz50_a3 double precision, nz50_a4 double precision, nz50_a5 double precision, nz50_a6 double precision, sti_a1 double precision, sti_a2 double precision, sti_a3 double precision, sti_a4 double precision, sti_a5 double precision, sti_a6 double precision, ks11_a1 double precision, ks11_a2 double precision, ks11_a3 double precision, ks11_a4 double precision, ks11_a5 double precision, ks11_a6 double precision, twii_a1 double precision, twii_a2 double precision, twii_a3 double precision, twii_a4 double precision, twii_a5 double precision, twii_a6 double precision, bvsp_a1 double precision, bvsp_a2 double precision, bvsp_a3 double precision, bvsp_a4 double precision, bvsp_a5 double precision, bvsp_a6 double precision, gsptse_a1 double precision, gsptse_a2 double precision, gsptse_a3 double precision, gsptse_a4 double precision, gsptse_a5 double precision, gsptse_a6 double precision, mxx_a1 double precision, mxx_a2 double precision, mxx_a3 double precision, mxx_a4 double precision, mxx_a5 double precision, mxx_a6 double precision, gspc_a1 double precision, gspc_a2 double precision, gspc_a3 double precision, gspc_a4 double precision, gspc_a5 double precision, gspc_a6 double precision, atx_a1 double precision, atx_a2 double precision, atx_a3 double precision, atx_a4 double precision, atx_a5 double precision, atx_a6 double precision, bfx_a1 double precision, bfx_a2 double precision, bfx_a3 double precision, bfx_a4 double precision, bfx_a5 double precision, bfx_a6 double precision, fchi_a1 double precision, fchi_a2 double precision, fchi_a3 double precision, fchi_a4 double precision, fchi_a5 double precision, fchi_a6 double precision, ssmi_a1 double precision, ssmi_a2 double precision, ssmi_a3 double precision, ssmi_a4 double precision, ssmi_a5 double precision, ssmi_a6 double precision, gd_a1 double precision, gd_a2 double precision, gd_a3 double precision, gd_a4 double precision, gd_a5 double precision, gd_a6 double precision, eurusd_a1 double precision, eurusd_a2 double precision, eurusd_a3 double precision, eurusd_a4 double precision, eurusd_a5 double precision, eurusd_a6 double precision, usdjpy_a1 double precision, usdjpy_a2 double precision, usdjpy_a3 double precision, usdjpy_a4 double precision, usdjpy_a5 double precision, usdjpy_a6 double precision, usdchf_a1 double precision, usdchf_a2 double precision, usdchf_a3 double precision, usdchf_a4 double precision, usdchf_a5 double precision, usdchf_a6 double precision, gbpusd_a1 double precision, gbpusd_a2 double precision, gbpusd_a3 double precision, gbpusd_a4 double precision, gbpusd_a5 double precision, gbpusd_a6 double precision, usdcad_a1 double precision, usdcad_a2 double precision, usdcad_a3 double precision, usdcad_a4 double precision, usdcad_a5 double precision, usdcad_a6 double precision, eurgbp_a1 double precision, eurgbp_a2 double precision, eurgbp_a3 double precision, eurgbp_a4 double precision, eurgbp_a5 double precision, eurgbp_a6 double precision, eurjpy_a1 double precision, eurjpy_a2 double precision, eurjpy_a3 double precision, eurjpy_a4 double precision, eurjpy_a5 double precision, eurjpy_a6 double precision, eurchf_a1 double precision, eurchf_a2 double precision, eurchf_a3 double precision, eurchf_a4 double precision, eurchf_a5 double precision, eurchf_a6 double precision, audusd_a1 double precision, audusd_a2 double precision, audusd_a3 double precision, audusd_a4 double precision, audusd_a5 double precision, audusd_a6 double precision, gbpjpy_a1 double precision, gbpjpy_a2 double precision, gbpjpy_a3 double precision, gbpjpy_a4 double precision, gbpjpy_a5 double precision, gbpjpy_a6 double precision, chfjpy_a1 double precision, chfjpy_a2 double precision, chfjpy_a3 double precision, chfjpy_a4 double precision, chfjpy_a5 double precision, chfjpy_a6 double precision, gbpchf_a1 double precision, gbpchf_a2 double precision, gbpchf_a3 double precision, gbpchf_a4 double precision, gbpchf_a5 double precision, gbpchf_a6 double precision, nzdusd_a1 double precision, nzdusd_a2 double precision, nzdusd_a3 double precision, nzdusd_a4 double precision, nzdusd_a5 double precision, nzdusd_a6 double precision, cmd_choc_a1 double precision, cmd_choc_a2 double precision, cmd_choc_a3 double precision, cmd_choc_a4 double precision, cmd_choc_a5 double precision, cmd_choc_a6 double precision, cmd_corn_a1 double precision, cmd_corn_a2 double precision, cmd_corn_a3 double precision, cmd_corn_a4 double precision, cmd_corn_a5 double precision, cmd_corn_a6 double precision, cmd_ctnn_a1 double precision, cmd_ctnn_a2 double precision, cmd_ctnn_a3 double precision, cmd_ctnn_a4 double precision, cmd_ctnn_a5 double precision, cmd_ctnn_a6 double precision, cmd_cupm_a1 double precision, cmd_cupm_a2 double precision, cmd_cupm_a3 double precision, cmd_cupm_a4 double precision, cmd_cupm_a5 double precision, cmd_cupm_a6 double precision, cmd_foil_a1 double precision, cmd_foil_a2 double precision, cmd_foil_a3 double precision, cmd_foil_a4 double precision, cmd_foil_a5 double precision, cmd_foil_a6 double precision, cmd_gaz_a1 double precision, cmd_gaz_a2 double precision, cmd_gaz_a3 double precision, cmd_gaz_a4 double precision, cmd_gaz_a5 double precision, cmd_gaz_a6 double precision, cmd_gld_a1 double precision, cmd_gld_a2 double precision, cmd_gld_a3 double precision, cmd_gld_a4 double precision, cmd_gld_a5 double precision, cmd_gld_a6 double precision, cmd_hevy_a1 double precision, cmd_hevy_a2 double precision, cmd_hevy_a3 double precision, cmd_hevy_a4 double precision, cmd_hevy_a5 double precision, cmd_hevy_a6 double precision, cmd_ledd_a1 double precision, cmd_ledd_a2 double precision, cmd_ledd_a3 double precision, cmd_ledd_a4 double precision, cmd_ledd_a5 double precision, cmd_ledd_a6 double precision, cmd_lstk_a1 double precision, cmd_lstk_a2 double precision, cmd_lstk_a3 double precision, cmd_lstk_a4 double precision, cmd_lstk_a5 double precision, cmd_lstk_a6 double precision, cmd_nini_a1 double precision, cmd_nini_a2 double precision, cmd_nini_a3 double precision, cmd_nini_a4 double precision, cmd_nini_a5 double precision, cmd_nini_a6 double precision, cmd_oil_a1 double precision, cmd_oil_a2 double precision, cmd_oil_a3 double precision, cmd_oil_a4 double precision, cmd_oil_a5 double precision, cmd_oil_a6 double precision, cmd_pall_a1 double precision, cmd_pall_a2 double precision, cmd_pall_a3 double precision, cmd_pall_a4 double precision, cmd_pall_a5 double precision, cmd_pall_a6 double precision, cmd_pplt_a1 double precision, cmd_pplt_a2 double precision, cmd_pplt_a3 double precision, cmd_pplt_a4 double precision, cmd_pplt_a5 double precision, cmd_pplt_a6 double precision, cmd_sgar_a1 double precision, cmd_sgar_a2 double precision, cmd_sgar_a3 double precision, cmd_sgar_a4 double precision, cmd_sgar_a5 double precision, cmd_sgar_a6 double precision, cmd_slv_a1 double precision, cmd_slv_a2 double precision, cmd_slv_a3 double precision, cmd_slv_a4 double precision, cmd_slv_a5 double precision, cmd_slv_a6 double precision, cmd_soyb_a1 double precision, cmd_soyb_a2 double precision, cmd_soyb_a3 double precision, cmd_soyb_a4 double precision, cmd_soyb_a5 double precision, cmd_soyb_a6 double precision, cmd_uhn_a1 double precision, cmd_uhn_a2 double precision, cmd_uhn_a3 double precision, cmd_uhn_a4 double precision, cmd_uhn_a5 double precision, cmd_uhn_a6 double precision, dow double precision, week double precision, optexpday integer, prediction double precision)
    LANGUAGE sql
    AS $$
      SELECT 
		(stockavg).a1 as a1,
		(stockavg).a2 as a2,
		(stockavg).a3 as a3,
		(stockavg).a4 as a4,
		(stockavg).a5 as a5,
		(stockavg).a6 as a6,
		(aord).a1 as aord_a1,
		(aord).a2 as aord_a2,
		(aord).a3 as aord_a3,
		(aord).a4 as aord_a4,
		(aord).a5 as aord_a5,
		(aord).a6 as aord_a6,
		(n225).a1 as n225_a1,
		(n225).a2 as n225_a2,
		(n225).a3 as n225_a3,
		(n225).a4 as n225_a4,
		(n225).a5 as n225_a5,
		(n225).a6 as n225_a6,
		(ndx).a1 as ndx_a1,
		(ndx).a2 as ndx_a2,
		(ndx).a3 as ndx_a3,
		(ndx).a4 as ndx_a4,
		(ndx).a5 as ndx_a5,
		(ndx).a6 as ndx_a6,
		(dji).a1 as dji_a1,
		(dji).a2 as dji_a2,
		(dji).a3 as dji_a3,
		(dji).a4 as dji_a4,
		(dji).a5 as dji_a5,
		(dji).a6 as dji_a6,
		(ftse).a1 as ftse_a1,
		(ftse).a2 as ftse_a2,
		(ftse).a3 as ftse_a3,
		(ftse).a4 as ftse_a4,
		(ftse).a5 as ftse_a5,
		(ftse).a6 as ftse_a6,
		(gdaxi).a1 as gdaxi_a1,
		(gdaxi).a2 as gdaxi_a2,
		(gdaxi).a3 as gdaxi_a3,
		(gdaxi).a4 as gdaxi_a4,
		(gdaxi).a5 as gdaxi_a5,
		(gdaxi).a6 as gdaxi_a6,
		(ssec).a1 as ssec_a1,
		(ssec).a2 as ssec_a2,
		(ssec).a3 as ssec_a3,
		(ssec).a4 as ssec_a4,
		(ssec).a5 as ssec_a5,
		(ssec).a6 as ssec_a6,
		(hsi).a1 as hsi_a1,
		(hsi).a2 as hsi_a2,
		(hsi).a3 as hsi_a3,
		(hsi).a4 as hsi_a4,
		(hsi).a5 as hsi_a5,
		(hsi).a6 as hsi_a6,
		(bsesn).a1 as bsesn_a1,
		(bsesn).a2 as bsesn_a2,
		(bsesn).a3 as bsesn_a3,
		(bsesn).a4 as bsesn_a4,
		(bsesn).a5 as bsesn_a5,
		(bsesn).a6 as bsesn_a6,
		(jkse).a1 as jkse_a1,
		(jkse).a2 as jkse_a2,
		(jkse).a3 as jkse_a3,
		(jkse).a4 as jkse_a4,
		(jkse).a5 as jkse_a5,
		(jkse).a6 as jkse_a6,
		(nz50).a1 as nz50_a1,
		(nz50).a2 as nz50_a2,
		(nz50).a3 as nz50_a3,
		(nz50).a4 as nz50_a4,
		(nz50).a5 as nz50_a5,
		(nz50).a6 as nz50_a6,
		(sti).a1 as sti_a1,
		(sti).a2 as sti_a2,
		(sti).a3 as sti_a3,
		(sti).a4 as sti_a4,
		(sti).a5 as sti_a5,
		(sti).a6 as sti_a6,
		(ks11).a1 as ks11_a1,
		(ks11).a2 as ks11_a2,
		(ks11).a3 as ks11_a3,
		(ks11).a4 as ks11_a4,
		(ks11).a5 as ks11_a5,
		(ks11).a6 as ks11_a6,
		(twii).a1 as twii_a1,
		(twii).a2 as twii_a2,
		(twii).a3 as twii_a3,
		(twii).a4 as twii_a4,
		(twii).a5 as twii_a5,
		(twii).a6 as twii_a6,
		(bvsp).a1 as bvsp_a1,
		(bvsp).a2 as bvsp_a2,
		(bvsp).a3 as bvsp_a3,
		(bvsp).a4 as bvsp_a4,
		(bvsp).a5 as bvsp_a5,
		(bvsp).a6 as bvsp_a6,
		(gsptse).a1 as gsptse_a1,
		(gsptse).a2 as gsptse_a2,
		(gsptse).a3 as gsptse_a3,
		(gsptse).a4 as gsptse_a4,
		(gsptse).a5 as gsptse_a5,
		(gsptse).a6 as gsptse_a6,
		(mxx).a1 as mxx_a1,
		(mxx).a2 as mxx_a2,
		(mxx).a3 as mxx_a3,
		(mxx).a4 as mxx_a4,
		(mxx).a5 as mxx_a5,
		(mxx).a6 as mxx_a6,
		(gspc).a1 as gspc_a1,
		(gspc).a2 as gspc_a2,
		(gspc).a3 as gspc_a3,
		(gspc).a4 as gspc_a4,
		(gspc).a5 as gspc_a5,
		(gspc).a6 as gspc_a6,
		(atx).a1 as atx_a1,
		(atx).a2 as atx_a2,
		(atx).a3 as atx_a3,
		(atx).a4 as atx_a4,
		(atx).a5 as atx_a5,
		(atx).a6 as atx_a6,
		(bfx).a1 as bfx_a1,
		(bfx).a2 as bfx_a2,
		(bfx).a3 as bfx_a3,
		(bfx).a4 as bfx_a4,
		(bfx).a5 as bfx_a5,
		(bfx).a6 as bfx_a6,
		(fchi).a1 as fchi_a1,
		(fchi).a2 as fchi_a2,
		(fchi).a3 as fchi_a3,
		(fchi).a4 as fchi_a4,
		(fchi).a5 as fchi_a5,
		(fchi).a6 as fchi_a6,
		(ssmi).a1 as ssmi_a1,
		(ssmi).a2 as ssmi_a2,
		(ssmi).a3 as ssmi_a3,
		(ssmi).a4 as ssmi_a4,
		(ssmi).a5 as ssmi_a5,
		(ssmi).a6 as ssmi_a6,
		(gd).a1 as gd_a1,
		(gd).a2 as gd_a2,
		(gd).a3 as gd_a3,
		(gd).a4 as gd_a4,
		(gd).a5 as gd_a5,
		(gd).a6 as gd_a6,
		(eurusd).a1 as eurusd_a1,
		(eurusd).a2 as eurusd_a2,
		(eurusd).a3 as eurusd_a3,
		(eurusd).a4 as eurusd_a4,
		(eurusd).a5 as eurusd_a5,
		(eurusd).a6 as eurusd_a6,
		(usdjpy).a1 as usdjpy_a1,
		(usdjpy).a2 as usdjpy_a2,
		(usdjpy).a3 as usdjpy_a3,
		(usdjpy).a4 as usdjpy_a4,
		(usdjpy).a5 as usdjpy_a5,
		(usdjpy).a6 as usdjpy_a6,
		(usdchf).a1 as usdchf_a1,
		(usdchf).a2 as usdchf_a2,
		(usdchf).a3 as usdchf_a3,
		(usdchf).a4 as usdchf_a4,
		(usdchf).a5 as usdchf_a5,
		(usdchf).a6 as usdchf_a6,
		(gbpusd).a1 as gbpusd_a1,
		(gbpusd).a2 as gbpusd_a2,
		(gbpusd).a3 as gbpusd_a3,
		(gbpusd).a4 as gbpusd_a4,
		(gbpusd).a5 as gbpusd_a5,
		(gbpusd).a6 as gbpusd_a6,
		(usdcad).a1 as usdcad_a1,
		(usdcad).a2 as usdcad_a2,
		(usdcad).a3 as usdcad_a3,
		(usdcad).a4 as usdcad_a4,
		(usdcad).a5 as usdcad_a5,
		(usdcad).a6 as usdcad_a6,
		(eurgbp).a1 as eurgbp_a1,
		(eurgbp).a2 as eurgbp_a2,
		(eurgbp).a3 as eurgbp_a3,
		(eurgbp).a4 as eurgbp_a4,
		(eurgbp).a5 as eurgbp_a5,
		(eurgbp).a6 as eurgbp_a6,
		(eurjpy).a1 as eurjpy_a1,
		(eurjpy).a2 as eurjpy_a2,
		(eurjpy).a3 as eurjpy_a3,
		(eurjpy).a4 as eurjpy_a4,
		(eurjpy).a5 as eurjpy_a5,
		(eurjpy).a6 as eurjpy_a6,
		(eurchf).a1 as eurchf_a1,
		(eurchf).a2 as eurchf_a2,
		(eurchf).a3 as eurchf_a3,
		(eurchf).a4 as eurchf_a4,
		(eurchf).a5 as eurchf_a5,
		(eurchf).a6 as eurchf_a6,
		(audusd).a1 as audusd_a1,
		(audusd).a2 as audusd_a2,
		(audusd).a3 as audusd_a3,
		(audusd).a4 as audusd_a4,
		(audusd).a5 as audusd_a5,
		(audusd).a6 as audusd_a6,
		(gbpjpy).a1 as gbpjpy_a1,
		(gbpjpy).a2 as gbpjpy_a2,
		(gbpjpy).a3 as gbpjpy_a3,
		(gbpjpy).a4 as gbpjpy_a4,
		(gbpjpy).a5 as gbpjpy_a5,
		(gbpjpy).a6 as gbpjpy_a6,
		(chfjpy).a1 as chfjpy_a1,
		(chfjpy).a2 as chfjpy_a2,
		(chfjpy).a3 as chfjpy_a3,
		(chfjpy).a4 as chfjpy_a4,
		(chfjpy).a5 as chfjpy_a5,
		(chfjpy).a6 as chfjpy_a6,
		(gbpchf).a1 as gbpchf_a1,
		(gbpchf).a2 as gbpchf_a2,
		(gbpchf).a3 as gbpchf_a3,
		(gbpchf).a4 as gbpchf_a4,
		(gbpchf).a5 as gbpchf_a5,
		(gbpchf).a6 as gbpchf_a6,
		(nzdusd).a1 as nzdusd_a1,
		(nzdusd).a2 as nzdusd_a2,
		(nzdusd).a3 as nzdusd_a3,
		(nzdusd).a4 as nzdusd_a4,
		(nzdusd).a5 as nzdusd_a5,
		(nzdusd).a6 as nzdusd_a6,
		(cmd_choc).a1 as cmd_choc_a1,
		(cmd_choc).a2 as cmd_choc_a2,
		(cmd_choc).a3 as cmd_choc_a3,
		(cmd_choc).a4 as cmd_choc_a4,
		(cmd_choc).a5 as cmd_choc_a5,
		(cmd_choc).a6 as cmd_choc_a6,
		(cmd_corn).a1 as cmd_corn_a1,
		(cmd_corn).a2 as cmd_corn_a2,
		(cmd_corn).a3 as cmd_corn_a3,
		(cmd_corn).a4 as cmd_corn_a4,
		(cmd_corn).a5 as cmd_corn_a5,
		(cmd_corn).a6 as cmd_corn_a6,
		(cmd_ctnn).a1 as cmd_ctnn_a1,
		(cmd_ctnn).a2 as cmd_ctnn_a2,
		(cmd_ctnn).a3 as cmd_ctnn_a3,
		(cmd_ctnn).a4 as cmd_ctnn_a4,
		(cmd_ctnn).a5 as cmd_ctnn_a5,
		(cmd_ctnn).a6 as cmd_ctnn_a6,
		(cmd_cupm).a1 as cmd_cupm_a1,
		(cmd_cupm).a2 as cmd_cupm_a2,
		(cmd_cupm).a3 as cmd_cupm_a3,
		(cmd_cupm).a4 as cmd_cupm_a4,
		(cmd_cupm).a5 as cmd_cupm_a5,
		(cmd_cupm).a6 as cmd_cupm_a6,
		(cmd_foil).a1 as cmd_foil_a1,
		(cmd_foil).a2 as cmd_foil_a2,
		(cmd_foil).a3 as cmd_foil_a3,
		(cmd_foil).a4 as cmd_foil_a4,
		(cmd_foil).a5 as cmd_foil_a5,
		(cmd_foil).a6 as cmd_foil_a6,
		(cmd_gaz).a1 as cmd_gaz_a1,
		(cmd_gaz).a2 as cmd_gaz_a2,
		(cmd_gaz).a3 as cmd_gaz_a3,
		(cmd_gaz).a4 as cmd_gaz_a4,
		(cmd_gaz).a5 as cmd_gaz_a5,
		(cmd_gaz).a6 as cmd_gaz_a6,
		(cmd_gld).a1 as cmd_gld_a1,
		(cmd_gld).a2 as cmd_gld_a2,
		(cmd_gld).a3 as cmd_gld_a3,
		(cmd_gld).a4 as cmd_gld_a4,
		(cmd_gld).a5 as cmd_gld_a5,
		(cmd_gld).a6 as cmd_gld_a6,
		(cmd_hevy).a1 as cmd_hevy_a1,
		(cmd_hevy).a2 as cmd_hevy_a2,
		(cmd_hevy).a3 as cmd_hevy_a3,
		(cmd_hevy).a4 as cmd_hevy_a4,
		(cmd_hevy).a5 as cmd_hevy_a5,
		(cmd_hevy).a6 as cmd_hevy_a6,
		(cmd_ledd).a1 as cmd_ledd_a1,
		(cmd_ledd).a2 as cmd_ledd_a2,
		(cmd_ledd).a3 as cmd_ledd_a3,
		(cmd_ledd).a4 as cmd_ledd_a4,
		(cmd_ledd).a5 as cmd_ledd_a5,
		(cmd_ledd).a6 as cmd_ledd_a6,
		(cmd_lstk).a1 as cmd_lstk_a1,
		(cmd_lstk).a2 as cmd_lstk_a2,
		(cmd_lstk).a3 as cmd_lstk_a3,
		(cmd_lstk).a4 as cmd_lstk_a4,
		(cmd_lstk).a5 as cmd_lstk_a5,
		(cmd_lstk).a6 as cmd_lstk_a6,
		(cmd_nini).a1 as cmd_nini_a1,
		(cmd_nini).a2 as cmd_nini_a2,
		(cmd_nini).a3 as cmd_nini_a3,
		(cmd_nini).a4 as cmd_nini_a4,
		(cmd_nini).a5 as cmd_nini_a5,
		(cmd_nini).a6 as cmd_nini_a6,
		(cmd_oil).a1 as cmd_oil_a1,
		(cmd_oil).a2 as cmd_oil_a2,
		(cmd_oil).a3 as cmd_oil_a3,
		(cmd_oil).a4 as cmd_oil_a4,
		(cmd_oil).a5 as cmd_oil_a5,
		(cmd_oil).a6 as cmd_oil_a6,
		(cmd_pall).a1 as cmd_pall_a1,
		(cmd_pall).a2 as cmd_pall_a2,
		(cmd_pall).a3 as cmd_pall_a3,
		(cmd_pall).a4 as cmd_pall_a4,
		(cmd_pall).a5 as cmd_pall_a5,
		(cmd_pall).a6 as cmd_pall_a6,
		(cmd_pplt).a1 as cmd_pplt_a1,
		(cmd_pplt).a2 as cmd_pplt_a2,
		(cmd_pplt).a3 as cmd_pplt_a3,
		(cmd_pplt).a4 as cmd_pplt_a4,
		(cmd_pplt).a5 as cmd_pplt_a5,
		(cmd_pplt).a6 as cmd_pplt_a6,
		(cmd_sgar).a1 as cmd_sgar_a1,
		(cmd_sgar).a2 as cmd_sgar_a2,
		(cmd_sgar).a3 as cmd_sgar_a3,
		(cmd_sgar).a4 as cmd_sgar_a4,
		(cmd_sgar).a5 as cmd_sgar_a5,
		(cmd_sgar).a6 as cmd_sgar_a6,
		(cmd_slv).a1 as cmd_slv_a1,
		(cmd_slv).a2 as cmd_slv_a2,
		(cmd_slv).a3 as cmd_slv_a3,
		(cmd_slv).a4 as cmd_slv_a4,
		(cmd_slv).a5 as cmd_slv_a5,
		(cmd_slv).a6 as cmd_slv_a6,
		(cmd_soyb).a1 as cmd_soyb_a1,
		(cmd_soyb).a2 as cmd_soyb_a2,
		(cmd_soyb).a3 as cmd_soyb_a3,
		(cmd_soyb).a4 as cmd_soyb_a4,
		(cmd_soyb).a5 as cmd_soyb_a5,
		(cmd_soyb).a6 as cmd_soyb_a6,
		(cmd_uhn).a1 as cmd_uhn_a1,
		(cmd_uhn).a2 as cmd_uhn_a2,
		(cmd_uhn).a3 as cmd_uhn_a3,
		(cmd_uhn).a4 as cmd_uhn_a4,
		(cmd_uhn).a5 as cmd_uhn_a5,
		(cmd_uhn).a6 as cmd_uhn_a6,
		dow as dow,
		week as week,
		optexpday as optexpday,
		prediction as prediction
	FROM datamining_stocks_view v
		WHERE v.stockname=stcknm
    $$;


ALTER FUNCTION public.datamine1(stcknm character varying) OWNER TO postgres;

--
-- TOC entry 214 (class 1255 OID 21934027)
-- Name: datamine_aggr_sp(character varying, bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION datamine_aggr_sp(stockname character varying, ofst bigint, lmt bigint) RETURNS SETOF dm_type
    LANGUAGE sql
    AS $$
      SELECT
		(stockavg).a1 as a1,
		(stockavg).a2 as a2,
		(stockavg).a3 as a3,
		(stockavg).a4 as a4,
		(stockavg).a5 as a5,
		(stockavg).a6 as a6,
		(aord).a1 as aord_a1,
		(aord).a2 as aord_a2,
		(aord).a3 as aord_a3,
		(aord).a4 as aord_a4,
		(aord).a5 as aord_a5,
		(aord).a6 as aord_a6,
		(n225).a1 as n225_a1,
		(n225).a2 as n225_a2,
		(n225).a3 as n225_a3,
		(n225).a4 as n225_a4,
		(n225).a5 as n225_a5,
		(n225).a6 as n225_a6,
		(ndx).a1 as ndx_a1,
		(ndx).a2 as ndx_a2,
		(ndx).a3 as ndx_a3,
		(ndx).a4 as ndx_a4,
		(ndx).a5 as ndx_a5,
		(ndx).a6 as ndx_a6,
		(dji).a1 as dji_a1,
		(dji).a2 as dji_a2,
		(dji).a3 as dji_a3,
		(dji).a4 as dji_a4,
		(dji).a5 as dji_a5,
		(dji).a6 as dji_a6,
		(ftse).a1 as ftse_a1,
		(ftse).a2 as ftse_a2,
		(ftse).a3 as ftse_a3,
		(ftse).a4 as ftse_a4,
		(ftse).a5 as ftse_a5,
		(ftse).a6 as ftse_a6,
		(gdaxi).a1 as gdaxi_a1,
		(gdaxi).a2 as gdaxi_a2,
		(gdaxi).a3 as gdaxi_a3,
		(gdaxi).a4 as gdaxi_a4,
		(gdaxi).a5 as gdaxi_a5,
		(gdaxi).a6 as gdaxi_a6,
		(ssec).a1 as ssec_a1,
		(ssec).a2 as ssec_a2,
		(ssec).a3 as ssec_a3,
		(ssec).a4 as ssec_a4,
		(ssec).a5 as ssec_a5,
		(ssec).a6 as ssec_a6,
		(hsi).a1 as hsi_a1,
		(hsi).a2 as hsi_a2,
		(hsi).a3 as hsi_a3,
		(hsi).a4 as hsi_a4,
		(hsi).a5 as hsi_a5,
		(hsi).a6 as hsi_a6,
		(bsesn).a1 as bsesn_a1,
		(bsesn).a2 as bsesn_a2,
		(bsesn).a3 as bsesn_a3,
		(bsesn).a4 as bsesn_a4,
		(bsesn).a5 as bsesn_a5,
		(bsesn).a6 as bsesn_a6,
		(jkse).a1 as jkse_a1,
		(jkse).a2 as jkse_a2,
		(jkse).a3 as jkse_a3,
		(jkse).a4 as jkse_a4,
		(jkse).a5 as jkse_a5,
		(jkse).a6 as jkse_a6,
		(nz50).a1 as nz50_a1,
		(nz50).a2 as nz50_a2,
		(nz50).a3 as nz50_a3,
		(nz50).a4 as nz50_a4,
		(nz50).a5 as nz50_a5,
		(nz50).a6 as nz50_a6,
		(sti).a1 as sti_a1,
		(sti).a2 as sti_a2,
		(sti).a3 as sti_a3,
		(sti).a4 as sti_a4,
		(sti).a5 as sti_a5,
		(sti).a6 as sti_a6,
		(ks11).a1 as ks11_a1,
		(ks11).a2 as ks11_a2,
		(ks11).a3 as ks11_a3,
		(ks11).a4 as ks11_a4,
		(ks11).a5 as ks11_a5,
		(ks11).a6 as ks11_a6,
		(twii).a1 as twii_a1,
		(twii).a2 as twii_a2,
		(twii).a3 as twii_a3,
		(twii).a4 as twii_a4,
		(twii).a5 as twii_a5,
		(twii).a6 as twii_a6,
		(bvsp).a1 as bvsp_a1,
		(bvsp).a2 as bvsp_a2,
		(bvsp).a3 as bvsp_a3,
		(bvsp).a4 as bvsp_a4,
		(bvsp).a5 as bvsp_a5,
		(bvsp).a6 as bvsp_a6,
		(gsptse).a1 as gsptse_a1,
		(gsptse).a2 as gsptse_a2,
		(gsptse).a3 as gsptse_a3,
		(gsptse).a4 as gsptse_a4,
		(gsptse).a5 as gsptse_a5,
		(gsptse).a6 as gsptse_a6,
		(mxx).a1 as mxx_a1,
		(mxx).a2 as mxx_a2,
		(mxx).a3 as mxx_a3,
		(mxx).a4 as mxx_a4,
		(mxx).a5 as mxx_a5,
		(mxx).a6 as mxx_a6,
		(gspc).a1 as gspc_a1,
		(gspc).a2 as gspc_a2,
		(gspc).a3 as gspc_a3,
		(gspc).a4 as gspc_a4,
		(gspc).a5 as gspc_a5,
		(gspc).a6 as gspc_a6,
		(atx).a1 as atx_a1,
		(atx).a2 as atx_a2,
		(atx).a3 as atx_a3,
		(atx).a4 as atx_a4,
		(atx).a5 as atx_a5,
		(atx).a6 as atx_a6,
		(bfx).a1 as bfx_a1,
		(bfx).a2 as bfx_a2,
		(bfx).a3 as bfx_a3,
		(bfx).a4 as bfx_a4,
		(bfx).a5 as bfx_a5,
		(bfx).a6 as bfx_a6,
		(fchi).a1 as fchi_a1,
		(fchi).a2 as fchi_a2,
		(fchi).a3 as fchi_a3,
		(fchi).a4 as fchi_a4,
		(fchi).a5 as fchi_a5,
		(fchi).a6 as fchi_a6,
		(ssmi).a1 as ssmi_a1,
		(ssmi).a2 as ssmi_a2,
		(ssmi).a3 as ssmi_a3,
		(ssmi).a4 as ssmi_a4,
		(ssmi).a5 as ssmi_a5,
		(ssmi).a6 as ssmi_a6,
		(gd).a1 as gd_a1,
		(gd).a2 as gd_a2,
		(gd).a3 as gd_a3,
		(gd).a4 as gd_a4,
		(gd).a5 as gd_a5,
		(gd).a6 as gd_a6,
		(eurusd).a1 as eurusd_a1,
		(eurusd).a2 as eurusd_a2,
		(eurusd).a3 as eurusd_a3,
		(eurusd).a4 as eurusd_a4,
		(eurusd).a5 as eurusd_a5,
		(eurusd).a6 as eurusd_a6,
		(usdjpy).a1 as usdjpy_a1,
		(usdjpy).a2 as usdjpy_a2,
		(usdjpy).a3 as usdjpy_a3,
		(usdjpy).a4 as usdjpy_a4,
		(usdjpy).a5 as usdjpy_a5,
		(usdjpy).a6 as usdjpy_a6,
		(usdchf).a1 as usdchf_a1,
		(usdchf).a2 as usdchf_a2,
		(usdchf).a3 as usdchf_a3,
		(usdchf).a4 as usdchf_a4,
		(usdchf).a5 as usdchf_a5,
		(usdchf).a6 as usdchf_a6,
		(gbpusd).a1 as gbpusd_a1,
		(gbpusd).a2 as gbpusd_a2,
		(gbpusd).a3 as gbpusd_a3,
		(gbpusd).a4 as gbpusd_a4,
		(gbpusd).a5 as gbpusd_a5,
		(gbpusd).a6 as gbpusd_a6,
		(usdcad).a1 as usdcad_a1,
		(usdcad).a2 as usdcad_a2,
		(usdcad).a3 as usdcad_a3,
		(usdcad).a4 as usdcad_a4,
		(usdcad).a5 as usdcad_a5,
		(usdcad).a6 as usdcad_a6,
		(eurgbp).a1 as eurgbp_a1,
		(eurgbp).a2 as eurgbp_a2,
		(eurgbp).a3 as eurgbp_a3,
		(eurgbp).a4 as eurgbp_a4,
		(eurgbp).a5 as eurgbp_a5,
		(eurgbp).a6 as eurgbp_a6,
		(eurjpy).a1 as eurjpy_a1,
		(eurjpy).a2 as eurjpy_a2,
		(eurjpy).a3 as eurjpy_a3,
		(eurjpy).a4 as eurjpy_a4,
		(eurjpy).a5 as eurjpy_a5,
		(eurjpy).a6 as eurjpy_a6,
		(eurchf).a1 as eurchf_a1,
		(eurchf).a2 as eurchf_a2,
		(eurchf).a3 as eurchf_a3,
		(eurchf).a4 as eurchf_a4,
		(eurchf).a5 as eurchf_a5,
		(eurchf).a6 as eurchf_a6,
		(audusd).a1 as audusd_a1,
		(audusd).a2 as audusd_a2,
		(audusd).a3 as audusd_a3,
		(audusd).a4 as audusd_a4,
		(audusd).a5 as audusd_a5,
		(audusd).a6 as audusd_a6,
		(gbpjpy).a1 as gbpjpy_a1,
		(gbpjpy).a2 as gbpjpy_a2,
		(gbpjpy).a3 as gbpjpy_a3,
		(gbpjpy).a4 as gbpjpy_a4,
		(gbpjpy).a5 as gbpjpy_a5,
		(gbpjpy).a6 as gbpjpy_a6,
		(chfjpy).a1 as chfjpy_a1,
		(chfjpy).a2 as chfjpy_a2,
		(chfjpy).a3 as chfjpy_a3,
		(chfjpy).a4 as chfjpy_a4,
		(chfjpy).a5 as chfjpy_a5,
		(chfjpy).a6 as chfjpy_a6,
		(gbpchf).a1 as gbpchf_a1,
		(gbpchf).a2 as gbpchf_a2,
		(gbpchf).a3 as gbpchf_a3,
		(gbpchf).a4 as gbpchf_a4,
		(gbpchf).a5 as gbpchf_a5,
		(gbpchf).a6 as gbpchf_a6,
		(nzdusd).a1 as nzdusd_a1,
		(nzdusd).a2 as nzdusd_a2,
		(nzdusd).a3 as nzdusd_a3,
		(nzdusd).a4 as nzdusd_a4,
		(nzdusd).a5 as nzdusd_a5,
		(nzdusd).a6 as nzdusd_a6,
		(cmd_choc).a1 as cmd_choc_a1,
		(cmd_choc).a2 as cmd_choc_a2,
		(cmd_choc).a3 as cmd_choc_a3,
		(cmd_choc).a4 as cmd_choc_a4,
		(cmd_choc).a5 as cmd_choc_a5,
		(cmd_choc).a6 as cmd_choc_a6,
		(cmd_corn).a1 as cmd_corn_a1,
		(cmd_corn).a2 as cmd_corn_a2,
		(cmd_corn).a3 as cmd_corn_a3,
		(cmd_corn).a4 as cmd_corn_a4,
		(cmd_corn).a5 as cmd_corn_a5,
		(cmd_corn).a6 as cmd_corn_a6,
		(cmd_ctnn).a1 as cmd_ctnn_a1,
		(cmd_ctnn).a2 as cmd_ctnn_a2,
		(cmd_ctnn).a3 as cmd_ctnn_a3,
		(cmd_ctnn).a4 as cmd_ctnn_a4,
		(cmd_ctnn).a5 as cmd_ctnn_a5,
		(cmd_ctnn).a6 as cmd_ctnn_a6,
		(cmd_cupm).a1 as cmd_cupm_a1,
		(cmd_cupm).a2 as cmd_cupm_a2,
		(cmd_cupm).a3 as cmd_cupm_a3,
		(cmd_cupm).a4 as cmd_cupm_a4,
		(cmd_cupm).a5 as cmd_cupm_a5,
		(cmd_cupm).a6 as cmd_cupm_a6,
		(cmd_foil).a1 as cmd_foil_a1,
		(cmd_foil).a2 as cmd_foil_a2,
		(cmd_foil).a3 as cmd_foil_a3,
		(cmd_foil).a4 as cmd_foil_a4,
		(cmd_foil).a5 as cmd_foil_a5,
		(cmd_foil).a6 as cmd_foil_a6,
		(cmd_gaz).a1 as cmd_gaz_a1,
		(cmd_gaz).a2 as cmd_gaz_a2,
		(cmd_gaz).a3 as cmd_gaz_a3,
		(cmd_gaz).a4 as cmd_gaz_a4,
		(cmd_gaz).a5 as cmd_gaz_a5,
		(cmd_gaz).a6 as cmd_gaz_a6,
		(cmd_gld).a1 as cmd_gld_a1,
		(cmd_gld).a2 as cmd_gld_a2,
		(cmd_gld).a3 as cmd_gld_a3,
		(cmd_gld).a4 as cmd_gld_a4,
		(cmd_gld).a5 as cmd_gld_a5,
		(cmd_gld).a6 as cmd_gld_a6,
		(cmd_hevy).a1 as cmd_hevy_a1,
		(cmd_hevy).a2 as cmd_hevy_a2,
		(cmd_hevy).a3 as cmd_hevy_a3,
		(cmd_hevy).a4 as cmd_hevy_a4,
		(cmd_hevy).a5 as cmd_hevy_a5,
		(cmd_hevy).a6 as cmd_hevy_a6,
		(cmd_ledd).a1 as cmd_ledd_a1,
		(cmd_ledd).a2 as cmd_ledd_a2,
		(cmd_ledd).a3 as cmd_ledd_a3,
		(cmd_ledd).a4 as cmd_ledd_a4,
		(cmd_ledd).a5 as cmd_ledd_a5,
		(cmd_ledd).a6 as cmd_ledd_a6,
		(cmd_lstk).a1 as cmd_lstk_a1,
		(cmd_lstk).a2 as cmd_lstk_a2,
		(cmd_lstk).a3 as cmd_lstk_a3,
		(cmd_lstk).a4 as cmd_lstk_a4,
		(cmd_lstk).a5 as cmd_lstk_a5,
		(cmd_lstk).a6 as cmd_lstk_a6,
		(cmd_nini).a1 as cmd_nini_a1,
		(cmd_nini).a2 as cmd_nini_a2,
		(cmd_nini).a3 as cmd_nini_a3,
		(cmd_nini).a4 as cmd_nini_a4,
		(cmd_nini).a5 as cmd_nini_a5,
		(cmd_nini).a6 as cmd_nini_a6,
		(cmd_oil).a1 as cmd_oil_a1,
		(cmd_oil).a2 as cmd_oil_a2,
		(cmd_oil).a3 as cmd_oil_a3,
		(cmd_oil).a4 as cmd_oil_a4,
		(cmd_oil).a5 as cmd_oil_a5,
		(cmd_oil).a6 as cmd_oil_a6,
		(cmd_pall).a1 as cmd_pall_a1,
		(cmd_pall).a2 as cmd_pall_a2,
		(cmd_pall).a3 as cmd_pall_a3,
		(cmd_pall).a4 as cmd_pall_a4,
		(cmd_pall).a5 as cmd_pall_a5,
		(cmd_pall).a6 as cmd_pall_a6,
		(cmd_pplt).a1 as cmd_pplt_a1,
		(cmd_pplt).a2 as cmd_pplt_a2,
		(cmd_pplt).a3 as cmd_pplt_a3,
		(cmd_pplt).a4 as cmd_pplt_a4,
		(cmd_pplt).a5 as cmd_pplt_a5,
		(cmd_pplt).a6 as cmd_pplt_a6,
		(cmd_sgar).a1 as cmd_sgar_a1,
		(cmd_sgar).a2 as cmd_sgar_a2,
		(cmd_sgar).a3 as cmd_sgar_a3,
		(cmd_sgar).a4 as cmd_sgar_a4,
		(cmd_sgar).a5 as cmd_sgar_a5,
		(cmd_sgar).a6 as cmd_sgar_a6,
		(cmd_slv).a1 as cmd_slv_a1,
		(cmd_slv).a2 as cmd_slv_a2,
		(cmd_slv).a3 as cmd_slv_a3,
		(cmd_slv).a4 as cmd_slv_a4,
		(cmd_slv).a5 as cmd_slv_a5,
		(cmd_slv).a6 as cmd_slv_a6,
		(cmd_soyb).a1 as cmd_soyb_a1,
		(cmd_soyb).a2 as cmd_soyb_a2,
		(cmd_soyb).a3 as cmd_soyb_a3,
		(cmd_soyb).a4 as cmd_soyb_a4,
		(cmd_soyb).a5 as cmd_soyb_a5,
		(cmd_soyb).a6 as cmd_soyb_a6,
		(cmd_uhn).a1 as cmd_uhn_a1,
		(cmd_uhn).a2 as cmd_uhn_a2,
		(cmd_uhn).a3 as cmd_uhn_a3,
		(cmd_uhn).a4 as cmd_uhn_a4,
		(cmd_uhn).a5 as cmd_uhn_a5,
		(cmd_uhn).a6 as cmd_uhn_a6,
		dow as dow,
		week as week,
		optexpday as optexpday,
		prediction as prediction
	FROM datamine_aggr da
		WHERE da.stockname=stockname
		order by da.date desc
	offset ofst
	limit lmt

    $$;


ALTER FUNCTION public.datamine_aggr_sp(stockname character varying, ofst bigint, lmt bigint) OWNER TO postgres;

--
-- TOC entry 215 (class 1255 OID 21934029)
-- Name: datamine_extra(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION datamine_extra(stcknm character varying) RETURNS TABLE(date date, price double precision, a1 double precision, a2 double precision, a3 double precision, a4 double precision, a5 double precision, a6 double precision, aord_a1 double precision, aord_a2 double precision, aord_a3 double precision, aord_a4 double precision, aord_a5 double precision, aord_a6 double precision, n225_a1 double precision, n225_a2 double precision, n225_a3 double precision, n225_a4 double precision, n225_a5 double precision, n225_a6 double precision, ndx_a1 double precision, ndx_a2 double precision, ndx_a3 double precision, ndx_a4 double precision, ndx_a5 double precision, ndx_a6 double precision, dji_a1 double precision, dji_a2 double precision, dji_a3 double precision, dji_a4 double precision, dji_a5 double precision, dji_a6 double precision, ftse_a1 double precision, ftse_a2 double precision, ftse_a3 double precision, ftse_a4 double precision, ftse_a5 double precision, ftse_a6 double precision, gdaxi_a1 double precision, gdaxi_a2 double precision, gdaxi_a3 double precision, gdaxi_a4 double precision, gdaxi_a5 double precision, gdaxi_a6 double precision, ssec_a1 double precision, ssec_a2 double precision, ssec_a3 double precision, ssec_a4 double precision, ssec_a5 double precision, ssec_a6 double precision, hsi_a1 double precision, hsi_a2 double precision, hsi_a3 double precision, hsi_a4 double precision, hsi_a5 double precision, hsi_a6 double precision, bsesn_a1 double precision, bsesn_a2 double precision, bsesn_a3 double precision, bsesn_a4 double precision, bsesn_a5 double precision, bsesn_a6 double precision, jkse_a1 double precision, jkse_a2 double precision, jkse_a3 double precision, jkse_a4 double precision, jkse_a5 double precision, jkse_a6 double precision, nz50_a1 double precision, nz50_a2 double precision, nz50_a3 double precision, nz50_a4 double precision, nz50_a5 double precision, nz50_a6 double precision, sti_a1 double precision, sti_a2 double precision, sti_a3 double precision, sti_a4 double precision, sti_a5 double precision, sti_a6 double precision, ks11_a1 double precision, ks11_a2 double precision, ks11_a3 double precision, ks11_a4 double precision, ks11_a5 double precision, ks11_a6 double precision, twii_a1 double precision, twii_a2 double precision, twii_a3 double precision, twii_a4 double precision, twii_a5 double precision, twii_a6 double precision, bvsp_a1 double precision, bvsp_a2 double precision, bvsp_a3 double precision, bvsp_a4 double precision, bvsp_a5 double precision, bvsp_a6 double precision, gsptse_a1 double precision, gsptse_a2 double precision, gsptse_a3 double precision, gsptse_a4 double precision, gsptse_a5 double precision, gsptse_a6 double precision, mxx_a1 double precision, mxx_a2 double precision, mxx_a3 double precision, mxx_a4 double precision, mxx_a5 double precision, mxx_a6 double precision, gspc_a1 double precision, gspc_a2 double precision, gspc_a3 double precision, gspc_a4 double precision, gspc_a5 double precision, gspc_a6 double precision, atx_a1 double precision, atx_a2 double precision, atx_a3 double precision, atx_a4 double precision, atx_a5 double precision, atx_a6 double precision, bfx_a1 double precision, bfx_a2 double precision, bfx_a3 double precision, bfx_a4 double precision, bfx_a5 double precision, bfx_a6 double precision, fchi_a1 double precision, fchi_a2 double precision, fchi_a3 double precision, fchi_a4 double precision, fchi_a5 double precision, fchi_a6 double precision, ssmi_a1 double precision, ssmi_a2 double precision, ssmi_a3 double precision, ssmi_a4 double precision, ssmi_a5 double precision, ssmi_a6 double precision, gd_a1 double precision, gd_a2 double precision, gd_a3 double precision, gd_a4 double precision, gd_a5 double precision, gd_a6 double precision, eurusd_a1 double precision, eurusd_a2 double precision, eurusd_a3 double precision, eurusd_a4 double precision, eurusd_a5 double precision, eurusd_a6 double precision, usdjpy_a1 double precision, usdjpy_a2 double precision, usdjpy_a3 double precision, usdjpy_a4 double precision, usdjpy_a5 double precision, usdjpy_a6 double precision, usdchf_a1 double precision, usdchf_a2 double precision, usdchf_a3 double precision, usdchf_a4 double precision, usdchf_a5 double precision, usdchf_a6 double precision, gbpusd_a1 double precision, gbpusd_a2 double precision, gbpusd_a3 double precision, gbpusd_a4 double precision, gbpusd_a5 double precision, gbpusd_a6 double precision, usdcad_a1 double precision, usdcad_a2 double precision, usdcad_a3 double precision, usdcad_a4 double precision, usdcad_a5 double precision, usdcad_a6 double precision, eurgbp_a1 double precision, eurgbp_a2 double precision, eurgbp_a3 double precision, eurgbp_a4 double precision, eurgbp_a5 double precision, eurgbp_a6 double precision, eurjpy_a1 double precision, eurjpy_a2 double precision, eurjpy_a3 double precision, eurjpy_a4 double precision, eurjpy_a5 double precision, eurjpy_a6 double precision, eurchf_a1 double precision, eurchf_a2 double precision, eurchf_a3 double precision, eurchf_a4 double precision, eurchf_a5 double precision, eurchf_a6 double precision, audusd_a1 double precision, audusd_a2 double precision, audusd_a3 double precision, audusd_a4 double precision, audusd_a5 double precision, audusd_a6 double precision, gbpjpy_a1 double precision, gbpjpy_a2 double precision, gbpjpy_a3 double precision, gbpjpy_a4 double precision, gbpjpy_a5 double precision, gbpjpy_a6 double precision, chfjpy_a1 double precision, chfjpy_a2 double precision, chfjpy_a3 double precision, chfjpy_a4 double precision, chfjpy_a5 double precision, chfjpy_a6 double precision, gbpchf_a1 double precision, gbpchf_a2 double precision, gbpchf_a3 double precision, gbpchf_a4 double precision, gbpchf_a5 double precision, gbpchf_a6 double precision, nzdusd_a1 double precision, nzdusd_a2 double precision, nzdusd_a3 double precision, nzdusd_a4 double precision, nzdusd_a5 double precision, nzdusd_a6 double precision, cmd_choc_a1 double precision, cmd_choc_a2 double precision, cmd_choc_a3 double precision, cmd_choc_a4 double precision, cmd_choc_a5 double precision, cmd_choc_a6 double precision, cmd_corn_a1 double precision, cmd_corn_a2 double precision, cmd_corn_a3 double precision, cmd_corn_a4 double precision, cmd_corn_a5 double precision, cmd_corn_a6 double precision, cmd_ctnn_a1 double precision, cmd_ctnn_a2 double precision, cmd_ctnn_a3 double precision, cmd_ctnn_a4 double precision, cmd_ctnn_a5 double precision, cmd_ctnn_a6 double precision, cmd_cupm_a1 double precision, cmd_cupm_a2 double precision, cmd_cupm_a3 double precision, cmd_cupm_a4 double precision, cmd_cupm_a5 double precision, cmd_cupm_a6 double precision, cmd_foil_a1 double precision, cmd_foil_a2 double precision, cmd_foil_a3 double precision, cmd_foil_a4 double precision, cmd_foil_a5 double precision, cmd_foil_a6 double precision, cmd_gaz_a1 double precision, cmd_gaz_a2 double precision, cmd_gaz_a3 double precision, cmd_gaz_a4 double precision, cmd_gaz_a5 double precision, cmd_gaz_a6 double precision, cmd_gld_a1 double precision, cmd_gld_a2 double precision, cmd_gld_a3 double precision, cmd_gld_a4 double precision, cmd_gld_a5 double precision, cmd_gld_a6 double precision, cmd_hevy_a1 double precision, cmd_hevy_a2 double precision, cmd_hevy_a3 double precision, cmd_hevy_a4 double precision, cmd_hevy_a5 double precision, cmd_hevy_a6 double precision, cmd_ledd_a1 double precision, cmd_ledd_a2 double precision, cmd_ledd_a3 double precision, cmd_ledd_a4 double precision, cmd_ledd_a5 double precision, cmd_ledd_a6 double precision, cmd_lstk_a1 double precision, cmd_lstk_a2 double precision, cmd_lstk_a3 double precision, cmd_lstk_a4 double precision, cmd_lstk_a5 double precision, cmd_lstk_a6 double precision, cmd_nini_a1 double precision, cmd_nini_a2 double precision, cmd_nini_a3 double precision, cmd_nini_a4 double precision, cmd_nini_a5 double precision, cmd_nini_a6 double precision, cmd_oil_a1 double precision, cmd_oil_a2 double precision, cmd_oil_a3 double precision, cmd_oil_a4 double precision, cmd_oil_a5 double precision, cmd_oil_a6 double precision, cmd_pall_a1 double precision, cmd_pall_a2 double precision, cmd_pall_a3 double precision, cmd_pall_a4 double precision, cmd_pall_a5 double precision, cmd_pall_a6 double precision, cmd_pplt_a1 double precision, cmd_pplt_a2 double precision, cmd_pplt_a3 double precision, cmd_pplt_a4 double precision, cmd_pplt_a5 double precision, cmd_pplt_a6 double precision, cmd_sgar_a1 double precision, cmd_sgar_a2 double precision, cmd_sgar_a3 double precision, cmd_sgar_a4 double precision, cmd_sgar_a5 double precision, cmd_sgar_a6 double precision, cmd_slv_a1 double precision, cmd_slv_a2 double precision, cmd_slv_a3 double precision, cmd_slv_a4 double precision, cmd_slv_a5 double precision, cmd_slv_a6 double precision, cmd_soyb_a1 double precision, cmd_soyb_a2 double precision, cmd_soyb_a3 double precision, cmd_soyb_a4 double precision, cmd_soyb_a5 double precision, cmd_soyb_a6 double precision, cmd_uhn_a1 double precision, cmd_uhn_a2 double precision, cmd_uhn_a3 double precision, cmd_uhn_a4 double precision, cmd_uhn_a5 double precision, cmd_uhn_a6 double precision, dow double precision, week double precision, optexpday integer, prediction double precision)
    LANGUAGE sql
    AS $$
      SELECT date,
      price,
		(stockavg).a1 as a1,
		(stockavg).a2 as a2,
		(stockavg).a3 as a3,
		(stockavg).a4 as a4,
		(stockavg).a5 as a5,
		(stockavg).a6 as a6,
		(aord).a1 as aord_a1,
		(aord).a2 as aord_a2,
		(aord).a3 as aord_a3,
		(aord).a4 as aord_a4,
		(aord).a5 as aord_a5,
		(aord).a6 as aord_a6,
		(n225).a1 as n225_a1,
		(n225).a2 as n225_a2,
		(n225).a3 as n225_a3,
		(n225).a4 as n225_a4,
		(n225).a5 as n225_a5,
		(n225).a6 as n225_a6,
		(ndx).a1 as ndx_a1,
		(ndx).a2 as ndx_a2,
		(ndx).a3 as ndx_a3,
		(ndx).a4 as ndx_a4,
		(ndx).a5 as ndx_a5,
		(ndx).a6 as ndx_a6,
		(dji).a1 as dji_a1,
		(dji).a2 as dji_a2,
		(dji).a3 as dji_a3,
		(dji).a4 as dji_a4,
		(dji).a5 as dji_a5,
		(dji).a6 as dji_a6,
		(ftse).a1 as ftse_a1,
		(ftse).a2 as ftse_a2,
		(ftse).a3 as ftse_a3,
		(ftse).a4 as ftse_a4,
		(ftse).a5 as ftse_a5,
		(ftse).a6 as ftse_a6,
		(gdaxi).a1 as gdaxi_a1,
		(gdaxi).a2 as gdaxi_a2,
		(gdaxi).a3 as gdaxi_a3,
		(gdaxi).a4 as gdaxi_a4,
		(gdaxi).a5 as gdaxi_a5,
		(gdaxi).a6 as gdaxi_a6,
		(ssec).a1 as ssec_a1,
		(ssec).a2 as ssec_a2,
		(ssec).a3 as ssec_a3,
		(ssec).a4 as ssec_a4,
		(ssec).a5 as ssec_a5,
		(ssec).a6 as ssec_a6,
		(hsi).a1 as hsi_a1,
		(hsi).a2 as hsi_a2,
		(hsi).a3 as hsi_a3,
		(hsi).a4 as hsi_a4,
		(hsi).a5 as hsi_a5,
		(hsi).a6 as hsi_a6,
		(bsesn).a1 as bsesn_a1,
		(bsesn).a2 as bsesn_a2,
		(bsesn).a3 as bsesn_a3,
		(bsesn).a4 as bsesn_a4,
		(bsesn).a5 as bsesn_a5,
		(bsesn).a6 as bsesn_a6,
		(jkse).a1 as jkse_a1,
		(jkse).a2 as jkse_a2,
		(jkse).a3 as jkse_a3,
		(jkse).a4 as jkse_a4,
		(jkse).a5 as jkse_a5,
		(jkse).a6 as jkse_a6,
		(nz50).a1 as nz50_a1,
		(nz50).a2 as nz50_a2,
		(nz50).a3 as nz50_a3,
		(nz50).a4 as nz50_a4,
		(nz50).a5 as nz50_a5,
		(nz50).a6 as nz50_a6,
		(sti).a1 as sti_a1,
		(sti).a2 as sti_a2,
		(sti).a3 as sti_a3,
		(sti).a4 as sti_a4,
		(sti).a5 as sti_a5,
		(sti).a6 as sti_a6,
		(ks11).a1 as ks11_a1,
		(ks11).a2 as ks11_a2,
		(ks11).a3 as ks11_a3,
		(ks11).a4 as ks11_a4,
		(ks11).a5 as ks11_a5,
		(ks11).a6 as ks11_a6,
		(twii).a1 as twii_a1,
		(twii).a2 as twii_a2,
		(twii).a3 as twii_a3,
		(twii).a4 as twii_a4,
		(twii).a5 as twii_a5,
		(twii).a6 as twii_a6,
		(bvsp).a1 as bvsp_a1,
		(bvsp).a2 as bvsp_a2,
		(bvsp).a3 as bvsp_a3,
		(bvsp).a4 as bvsp_a4,
		(bvsp).a5 as bvsp_a5,
		(bvsp).a6 as bvsp_a6,
		(gsptse).a1 as gsptse_a1,
		(gsptse).a2 as gsptse_a2,
		(gsptse).a3 as gsptse_a3,
		(gsptse).a4 as gsptse_a4,
		(gsptse).a5 as gsptse_a5,
		(gsptse).a6 as gsptse_a6,
		(mxx).a1 as mxx_a1,
		(mxx).a2 as mxx_a2,
		(mxx).a3 as mxx_a3,
		(mxx).a4 as mxx_a4,
		(mxx).a5 as mxx_a5,
		(mxx).a6 as mxx_a6,
		(gspc).a1 as gspc_a1,
		(gspc).a2 as gspc_a2,
		(gspc).a3 as gspc_a3,
		(gspc).a4 as gspc_a4,
		(gspc).a5 as gspc_a5,
		(gspc).a6 as gspc_a6,
		(atx).a1 as atx_a1,
		(atx).a2 as atx_a2,
		(atx).a3 as atx_a3,
		(atx).a4 as atx_a4,
		(atx).a5 as atx_a5,
		(atx).a6 as atx_a6,
		(bfx).a1 as bfx_a1,
		(bfx).a2 as bfx_a2,
		(bfx).a3 as bfx_a3,
		(bfx).a4 as bfx_a4,
		(bfx).a5 as bfx_a5,
		(bfx).a6 as bfx_a6,
		(fchi).a1 as fchi_a1,
		(fchi).a2 as fchi_a2,
		(fchi).a3 as fchi_a3,
		(fchi).a4 as fchi_a4,
		(fchi).a5 as fchi_a5,
		(fchi).a6 as fchi_a6,
		(ssmi).a1 as ssmi_a1,
		(ssmi).a2 as ssmi_a2,
		(ssmi).a3 as ssmi_a3,
		(ssmi).a4 as ssmi_a4,
		(ssmi).a5 as ssmi_a5,
		(ssmi).a6 as ssmi_a6,
		(gd).a1 as gd_a1,
		(gd).a2 as gd_a2,
		(gd).a3 as gd_a3,
		(gd).a4 as gd_a4,
		(gd).a5 as gd_a5,
		(gd).a6 as gd_a6,
		(eurusd).a1 as eurusd_a1,
		(eurusd).a2 as eurusd_a2,
		(eurusd).a3 as eurusd_a3,
		(eurusd).a4 as eurusd_a4,
		(eurusd).a5 as eurusd_a5,
		(eurusd).a6 as eurusd_a6,
		(usdjpy).a1 as usdjpy_a1,
		(usdjpy).a2 as usdjpy_a2,
		(usdjpy).a3 as usdjpy_a3,
		(usdjpy).a4 as usdjpy_a4,
		(usdjpy).a5 as usdjpy_a5,
		(usdjpy).a6 as usdjpy_a6,
		(usdchf).a1 as usdchf_a1,
		(usdchf).a2 as usdchf_a2,
		(usdchf).a3 as usdchf_a3,
		(usdchf).a4 as usdchf_a4,
		(usdchf).a5 as usdchf_a5,
		(usdchf).a6 as usdchf_a6,
		(gbpusd).a1 as gbpusd_a1,
		(gbpusd).a2 as gbpusd_a2,
		(gbpusd).a3 as gbpusd_a3,
		(gbpusd).a4 as gbpusd_a4,
		(gbpusd).a5 as gbpusd_a5,
		(gbpusd).a6 as gbpusd_a6,
		(usdcad).a1 as usdcad_a1,
		(usdcad).a2 as usdcad_a2,
		(usdcad).a3 as usdcad_a3,
		(usdcad).a4 as usdcad_a4,
		(usdcad).a5 as usdcad_a5,
		(usdcad).a6 as usdcad_a6,
		(eurgbp).a1 as eurgbp_a1,
		(eurgbp).a2 as eurgbp_a2,
		(eurgbp).a3 as eurgbp_a3,
		(eurgbp).a4 as eurgbp_a4,
		(eurgbp).a5 as eurgbp_a5,
		(eurgbp).a6 as eurgbp_a6,
		(eurjpy).a1 as eurjpy_a1,
		(eurjpy).a2 as eurjpy_a2,
		(eurjpy).a3 as eurjpy_a3,
		(eurjpy).a4 as eurjpy_a4,
		(eurjpy).a5 as eurjpy_a5,
		(eurjpy).a6 as eurjpy_a6,
		(eurchf).a1 as eurchf_a1,
		(eurchf).a2 as eurchf_a2,
		(eurchf).a3 as eurchf_a3,
		(eurchf).a4 as eurchf_a4,
		(eurchf).a5 as eurchf_a5,
		(eurchf).a6 as eurchf_a6,
		(audusd).a1 as audusd_a1,
		(audusd).a2 as audusd_a2,
		(audusd).a3 as audusd_a3,
		(audusd).a4 as audusd_a4,
		(audusd).a5 as audusd_a5,
		(audusd).a6 as audusd_a6,
		(gbpjpy).a1 as gbpjpy_a1,
		(gbpjpy).a2 as gbpjpy_a2,
		(gbpjpy).a3 as gbpjpy_a3,
		(gbpjpy).a4 as gbpjpy_a4,
		(gbpjpy).a5 as gbpjpy_a5,
		(gbpjpy).a6 as gbpjpy_a6,
		(chfjpy).a1 as chfjpy_a1,
		(chfjpy).a2 as chfjpy_a2,
		(chfjpy).a3 as chfjpy_a3,
		(chfjpy).a4 as chfjpy_a4,
		(chfjpy).a5 as chfjpy_a5,
		(chfjpy).a6 as chfjpy_a6,
		(gbpchf).a1 as gbpchf_a1,
		(gbpchf).a2 as gbpchf_a2,
		(gbpchf).a3 as gbpchf_a3,
		(gbpchf).a4 as gbpchf_a4,
		(gbpchf).a5 as gbpchf_a5,
		(gbpchf).a6 as gbpchf_a6,
		(nzdusd).a1 as nzdusd_a1,
		(nzdusd).a2 as nzdusd_a2,
		(nzdusd).a3 as nzdusd_a3,
		(nzdusd).a4 as nzdusd_a4,
		(nzdusd).a5 as nzdusd_a5,
		(nzdusd).a6 as nzdusd_a6,
		(cmd_choc).a1 as cmd_choc_a1,
		(cmd_choc).a2 as cmd_choc_a2,
		(cmd_choc).a3 as cmd_choc_a3,
		(cmd_choc).a4 as cmd_choc_a4,
		(cmd_choc).a5 as cmd_choc_a5,
		(cmd_choc).a6 as cmd_choc_a6,
		(cmd_corn).a1 as cmd_corn_a1,
		(cmd_corn).a2 as cmd_corn_a2,
		(cmd_corn).a3 as cmd_corn_a3,
		(cmd_corn).a4 as cmd_corn_a4,
		(cmd_corn).a5 as cmd_corn_a5,
		(cmd_corn).a6 as cmd_corn_a6,
		(cmd_ctnn).a1 as cmd_ctnn_a1,
		(cmd_ctnn).a2 as cmd_ctnn_a2,
		(cmd_ctnn).a3 as cmd_ctnn_a3,
		(cmd_ctnn).a4 as cmd_ctnn_a4,
		(cmd_ctnn).a5 as cmd_ctnn_a5,
		(cmd_ctnn).a6 as cmd_ctnn_a6,
		(cmd_cupm).a1 as cmd_cupm_a1,
		(cmd_cupm).a2 as cmd_cupm_a2,
		(cmd_cupm).a3 as cmd_cupm_a3,
		(cmd_cupm).a4 as cmd_cupm_a4,
		(cmd_cupm).a5 as cmd_cupm_a5,
		(cmd_cupm).a6 as cmd_cupm_a6,
		(cmd_foil).a1 as cmd_foil_a1,
		(cmd_foil).a2 as cmd_foil_a2,
		(cmd_foil).a3 as cmd_foil_a3,
		(cmd_foil).a4 as cmd_foil_a4,
		(cmd_foil).a5 as cmd_foil_a5,
		(cmd_foil).a6 as cmd_foil_a6,
		(cmd_gaz).a1 as cmd_gaz_a1,
		(cmd_gaz).a2 as cmd_gaz_a2,
		(cmd_gaz).a3 as cmd_gaz_a3,
		(cmd_gaz).a4 as cmd_gaz_a4,
		(cmd_gaz).a5 as cmd_gaz_a5,
		(cmd_gaz).a6 as cmd_gaz_a6,
		(cmd_gld).a1 as cmd_gld_a1,
		(cmd_gld).a2 as cmd_gld_a2,
		(cmd_gld).a3 as cmd_gld_a3,
		(cmd_gld).a4 as cmd_gld_a4,
		(cmd_gld).a5 as cmd_gld_a5,
		(cmd_gld).a6 as cmd_gld_a6,
		(cmd_hevy).a1 as cmd_hevy_a1,
		(cmd_hevy).a2 as cmd_hevy_a2,
		(cmd_hevy).a3 as cmd_hevy_a3,
		(cmd_hevy).a4 as cmd_hevy_a4,
		(cmd_hevy).a5 as cmd_hevy_a5,
		(cmd_hevy).a6 as cmd_hevy_a6,
		(cmd_ledd).a1 as cmd_ledd_a1,
		(cmd_ledd).a2 as cmd_ledd_a2,
		(cmd_ledd).a3 as cmd_ledd_a3,
		(cmd_ledd).a4 as cmd_ledd_a4,
		(cmd_ledd).a5 as cmd_ledd_a5,
		(cmd_ledd).a6 as cmd_ledd_a6,
		(cmd_lstk).a1 as cmd_lstk_a1,
		(cmd_lstk).a2 as cmd_lstk_a2,
		(cmd_lstk).a3 as cmd_lstk_a3,
		(cmd_lstk).a4 as cmd_lstk_a4,
		(cmd_lstk).a5 as cmd_lstk_a5,
		(cmd_lstk).a6 as cmd_lstk_a6,
		(cmd_nini).a1 as cmd_nini_a1,
		(cmd_nini).a2 as cmd_nini_a2,
		(cmd_nini).a3 as cmd_nini_a3,
		(cmd_nini).a4 as cmd_nini_a4,
		(cmd_nini).a5 as cmd_nini_a5,
		(cmd_nini).a6 as cmd_nini_a6,
		(cmd_oil).a1 as cmd_oil_a1,
		(cmd_oil).a2 as cmd_oil_a2,
		(cmd_oil).a3 as cmd_oil_a3,
		(cmd_oil).a4 as cmd_oil_a4,
		(cmd_oil).a5 as cmd_oil_a5,
		(cmd_oil).a6 as cmd_oil_a6,
		(cmd_pall).a1 as cmd_pall_a1,
		(cmd_pall).a2 as cmd_pall_a2,
		(cmd_pall).a3 as cmd_pall_a3,
		(cmd_pall).a4 as cmd_pall_a4,
		(cmd_pall).a5 as cmd_pall_a5,
		(cmd_pall).a6 as cmd_pall_a6,
		(cmd_pplt).a1 as cmd_pplt_a1,
		(cmd_pplt).a2 as cmd_pplt_a2,
		(cmd_pplt).a3 as cmd_pplt_a3,
		(cmd_pplt).a4 as cmd_pplt_a4,
		(cmd_pplt).a5 as cmd_pplt_a5,
		(cmd_pplt).a6 as cmd_pplt_a6,
		(cmd_sgar).a1 as cmd_sgar_a1,
		(cmd_sgar).a2 as cmd_sgar_a2,
		(cmd_sgar).a3 as cmd_sgar_a3,
		(cmd_sgar).a4 as cmd_sgar_a4,
		(cmd_sgar).a5 as cmd_sgar_a5,
		(cmd_sgar).a6 as cmd_sgar_a6,
		(cmd_slv).a1 as cmd_slv_a1,
		(cmd_slv).a2 as cmd_slv_a2,
		(cmd_slv).a3 as cmd_slv_a3,
		(cmd_slv).a4 as cmd_slv_a4,
		(cmd_slv).a5 as cmd_slv_a5,
		(cmd_slv).a6 as cmd_slv_a6,
		(cmd_soyb).a1 as cmd_soyb_a1,
		(cmd_soyb).a2 as cmd_soyb_a2,
		(cmd_soyb).a3 as cmd_soyb_a3,
		(cmd_soyb).a4 as cmd_soyb_a4,
		(cmd_soyb).a5 as cmd_soyb_a5,
		(cmd_soyb).a6 as cmd_soyb_a6,
		(cmd_uhn).a1 as cmd_uhn_a1,
		(cmd_uhn).a2 as cmd_uhn_a2,
		(cmd_uhn).a3 as cmd_uhn_a3,
		(cmd_uhn).a4 as cmd_uhn_a4,
		(cmd_uhn).a5 as cmd_uhn_a5,
		(cmd_uhn).a6 as cmd_uhn_a6,
		dow as dow,
		week as week,
		optexpday as optexpday,
		prediction as prediction
	FROM datamining_stocks_view v
		WHERE v.stockname=stcknm
    $$;


ALTER FUNCTION public.datamine_extra(stcknm character varying) OWNER TO postgres;

--
-- TOC entry 216 (class 1255 OID 21934031)
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
-- TOC entry 217 (class 1255 OID 21934032)
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
-- TOC entry 218 (class 1255 OID 21934033)
-- Name: h_bigint(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION h_bigint(text) RETURNS bigint
    LANGUAGE sql
    AS $_$
 select ('x'||substr(md5($1),1,16))::bit(64)::bigint;
$_$;


ALTER FUNCTION public.h_bigint(text) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 21934034)
-- Name: h_int(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION h_int(text) RETURNS integer
    LANGUAGE sql
    AS $_$
 select ('x'||substr(md5($1),1,8))::bit(32)::int;
$_$;


ALTER FUNCTION public.h_int(text) OWNER TO postgres;

--
-- TOC entry 199 (class 1255 OID 21934035)
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
-- TOC entry 200 (class 1255 OID 21934036)
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
	select "close" into firstAvailableClose from stocks
	  where
	    stock = stockname and
	    date <= dt
	  order by date desc
	  limit 1;

	select avg(s1."close") into avg_v from stocks s1
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
-- TOC entry 171 (class 1259 OID 41196)
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
-- TOC entry 201 (class 1255 OID 21934037)
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
-- TOC entry 202 (class 1255 OID 21934038)
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
-- TOC entry 203 (class 1255 OID 21934039)
-- Name: stockavg(text, date, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION stockavg(stockname text, dt date, intr interval) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE ret double precision;
	BEGIN
	select avg(s1."close") into ret from stocks s1
where
s1.stock = stockname and
s1.date > dt - intr and
s1.date <= dt;
	return ret;
END;
$$;


ALTER FUNCTION public.stockavg(stockname text, dt date, intr interval) OWNER TO postgres;

--
-- TOC entry 204 (class 1255 OID 21934040)
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
	select "close" into firstAvailableClose from stocks
	  where
	    stock = stockname and
	    date <= dt
	  order by date desc
	  limit 1;
	    
	select avg(s1."close") into avg_v from stocks s1
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
-- TOC entry 205 (class 1255 OID 21934041)
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
-- TOC entry 206 (class 1255 OID 21934042)
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
-- TOC entry 207 (class 1255 OID 21934043)
-- Name: sync_aggr(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sync_aggr() RETURNS integer
    LANGUAGE plpgsql
    AS $$
	DECLARE ret integer;
  BEGIN
	select sync_aggr((now() - interval '3 years')::date) into ret;
	return ret;
  END;
    $$;


ALTER FUNCTION public.sync_aggr() OWNER TO postgres;

--
-- TOC entry 208 (class 1255 OID 21934044)
-- Name: sync_aggr(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sync_aggr(startdate date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  declare retVal integer;
  BEGIN
  insert into datamine_aggr
	SELECT * from datamining_aggr_view v
		where
		v.date > startdate
		and
		(
			(v.date > (select max(d1.date) from datamine_aggr d1 where d1.stockname = v.stockname))
			or
			(not exists (select NULL from datamine_aggr d1 where d1.stockname = v.stockname))

		)
	order by v.date desc
;
	GET DIAGNOSTICS retVal = ROW_COUNT;
	return retVal;
  END;
    $$;


ALTER FUNCTION public.sync_aggr(startdate date) OWNER TO postgres;

--
-- TOC entry 209 (class 1255 OID 21934045)
-- Name: sync_aggr_all(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sync_aggr_all() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  declare retVal integer;
  BEGIN
  insert into datamine_aggr
	SELECT * from datamining_aggr_view v where
		not exists (select NULL from datamine_aggr d1 where d1.date = v.date and d1.stockname = v.stockname)
;
	GET DIAGNOSTICS retVal = ROW_COUNT;
	return retVal;
  END;
    $$;


ALTER FUNCTION public.sync_aggr_all() OWNER TO postgres;

--
-- TOC entry 210 (class 1255 OID 21934046)
-- Name: updatepredictions(text, date[], double precision[], double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION updatepredictions(stocknm text, datear date[], pricear double precision[], predictionar double precision[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM predictions where rundate = now()::date and stockname=stocknm;
	INSERT INTO predictions(
            rundate, stockname, date, origprice, prediction)
		VALUES (now()::date, stocknm, datear, pricear, predictionar);

	return 1;
END;
$$;


ALTER FUNCTION public.updatepredictions(stocknm text, datear date[], pricear double precision[], predictionar double precision[]) OWNER TO postgres;

--
-- TOC entry 180 (class 1259 OID 11887388)
-- Name: datamine_aggr; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE datamine_aggr (
    date date NOT NULL,
    stockname text NOT NULL,
    price double precision,
    stockavg avg_type,
    aord avg_type,
    n225 avg_type,
    ndx avg_type,
    dji avg_type,
    ftse avg_type,
    gdaxi avg_type,
    ssec avg_type,
    hsi avg_type,
    bsesn avg_type,
    jkse avg_type,
    klse avg_type,
    nz50 avg_type,
    sti avg_type,
    ks11 avg_type,
    twii avg_type,
    bvsp avg_type,
    gsptse avg_type,
    mxx avg_type,
    gspc avg_type,
    atx avg_type,
    bfx avg_type,
    fchi avg_type,
    oseax avg_type,
    omxspi avg_type,
    ssmi avg_type,
    gd avg_type,
    eurusd avg_type,
    usdjpy avg_type,
    usdchf avg_type,
    gbpusd avg_type,
    usdcad avg_type,
    eurgbp avg_type,
    eurjpy avg_type,
    eurchf avg_type,
    audusd avg_type,
    gbpjpy avg_type,
    chfjpy avg_type,
    gbpchf avg_type,
    nzdusd avg_type,
    cmd_choc avg_type,
    cmd_corn avg_type,
    cmd_ctnn avg_type,
    cmd_cupm avg_type,
    cmd_foil avg_type,
    cmd_gaz avg_type,
    cmd_gld avg_type,
    cmd_hevy avg_type,
    cmd_ledd avg_type,
    cmd_lstk avg_type,
    cmd_nini avg_type,
    cmd_oil avg_type,
    cmd_pall avg_type,
    cmd_pplt avg_type,
    cmd_sgar avg_type,
    cmd_slv avg_type,
    cmd_soyb avg_type,
    cmd_uhn avg_type,
    dow double precision,
    week double precision,
    optexpday integer,
    prediction double precision
);


ALTER TABLE public.datamine_aggr OWNER TO postgres;

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
-- TOC entry 2094 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.corrdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.corrdate IS 'date correlation was calculated';


--
-- TOC entry 2095 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.preddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.preddate IS 'date of last data prediction based on';


--
-- TOC entry 2096 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.active IS 'is stock active like used in calcultions';


--
-- TOC entry 181 (class 1259 OID 12555313)
-- Name: dataminestocks_py; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dataminestocks_py (
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


ALTER TABLE public.dataminestocks_py OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 21934047)
-- Name: datamining_aggr_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datamining_aggr_view AS
 SELECT s.date,
    s.stock AS stockname,
    s.close AS price,
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
   FROM (stocks s
     JOIN dataminestocks_py d ON ((d.stockname = s.stock)))
  WHERE (d.active = true)
  ORDER BY s.stock, s.date DESC;


ALTER TABLE public.datamining_aggr_view OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 21934052)
-- Name: datamining_avg_stocks_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datamining_avg_stocks_view AS
 SELECT s.date,
    s.stock AS stockname,
    s.close AS price,
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
-- TOC entry 185 (class 1259 OID 21934057)
-- Name: datamining_stocks_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datamining_stocks_view AS
 SELECT datamine_aggr.date,
    datamine_aggr.stockname,
    datamine_aggr.price,
    datamine_aggr.stockavg,
    datamine_aggr.aord,
    datamine_aggr.n225,
    datamine_aggr.ndx,
    datamine_aggr.dji,
    datamine_aggr.ftse,
    datamine_aggr.gdaxi,
    datamine_aggr.ssec,
    datamine_aggr.hsi,
    datamine_aggr.bsesn,
    datamine_aggr.jkse,
    datamine_aggr.klse,
    datamine_aggr.nz50,
    datamine_aggr.sti,
    datamine_aggr.ks11,
    datamine_aggr.twii,
    datamine_aggr.bvsp,
    datamine_aggr.gsptse,
    datamine_aggr.mxx,
    datamine_aggr.gspc,
    datamine_aggr.atx,
    datamine_aggr.bfx,
    datamine_aggr.fchi,
    datamine_aggr.oseax,
    datamine_aggr.omxspi,
    datamine_aggr.ssmi,
    datamine_aggr.gd,
    datamine_aggr.eurusd,
    datamine_aggr.usdjpy,
    datamine_aggr.usdchf,
    datamine_aggr.gbpusd,
    datamine_aggr.usdcad,
    datamine_aggr.eurgbp,
    datamine_aggr.eurjpy,
    datamine_aggr.eurchf,
    datamine_aggr.audusd,
    datamine_aggr.gbpjpy,
    datamine_aggr.chfjpy,
    datamine_aggr.gbpchf,
    datamine_aggr.nzdusd,
    datamine_aggr.cmd_choc,
    datamine_aggr.cmd_corn,
    datamine_aggr.cmd_ctnn,
    datamine_aggr.cmd_cupm,
    datamine_aggr.cmd_foil,
    datamine_aggr.cmd_gaz,
    datamine_aggr.cmd_gld,
    datamine_aggr.cmd_hevy,
    datamine_aggr.cmd_ledd,
    datamine_aggr.cmd_lstk,
    datamine_aggr.cmd_nini,
    datamine_aggr.cmd_oil,
    datamine_aggr.cmd_pall,
    datamine_aggr.cmd_pplt,
    datamine_aggr.cmd_sgar,
    datamine_aggr.cmd_slv,
    datamine_aggr.cmd_soyb,
    datamine_aggr.cmd_uhn,
    datamine_aggr.dow,
    datamine_aggr.week,
    datamine_aggr.optexpday,
    datamine_aggr.prediction
   FROM datamine_aggr
  ORDER BY datamine_aggr.stockname, datamine_aggr.date DESC;


ALTER TABLE public.datamining_stocks_view OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 21934062)
-- Name: datamining_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW datamining_view AS
 SELECT s.date,
    s.stock AS stockname,
    s.close AS price,
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
-- TOC entry 172 (class 1259 OID 41277)
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
-- TOC entry 175 (class 1259 OID 41468)
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
-- TOC entry 2097 (class 0 OID 0)
-- Dependencies: 175
-- Name: forex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE forex_id_seq OWNED BY forex.id;


--
-- TOC entry 182 (class 1259 OID 12566069)
-- Name: predictions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE predictions (
    rundate date NOT NULL,
    stockname text NOT NULL,
    date date[],
    origprice double precision[],
    prediction double precision[]
);


ALTER TABLE public.predictions OWNER TO postgres;

--
-- TOC entry 173 (class 1259 OID 41397)
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
-- TOC entry 2098 (class 0 OID 0)
-- Dependencies: 173
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
-- TOC entry 1942 (class 2604 OID 21934067)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY forex ALTER COLUMN id SET DEFAULT nextval('forex_id_seq'::regclass);


--
-- TOC entry 1941 (class 2604 OID 21934068)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stocks ALTER COLUMN id SET DEFAULT nextval('stocks_id_seq'::regclass);


--
-- TOC entry 1966 (class 2606 OID 12554484)
-- Name: PK; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY datamine_aggr
    ADD CONSTRAINT "PK" PRIMARY KEY (stockname, date);


--
-- TOC entry 1964 (class 2606 OID 41894)
-- Name: PK_instrument; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY downloadinstruments
    ADD CONSTRAINT "PK_instrument" PRIMARY KEY (instrument);


--
-- TOC entry 1959 (class 2606 OID 41476)
-- Name: forex_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY forex
    ADD CONSTRAINT forex_pkey PRIMARY KEY (id);


--
-- TOC entry 1962 (class 2606 OID 41766)
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dataminestocks
    ADD CONSTRAINT id PRIMARY KEY (stockname);


--
-- TOC entry 1971 (class 2606 OID 12555323)
-- Name: pk_dataminestocks_py; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dataminestocks_py
    ADD CONSTRAINT pk_dataminestocks_py PRIMARY KEY (stockname);


--
-- TOC entry 1973 (class 2606 OID 12566080)
-- Name: predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (rundate, stockname);


--
-- TOC entry 1952 (class 2606 OID 12567905)
-- Name: stocks_date_stock_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_date_stock_key UNIQUE (date, stock);


--
-- TOC entry 1954 (class 2606 OID 41407)
-- Name: stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- TOC entry 1960 (class 1259 OID 19279399)
-- Name: dataminestocks_stockname_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dataminestocks_stockname_idx ON dataminestocks USING btree (stockname);


--
-- TOC entry 1967 (class 1259 OID 12554471)
-- Name: date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX date ON datamine_aggr USING btree (date DESC);


--
-- TOC entry 1957 (class 1259 OID 41467)
-- Name: forex_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX forex_date_idx ON forex USING btree (date);


--
-- TOC entry 1968 (class 1259 OID 11887396)
-- Name: stock_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stock_date ON datamine_aggr USING btree (stockname, date DESC);


--
-- TOC entry 1969 (class 1259 OID 11887398)
-- Name: stockname; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stockname ON datamine_aggr USING btree (stockname);


--
-- TOC entry 1949 (class 1259 OID 42015)
-- Name: stocks_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_date_idx ON stocks USING btree (date);


--
-- TOC entry 1950 (class 1259 OID 41408)
-- Name: stocks_date_stock_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_date_stock_idx ON stocks USING btree (date, stock);


--
-- TOC entry 1955 (class 1259 OID 41414)
-- Name: stocks_stock_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_stock_date_idx ON stocks USING btree (stock, date);


--
-- TOC entry 1956 (class 1259 OID 42014)
-- Name: stocks_stock_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_stock_idx ON stocks USING btree (stock);


--
-- TOC entry 2092 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-02-16 23:17:40 AEDT

--
-- PostgreSQL database dump complete
--

