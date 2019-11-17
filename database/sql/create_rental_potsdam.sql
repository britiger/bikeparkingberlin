
SET client_min_messages TO WARNING;

-- Add Nextbike
INSERT INTO extern.rental_nextbike (city, api_ids, target_brand, target_network, target_operator, search_values, center_lat, center_lon, admin_osm_id) VALUES ('Potsdam', ARRAY[158], 'PotsdamRad', 'PotsdamRad', 'nextbike GmbH', ARRAY['%PotsdamRad%', '%Potsdam Rad%', '%Potsdam-Rad%', '%nextbike%'], 52.3988, 13.0656, ARRAY[-62369,-365821,-531654,-332537]);

-- Create View with all rental stations potsdam
CREATE OR REPLACE VIEW imposm3.view_rental_potsdam_nb AS
SELECT * 
FROM imposm3.view_rental
WHERE ST_WITHIN(geom, (SELECT ST_Union(geom) FROM imposm3.osm_borders WHERE osm_id IN(SELECT unnest(admin_osm_id) FROM extern.rental_nextbike WHERE city='Potsdam')));

-- All rental stations should exists
CREATE OR REPLACE VIEW extern.all_rental_nextbike_potsdam AS
SELECT nb.target_network, nb.target_operator, all_rental_nextbike.* 
FROM extern.all_rental_nextbike 
    LEFT JOIN extern.rental_nextbike nb ON api_ids && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Potsdam')
WHERE ARRAY[api_id] && (SELECT api_ids FROM extern.rental_nextbike WHERE city = 'Potsdam');
