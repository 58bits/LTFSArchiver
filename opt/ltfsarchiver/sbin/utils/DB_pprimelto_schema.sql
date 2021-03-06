--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: ltfsarchiver; Type: DATABASE; Schema: -; Owner: pprime
--

CREATE DATABASE ltfsarchiver WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'it_IT.utf8' LC_CTYPE = 'it_IT.utf8';


ALTER DATABASE ltfsarchiver OWNER TO pprime;

\connect ltfsarchiver

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: lock_table; Type: TABLE; Schema: public; Owner: pprime; Tablespace: 
--

CREATE TABLE lock_table (
    device character varying(32),
    ltolabel character varying(8)
);


ALTER TABLE public.lock_table OWNER TO pprime;

--
-- Name: lto_info; Type: TABLE; Schema: public; Owner: pprime; Tablespace: 
--

CREATE TABLE lto_info (
    label character varying(8),
    free integer,
    booked integer,
    inuse character varying(1),
    poolname character varying(16),
    ltotype character varying(4) DEFAULT 'n/a'::character varying
);


ALTER TABLE public.lto_info OWNER TO pprime;

--
-- Name: requests; Type: TABLE; Schema: public; Owner: pprime; Tablespace: 
--

CREATE TABLE requests (
    id integer NOT NULL,
    uuid character varying(36) NOT NULL,
    status character varying(10),
    substatus integer,
    operation character varying(1) NOT NULL,
    manager character varying(1) NOT NULL,
    sourcefile character varying(255) NOT NULL,
    md5create boolean,
    md5value text,
    sourcesize integer,
    datatype character varying(1),
    destfile character varying(255),
    callinghost character varying(64),
    poolname character varying(8),
    callingtime timestamp with time zone NOT NULL,
    starttime timestamp with time zone,
    endtime timestamp with time zone,
    errorcode integer,
    errordescription text,
    ltotape character varying(8) DEFAULT 'n/a'::character varying,
    ltolibrary character varying(32),
    temp character varying(255),
    device character varying(32) DEFAULT 'n/a'::character varying
);


ALTER TABLE public.requests OWNER TO pprime;

--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: pprime
--

CREATE SEQUENCE requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.requests_id_seq OWNER TO pprime;

--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pprime
--

ALTER SEQUENCE requests_id_seq OWNED BY requests.id;


--
-- Name: requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pprime
--

SELECT pg_catalog.setval('requests_id_seq', 141, true);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pprime
--

ALTER TABLE ONLY requests ALTER COLUMN id SET DEFAULT nextval('requests_id_seq'::regclass);

