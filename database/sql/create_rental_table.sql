SET client_min_messages TO WARNING;

CREATE SCHEMA IF NOT EXISTS extern;

CREATE TABLE IF NOT EXISTS extern.rental_generic (
    id SERIAL,
    city VARCHAR(255) NOT NULL,
    brand VARCHAR(255) NOT NULL,
    suffix VARCHAR(255) NOT NULL UNIQUE,
    target_network VARCHAR(255),
    target_operator VARCHAR(255),
    search_values VARCHAR(255)[],
    center_lat FLOAT,
    center_lon FLOAT,
    admin_osm_id BIGINT[]
);

-- Nextbike
CREATE TABLE IF NOT EXISTS extern.rental_nextbike (
    id SERIAL,
    city VARCHAR(255) NOT NULL UNIQUE,
    api_ids INT[],
    target_network VARCHAR(255),
    target_operator VARCHAR(255),
    search_values VARCHAR(255)[],
    center_lat FLOAT,
    center_lon FLOAT,
    admin_osm_id BIGINT[]
);

CREATE TABLE IF NOT EXISTS extern.all_rental_nextbike (
    "api_id" INT,
    "uid" INT,
    "lat" FLOAT,
    "lon" FLOAT,
    "name" VARCHAR(255),
    "number" INT,
    geom geometry(Geometry,3857)
);

-- fLotte
CREATE TABLE IF NOT EXISTS extern.all_rental_flotte (
    "uid" SERIAL,
    location_name VARCHAR(255),
    street VARCHAR(255),
    city VARCHAR(255),
    zip VARCHAR(255),
    lat FLOAT,
    lon FLOAT,
    items_cnt INT,
    geom geometry(Geometry,3857)
);

-- clean tables if already exists before
TRUNCATE TABLE extern.rental_generic;
TRUNCATE TABLE extern.rental_nextbike;
TRUNCATE TABLE extern.all_rental_nextbike;
TRUNCATE TABLE extern.all_rental_flotte;

CREATE OR REPLACE VIEW extern.rental_data AS
    SELECT city, brand, suffix, target_network, target_operator, search_values, center_lat, center_lon, admin_osm_id 
    FROM extern.rental_generic
UNION ALL
    SELECT city, 'nextbike' AS brand, 'nextbike_'||LOWER(city) AS suffix, target_network, target_operator, search_values, center_lat, center_lon, admin_osm_id
    FROM extern.rental_nextbike;
