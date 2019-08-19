SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS all_parking_nstedt CASCADE;
CREATE TABLE all_parking_nstedt (
    ogc_fid INT,
    IDENT INT,
    BEZEICH VARCHAR(255),
    OEPNV VARCHAR(255),
    ART VARCHAR(255),
    ANZAHL INT,
    X INT,
    Y INT,
    geom geometry
);

CREATE OR REPLACE VIEW missing_parking_nstedt AS
SELECT nstedt.*,  ST_AsGeoJSON(st_transform(nstedt.geom,4326)) as geojson
FROM public.all_parking_nstedt nstedt
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(nstedt.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Norderstedt';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Norderstedt', 'all_parking_nstedt', 'missing_parking_nstedt', 'Open Data Schleswig-Holstein Fahhradabstellanlagen an ÖPNV-Haltestellen, Standort und Ausstattung Norderstedt', 53.692139, 9.995334, 13);