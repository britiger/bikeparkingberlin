
SET client_min_messages TO WARNING;

-- Add Nextbike
INSERT INTO extern.rental_nextbike (city, api_ids, target_network, target_operator, search_values, center_lat, center_lon, admin_osm_id) VALUES ('Potsdam', ARRAY[158], 'PotsdamRad', 'nextbike GmbH', ARRAY['%PotsdamRad%', '%Potsdam Rad%', '%Potsdam-Rad%', '%nextbike%'], 52.3988, 13.0656, -62369);

-- Create View with all rental stations potsdam
CREATE OR REPLACE VIEW imposm3.view_rental_potsdam AS
SELECT * 
FROM imposm3.view_rental
WHERE ST_WITHIN(geom, (SELECT ST_Union(geom) FROM imposm3.osm_borders WHERE osm_id=-62369 OR osm_id=-365821 OR osm_id=-531654 OR osm_id=-332537));

-- All rental stations should exists
CREATE OR REPLACE VIEW extern.all_rental_nextbike_potsdam AS
SELECT nb.target_network, nb.target_operator, all_rental_nextbike.* 
FROM extern.all_rental_nextbike 
    LEFT JOIN extern.rental_nextbike nb ON api_ids && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Potsdam')
WHERE ARRAY[api_id] && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Potsdam');

-- All rental stations found in osm for operator
CREATE OR REPLACE VIEW extern.osm_rental_nextbike_potsdam AS
SELECT * 
FROM imposm3.view_rental_potsdam
WHERE 
    "name" ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_nextbike WHERE city = 'Potsdam')
    OR network ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_nextbike WHERE city = 'Potsdam')
    OR operator ILIKE ANY(SELECT unnest(search_values) FROM extern.rental_nextbike WHERE city = 'Potsdam');

-- All rental stations missing
CREATE OR REPLACE VIEW extern.missing_rental_nextbike_potsdam AS
SELECT potsdam.*, ST_AsGeoJSON(st_transform(potsdam.geom,4326)) as geojson
FROM extern.all_rental_nextbike_potsdam potsdam
LEFT JOIN extern.osm_rental_nextbike_potsdam osm
ON osm.geom && ST_Expand(st_transform(potsdam.geom,3857), 50)
WHERE osm.osm_id IS NULL;

-- All rental stations matches - Multiple entries if
CREATE OR REPLACE VIEW extern.existing_rental_nextbike_potsdam AS
SELECT osm.osm_id int_osm_id, osm.network int_network, osm.operator int_operator, osm.ref int_ref, osm.name int_name, osm.typ int_typ,
    potsdam.*, 
    ST_AsGeoJSON(st_transform(potsdam.geom,4326)) as geojson,
    ST_AsGeoJSON(st_transform(osm.geom,4326)) as osm_geojson,
    ST_Distance(osm.geom, potsdam.geom) AS distance
FROM extern.all_rental_nextbike_potsdam potsdam
    LEFT JOIN extern.osm_rental_nextbike_potsdam osm
        ON osm.geom && ST_Expand(st_transform(potsdam.geom,3857), 50)
WHERE potsdam.uid NOT IN (SELECT uid FROM extern.missing_rental_nextbike_potsdam);

-- All rental stations matches
CREATE OR REPLACE VIEW extern.unknown_rental_nextbike_potsdam AS
SELECT osm.osm_id int_osm_id, osm.network int_network, osm.operator int_operator, osm.ref int_ref, osm.name int_name, osm.typ int_typ,
    ST_AsGeoJSON(st_transform(osm.geom,4326)) as geojson,
    ST_X(st_transform(osm.geom,4326)) AS lon, ST_Y(st_transform(osm.geom,4326)) AS lat,
    osm.geom
FROM extern.osm_rental_nextbike_potsdam osm
WHERE osm.osm_id NOT IN (SELECT int_osm_id FROM extern.existing_rental_nextbike_potsdam);
