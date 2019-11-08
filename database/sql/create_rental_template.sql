
-- All rental stations found in osm for operator
CREATE OR REPLACE VIEW extern.osm_rental_#SUFFIX# AS
SELECT * 
FROM imposm3.view_rental_#AREA#
WHERE 
    "name" ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_data WHERE city = '#CITY#' AND brand='#BRAND#')
    OR network ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_data WHERE city = '#CITY#' AND brand='#BRAND#')
    OR operator ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_data WHERE city = '#CITY#' AND brand='#BRAND#');

-- All rental stations missing
CREATE OR REPLACE VIEW extern.missing_rental_#SUFFIX# AS
SELECT city.*, ST_AsGeoJSON(st_transform(city.geom,4326)) as geojson
FROM extern.all_rental_#SUFFIX# city
LEFT JOIN extern.osm_rental_#SUFFIX# osm
ON osm.geom && ST_Expand(st_transform(city.geom,3857), 50)
WHERE osm.osm_id IS NULL;

-- All rental stations matches - Multiple entries possible
CREATE OR REPLACE VIEW extern.existing_rental_#SUFFIX# AS
SELECT osm.osm_id int_osm_id, osm.network int_network, osm.operator int_operator, osm.ref int_ref, osm.name int_name, osm.typ int_typ,
    city.*, 
    ST_AsGeoJSON(st_transform(city.geom,4326)) as geojson,
    ST_AsGeoJSON(st_transform(osm.geom,4326)) as osm_geojson,
    ST_Distance(osm.geom, city.geom) AS distance
FROM extern.all_rental_#SUFFIX# city
    LEFT JOIN extern.osm_rental_#SUFFIX# osm
        ON osm.geom && ST_Expand(st_transform(city.geom,3857), 50)
WHERE city.uid NOT IN (SELECT uid FROM extern.missing_rental_#SUFFIX#);

-- All rental stations matches
CREATE OR REPLACE VIEW extern.unknown_rental_#SUFFIX# AS
SELECT osm.osm_id int_osm_id, osm.network int_network, osm.operator int_operator, osm.ref int_ref, osm.name int_name, osm.typ int_typ,
    ST_AsGeoJSON(st_transform(osm.geom,4326)) as geojson,
    ST_X(st_transform(osm.geom,4326)) AS lon, ST_Y(st_transform(osm.geom,4326)) AS lat,
    osm.geom
FROM extern.osm_rental_#SUFFIX# osm
WHERE osm.osm_id NOT IN (SELECT int_osm_id FROM extern.existing_rental_#SUFFIX#);