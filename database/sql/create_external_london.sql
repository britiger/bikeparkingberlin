SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='London';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level) 
    VALUES ('London',
        'london_mix',
        'Transport for London - Transport Data Service - Cycling incl. MapInfo',
        'https://cycling.data.tfl.gov.uk/',
        'Open Government License Version 2.0 - Powered by TfL Open Data',
        'https://tfl.gov.uk/corporate/terms-and-conditions/transport-data-service',
        51.509865, -0.1180, 15);

-- Create Views for London matching both sources:
--   - all_parking_london
--   - all_parking_london_map
DROP VIEW IF EXISTS extern.view_london_compare CASCADE;
CREATE VIEW extern.view_london_compare AS
    SELECT RANK() OVER (PARTITION BY lm.ogc_fid ORDER BY ST_Distance(l.geom, lm.geom)) as int_ranking, 
        l.*, 
        lm.cpuniqueid, lm.correct_as_of, lm.station_name, lm.cycle_parking_present_, lm.any_cycle_parking_within_statio, lm.location_number,
        lm.number_of_parking_spaces, lm.type_updated, lm.type, lm.location, lm.rough_distance_from_closest_sta, lm.covered_by, lm.covered,
        lm.secure_cycle_storage_available, lm.pump_and_repair_facilities, lm.photo_hyperlink
    FROM extern.all_parking_london_map lm 
        INNER JOIN extern.all_parking_london l
        ON ST_Distance(l.geom, lm.geom) < 15;

-- Create all_parking_london_mix
DROP MATERIALIZED VIEW IF EXISTS extern.all_parking_london_mix;
CREATE MATERIALIZED VIEW extern.all_parking_london_mix AS
WITH nearbys AS (SELECT * FROM extern.view_london_compare WHERE int_ranking = 1)
SELECT * FROM nearbys
UNION ALL
SELECT NULL, *, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL
FROM extern.all_parking_london WHERE ogc_fid NOT IN (SELECT ogc_fid FROM nearbys)
UNION ALL
SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    cpuniqueid, correct_as_of, station_name, cycle_parking_present_, any_cycle_parking_within_statio, location_number,
    number_of_parking_spaces, type_updated, "type", "location", rough_distance_from_closest_sta, covered_by, covered,
    secure_cycle_storage_available, pump_and_repair_facilities, photo_hyperlink
FROM extern.all_parking_london_map WHERE cpuniqueid NOT IN (SELECT cpuniqueid FROM nearbys);
