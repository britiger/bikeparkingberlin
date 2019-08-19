DROP TABLE IF EXISTS all_parking_jena CASCADE;
CREATE TABLE all_parking_jena (
    ogc_fid INT,
    id INT,
    org_lat FLOAT,
    org_lon FLOAT,
    name VARCHAR(255),
    geom geometry
);

CREATE OR REPLACE VIEW missing_parking_jena AS
SELECT jena.*,  ST_AsGeoJSON(st_transform(jena.geom,4326)) as geojson
FROM public.all_parking_jena jena
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(jena.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Jena';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Jena', 'all_parking_jena', 'missing_parking_jena', 'Open Data Jena - Fahrradabstellanlagen (Datenlizenz Deutschland - Namensnenung 2.0)', 50.92878, 11.5899, 13);