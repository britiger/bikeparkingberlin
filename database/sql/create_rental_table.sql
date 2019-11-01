SET client_min_messages TO WARNING;

-- TODO: Generic for all operators
CREATE SCHEMA IF NOT EXISTS extern;

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
    admin_osm_id BIGINT
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

-- clean tables if already exists before
TRUNCATE TABLE extern.rental_nextbike;
TRUNCATE TABLE extern.all_rental_nextbike;

CREATE OR REPLACE VIEW extern.rental_data AS
    SELECT *, 'nextbike_'||LOWER(city) AS suffix
    FROM extern.rental_nextbike;
