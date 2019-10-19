SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Berlin';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id, is_cluster) 
    VALUES ('Berlin',
        'berlin',
        'FIS-Brocker - Geoportal Berlin / Straßenbefahrung 2014 - Fahrradständer (WFS)',
        'https://fbinter.stadt-berlin.de/fb/index.jsp',
        'Datenlizenz Deutschland - Namensnennung - Version 2.0',
        'https://www.govdata.de/dl-de/by-2-0',
        52.520008, 13.404954, 15, -62422, true);

-- Cluster all_parking_berlin_cluster
DROP VIEW IF EXISTS extern.help_all_parking_berlin_cluster CASCADE;
CREATE VIEW extern.help_all_parking_berlin_cluster AS
SELECT 
    *,
    ST_ClusterDBSCAN(geom, 10, 1) OVER () AS cluster_id
FROM extern.all_parking_berlin;

DROP MATERIALIZED VIEW IF EXISTS extern.all_parking_berlin_cluster CASCADE;
CREATE MATERIALIZED VIEW extern.all_parking_berlin_cluster AS
SELECT 
    cluster_id AS ogc_fid,
    string_agg(gml_id, '; ') AS gml_ids,
    string_agg(frs_anzahl, ' + ') AS frs_anzahl,
    ST_Union(geom) AS geom
FROM extern.help_all_parking_berlin_cluster
GROUP BY cluster_id;
