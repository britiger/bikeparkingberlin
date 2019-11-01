
SET client_min_messages TO WARNING;

-- Add Nextbike
INSERT INTO extern.rental_nextbike (city, api_ids, target_network, target_operator, search_values, center_lat, center_lon, admin_osm_id) VALUES ('Berlin', ARRAY[362], 'Deezer nextbike', 'nextbike GmbH', ARRAY['%deezer%', '%nextbike%'], 52.520008, 13.404954, -62422);

-- Create View with all rental stations berlin
CREATE OR REPLACE VIEW imposm3.view_rental_berlin AS
SELECT * 
FROM imposm3.view_rental
WHERE ST_WITHIN(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=-62422));

-- All rental stations should exists
CREATE OR REPLACE VIEW extern.all_rental_nextbike_berlin AS
SELECT nb.target_network, nb.target_operator, all_rental_nextbike.* 
FROM extern.all_rental_nextbike 
    LEFT JOIN extern.rental_nextbike nb ON api_ids && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Berlin')
WHERE ARRAY[api_id] && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Berlin');

-- All rental stations found in osm for operator
CREATE OR REPLACE VIEW extern.osm_rental_nextbike_berlin AS
SELECT * 
FROM imposm3.view_rental_berlin
WHERE 
    "name" ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_nextbike WHERE city = 'Berlin')
    OR network ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_nextbike WHERE city = 'Berlin')
    OR operator ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_nextbike WHERE city = 'Berlin');

-- All rental stations missing
CREATE OR REPLACE VIEW extern.missing_rental_nextbike_berlin AS
SELECT berlin.*, ST_AsGeoJSON(st_transform(berlin.geom,4326)) as geojson
FROM extern.all_rental_nextbike_berlin berlin
LEFT JOIN extern.osm_rental_nextbike_berlin osm
ON osm.geom && ST_Expand(st_transform(berlin.geom,3857), 50)
WHERE osm.osm_id IS NULL;

-- All rental stations matches - Multiple entries if
CREATE OR REPLACE VIEW extern.existing_rental_nextbike_berlin AS
SELECT osm.osm_id int_osm_id, osm.network int_network, osm.operator int_operator, osm.ref int_ref, osm.name int_name, osm.typ int_typ,
    berlin.*, 
    ST_AsGeoJSON(st_transform(berlin.geom,4326)) as geojson,
    ST_AsGeoJSON(st_transform(osm.geom,4326)) as osm_geojson,
    ST_Distance(osm.geom, berlin.geom) AS distance
FROM extern.all_rental_nextbike_berlin berlin
    LEFT JOIN extern.osm_rental_nextbike_berlin osm
        ON osm.geom && ST_Expand(st_transform(berlin.geom,3857), 50)
WHERE berlin.uid NOT IN (SELECT uid FROM extern.missing_rental_nextbike_berlin);

-- All rental stations matches
CREATE OR REPLACE VIEW extern.unknown_rental_nextbike_berlin AS
SELECT osm.osm_id int_osm_id, osm.network int_network, osm.operator int_operator, osm.ref int_ref, osm.name int_name, osm.typ int_typ,
    ST_AsGeoJSON(st_transform(osm.geom,4326)) as geojson,
    ST_X(st_transform(osm.geom,4326)) AS lon, ST_Y(st_transform(osm.geom,4326)) AS lat,
    osm.geom
FROM extern.osm_rental_nextbike_berlin osm
WHERE osm.osm_id NOT IN (SELECT int_osm_id FROM extern.existing_rental_nextbike_berlin);
