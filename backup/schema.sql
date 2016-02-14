--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.10
-- Dumped by pg_dump version 9.3.10
-- Started on 2016-02-14 22:45:39 AEDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

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
-- TOC entry 182 (class 1259 OID 11887388)
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
-- TOC entry 2078 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.corrdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.corrdate IS 'date correlation was calculated';


--
-- TOC entry 2079 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.preddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.preddate IS 'date of last data prediction based on';


--
-- TOC entry 2080 (class 0 OID 0)
-- Dependencies: 176
-- Name: COLUMN dataminestocks.active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dataminestocks.active IS 'is stock active like used in calcultions';


--
-- TOC entry 184 (class 1259 OID 12555313)
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
-- TOC entry 177 (class 1259 OID 41750)
-- Name: downloadinstruments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE downloadinstruments (
    instrument text NOT NULL,
    type text
);


ALTER TABLE public.downloadinstruments OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 12566069)
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
-- TOC entry 2081 (class 0 OID 0)
-- Dependencies: 172
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE stocks_id_seq OWNED BY stocks.id;


--
-- TOC entry 1927 (class 2604 OID 41399)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY stocks ALTER COLUMN id SET DEFAULT nextval('stocks_id_seq'::regclass);


--
-- TOC entry 1948 (class 2606 OID 12554484)
-- Name: PK; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY datamine_aggr
    ADD CONSTRAINT "PK" PRIMARY KEY (stockname, date);


--
-- TOC entry 1946 (class 2606 OID 41894)
-- Name: PK_instrument; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY downloadinstruments
    ADD CONSTRAINT "PK_instrument" PRIMARY KEY (instrument);


--
-- TOC entry 1944 (class 2606 OID 41766)
-- Name: id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dataminestocks
    ADD CONSTRAINT id PRIMARY KEY (stockname);


--
-- TOC entry 1953 (class 2606 OID 12555323)
-- Name: pk_dataminestocks_py; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dataminestocks_py
    ADD CONSTRAINT pk_dataminestocks_py PRIMARY KEY (stockname);


--
-- TOC entry 1955 (class 2606 OID 12566080)
-- Name: predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (rundate, stockname);


--
-- TOC entry 1937 (class 2606 OID 12567905)
-- Name: stocks_date_stock_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_date_stock_key UNIQUE (date, stock);


--
-- TOC entry 1939 (class 2606 OID 41407)
-- Name: stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- TOC entry 1942 (class 1259 OID 19279399)
-- Name: dataminestocks_stockname_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dataminestocks_stockname_idx ON dataminestocks USING btree (stockname);


--
-- TOC entry 1949 (class 1259 OID 12554471)
-- Name: date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX date ON datamine_aggr USING btree (date DESC);


--
-- TOC entry 1950 (class 1259 OID 11887396)
-- Name: stock_date; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stock_date ON datamine_aggr USING btree (stockname, date DESC);


--
-- TOC entry 1951 (class 1259 OID 11887398)
-- Name: stockname; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stockname ON datamine_aggr USING btree (stockname);


--
-- TOC entry 1934 (class 1259 OID 42015)
-- Name: stocks_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_date_idx ON stocks USING btree (date);


--
-- TOC entry 1935 (class 1259 OID 41408)
-- Name: stocks_date_stock_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_date_stock_idx ON stocks USING btree (date, stock);


--
-- TOC entry 1940 (class 1259 OID 41414)
-- Name: stocks_stock_date_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_stock_date_idx ON stocks USING btree (stock, date);


--
-- TOC entry 1941 (class 1259 OID 42014)
-- Name: stocks_stock_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX stocks_stock_idx ON stocks USING btree (stock);


-- Completed on 2016-02-14 22:45:39 AEDT

--
-- PostgreSQL database dump complete
--

