
SET client_min_messages TO WARNING;

-- Add Nextbike
INSERT INTO extern.rental_nextbike (city, api_ids, target_brand, target_network, target_operator, search_values, center_lat, center_lon, admin_osm_id) VALUES ('Berlin', ARRAY[362], 'nextbike Berlin', 'nextbike Berlin', 'nextbike GmbH', ARRAY['%nextbike%','%by Edeka%'], 52.520008, 13.404954, ARRAY[-62422]);

-- Create View with all rental stations berlin
CREATE OR REPLACE VIEW imposm3.view_rental_berlin AS
SELECT * 
FROM imposm3.view_rental
WHERE ST_WITHIN(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=-62422));

-- All rental stations should exists
CREATE OR REPLACE VIEW extern.all_rental_nextbike_berlin AS
SELECT all_rental_nextbike.* 
FROM extern.all_rental_nextbike 
    LEFT JOIN extern.rental_nextbike nb ON api_ids && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Berlin')
WHERE ARRAY[api_id] && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Berlin');


-- Add fLotte
INSERT INTO extern.rental_generic (city, brand, suffix, target_network, target_operator, search_values, center_lat, center_lon, admin_osm_id, datasource, datasource_link, license, license_link) VALUES ('Berlin', 'fLotte', 'flotte', 'fLotte', NULL, ARRAY['%flotte%'], 52.520008, 13.404954, ARRAY[-62422,-62369,-1310102],'fLotte Berlin','https://flotte-berlin.de/','unkown license','https://flotte-berlin.de/ueber-uns/');

-- Create View with all rental stations berlin
CREATE OR REPLACE VIEW imposm3.view_rental_berlin_flotte AS
SELECT * 
FROM imposm3.view_rental
WHERE ST_WITHIN(geom, (SELECT ST_Union(geom) FROM imposm3.osm_borders WHERE osm_id IN (SELECT unnest(admin_osm_id) FROM extern.rental_generic WHERE city='Berlin' AND brand='fLotte')));
