SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: monetary_amount; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.monetary_amount AS (
	value double precision,
	currency character varying(3)
);


--
-- Name: product_scrub_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.product_scrub_status AS ENUM (
    'unspecified',
    'success',
    'gone'
);


--
-- Name: product_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.product_status AS ENUM (
    'preliminary',
    'on_moderation',
    'failed_moderation',
    'published',
    'unpublished',
    'archived'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: marketplace_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplace_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_id uuid NOT NULL,
    instance_name character varying,
    marketplace_id bigint NOT NULL,
    credentials public.hstore,
    is_valid boolean DEFAULT true,
    last_sync_at_products timestamp(6) without time zone,
    deleted_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN marketplace_credentials.instance_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.marketplace_credentials.instance_name IS 'user login to the marketplace';


--
-- Name: COLUMN marketplace_credentials.is_valid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.marketplace_credentials.is_valid IS 'result of checking marketplace credentials';


--
-- Name: COLUMN marketplace_credentials.last_sync_at_products; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.marketplace_credentials.last_sync_at_products IS 'date and time of last synchronization with the marketplace';


--
-- Name: marketplaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketplaces (
    id bigint NOT NULL,
    logo character varying,
    name character varying NOT NULL,
    label character varying,
    credential_attributes public.hstore,
    product_url character varying,
    product_url_attr character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN marketplaces.logo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.marketplaces.logo IS 'link to image';


--
-- Name: COLUMN marketplaces.credential_attributes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.marketplaces.credential_attributes IS 'list of oAuth attributes';


--
-- Name: COLUMN marketplaces.product_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.marketplaces.product_url IS 'Url to product on the marketplace by Id';


--
-- Name: COLUMN marketplaces.product_url_attr; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.marketplaces.product_url_attr IS 'type of Id in product Url';


--
-- Name: marketplaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marketplaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marketplaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marketplaces_id_seq OWNED BY public.marketplaces.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    marketplace_credential_id uuid NOT NULL,
    offer_id character varying,
    product_id character varying,
    name character varying NOT NULL,
    description text,
    skus character varying[],
    images character varying[],
    barcodes character varying[],
    status public.product_status DEFAULT 'preliminary'::public.product_status NOT NULL,
    scrub_status public.product_scrub_status DEFAULT 'unspecified'::public.product_scrub_status NOT NULL,
    price public.monetary_amount,
    stock integer,
    category_title character varying,
    schemes character varying[],
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: COLUMN products.offer_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.offer_id IS 'client SKU';


--
-- Name: COLUMN products.product_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.product_id IS 'marketplace object, articule or model';


--
-- Name: COLUMN products.skus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.skus IS 'marketplace SKUs';


--
-- Name: COLUMN products.schemes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.products.schemes IS 'sales schemes';


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: marketplaces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplaces ALTER COLUMN id SET DEFAULT nextval('public.marketplaces_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: marketplace_credentials marketplace_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_credentials
    ADD CONSTRAINT marketplace_credentials_pkey PRIMARY KEY (id);


--
-- Name: marketplaces marketplaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplaces
    ADD CONSTRAINT marketplaces_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_marketplace_credentials_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_marketplace_credentials_on_client_id ON public.marketplace_credentials USING btree (client_id);


--
-- Name: index_marketplace_credentials_on_marketplace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_marketplace_credentials_on_marketplace_id ON public.marketplace_credentials USING btree (marketplace_id);


--
-- Name: index_products_on_barcodes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_barcodes ON public.products USING gin (barcodes);


--
-- Name: index_products_on_marketplace_credential_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_marketplace_credential_id ON public.products USING btree (marketplace_credential_id);


--
-- Name: index_products_on_schemes; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_schemes ON public.products USING gin (schemes);


--
-- Name: index_products_on_skus; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_skus ON public.products USING gin (skus);


--
-- Name: product_heritage; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_heritage ON public.products USING btree (marketplace_credential_id, offer_id, product_id);


--
-- Name: marketplace_credentials fk_rails_44610a99bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_credentials
    ADD CONSTRAINT fk_rails_44610a99bd FOREIGN KEY (marketplace_id) REFERENCES public.marketplaces(id);


--
-- Name: products fk_rails_790b5e9085; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_rails_790b5e9085 FOREIGN KEY (marketplace_credential_id) REFERENCES public.marketplace_credentials(id);


--
-- Name: marketplace_credentials fk_rails_b90df0faf7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketplace_credentials
    ADD CONSTRAINT fk_rails_b90df0faf7 FOREIGN KEY (client_id) REFERENCES public.clients(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240106161532'),
('20240106161520'),
('20240106161507'),
('20240106161419');

