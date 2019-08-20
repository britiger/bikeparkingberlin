SET client_min_messages TO WARNING;

CREATE OR REPLACE VIEW missing_parking_moers AS
SELECT moers.*,  ST_AsGeoJSON(st_transform(moers.geom,4326)) as geojson
FROM public.fahrradstaender moers
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(moers.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Moers';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Moers', 'fahrradstaender', 'missing_parking_moers', 'Stadt Moers - Fahrradständer', 51.45342, 6.6326, 15);