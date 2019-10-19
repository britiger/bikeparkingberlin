SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='London';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id, is_cluster) 
    VALUES ('London',
        'london_mix',
        'Transport for London - Transport Data Service - Cycling incl. MapInfo',
        'https://cycling.data.tfl.gov.uk/',
        'Open Government License Version 2.0 - Powered by TfL Open Data',
        'https://tfl.gov.uk/corporate/terms-and-conditions/transport-data-service',
        51.509865, -0.1180, 15, -65606, true);

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

-- Cluster all_parking_london_mix_cluster
DROP VIEW IF EXISTS extern.help_all_parking_london_mix_cluster CASCADE;
CREATE VIEW extern.help_all_parking_london_cluster AS
SELECT 
    *,
    ST_ClusterDBSCAN(geom, 20, 1) OVER () AS cluster_id
FROM extern.all_parking_london_mix;

DROP MATERIALIZED VIEW IF EXISTS extern.all_parking_london_mix_cluster CASCADE;
CREATE MATERIALIZED VIEW extern.all_parking_london_mix_cluster AS
SELECT 
    cluster_id AS ogc_fid,
    string_agg(feature_id, '; ') AS feature_ids,
    string_agg(DISTINCT svdate::text, '; ') AS svdates,
    string_agg(DISTINCT prk_carr, '; ') AS prk_carrs,
    string_agg(DISTINCT prk_cover, '; ') AS prk_covers,
    string_agg(DISTINCT prk_secure, '; ') AS prk_secures,
    string_agg(DISTINCT prk_locker, '; ') AS prk_lockers,
    string_agg(DISTINCT prk_sheff, '; ') AS prk_sheffs,
    string_agg(DISTINCT prk_mstand, '; ') AS prk_mstands,
    string_agg(DISTINCT prk_pstand, '; ') AS prk_pstand,
    string_agg(DISTINCT prk_hoop, '; ') AS prk_hoop,
    string_agg(DISTINCT prk_post, '; ') AS prk_post,
    string_agg(DISTINCT prk_buterf, '; ') AS prk_buterf,
    string_agg(DISTINCT prk_wheel, '; ') AS prk_wheel,
    string_agg(DISTINCT prk_hangar, '; ') AS prk_hangar,
    string_agg(DISTINCT prk_tier, '; ') AS prk_tier,
    string_agg(DISTINCT prk_other, '; ') AS prk_other,
    string_agg(DISTINCT prk_provis::text, ' + ') AS prk_provis,
    string_agg(DISTINCT prk_cpt::text, ' + ') AS prk_cpt,
    string_agg(DISTINCT borough, '; ') AS borough,
    --
    string_agg(DISTINCT cpuniqueid, '; ') AS cpuniqueid,
    string_agg(DISTINCT correct_as_of, '; ') AS correct_as_of,
    string_agg(DISTINCT station_name, '; ') AS station_name,
    string_agg(DISTINCT cycle_parking_present_, '; ') AS cycle_parking_present_,
    string_agg(DISTINCT location_number::text, '; ') AS location_number,
    string_agg(DISTINCT number_of_parking_spaces::text, ' + ') AS number_of_parking_spaces,
    string_agg(DISTINCT type_updated, '; ') AS type_updated,
    string_agg(DISTINCT "type", '; ') AS "type",
    string_agg(DISTINCT "location", '; ') AS "location",
    string_agg(DISTINCT rough_distance_from_closest_sta, '; ') AS rough_distance_from_closest_sta,
    string_agg(DISTINCT covered_by, '; ') AS covered_by,
    string_agg(DISTINCT covered, '; ') AS covered,
    string_agg(DISTINCT secure_cycle_storage_available, '; ') AS secure_cycle_storage_available,
    string_agg(DISTINCT pump_and_repair_facilities, '; ') AS pump_and_repair_facilities,
    ST_Union(geom) AS geom
FROM extern.help_all_parking_london_cluster
GROUP BY cluster_id;
