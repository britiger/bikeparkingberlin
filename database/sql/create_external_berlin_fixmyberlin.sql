SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Berlin Friedrichshain-Kreuzberg';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id) 
    VALUES ('Berlin Friedrichshain-Kreuzberg',
        'berlin_fixmyberlin',
        'FixMyBerlin',
        'https://fixmyberlin.de/meldungen/radbuegel/friedrichshain-kreuzberg/karte',
        'ODbL Lizenz',
        'https://opendatacommons.org/licenses/odbl/',
        52.5, 13.433333, 13, -55764;

DROP VIEW IF EXISTS extern.fixmyberlin_view CASCADE;
CREATE VIEW extern.fixmyberlin_view AS 
SELECT
    jsonb_array_elements(data)->>'id' AS ogc_fid,
    jsonb_array_elements(data)->>'id' AS id,
--    jsonb_array_elements(data)->>'url' AS url,
    jsonb_array_elements(data)->>'status' AS status,
    jsonb_array_elements(data)->>'address' AS address,
    jsonb_array_elements(data)->'details'->>'subject' AS subject,
    jsonb_array_elements(data)->>'description' AS description,
    jsonb_array_elements(data)->'geometry'->'coordinates'->>1 AS lat,
    jsonb_array_elements(data)->'geometry'->'coordinates'->>0 AS lon
FROM extern.fixmyberlin_import;

DROP MATERIALIZED VIEW IF EXISTS extern.all_parking_berlin_fixmyberlin CASCADE;
CREATE MATERIALIZED VIEW extern.all_parking_berlin_fixmyberlin AS
SELECT *, ST_TRANSFORM(ST_SetSRID(ST_MakePoint(lon::float, lat::float),4326),3857) as geom
FROM extern.fixmyberlin_view
WHERE status='done' OR status='execution';
