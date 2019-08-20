SET client_min_messages TO WARNING;

CREATE OR REPLACE VIEW missing_parking_bonn AS
SELECT bonn.*,  ST_AsGeoJSON(st_transform(bonn.geom,4326)) as geojson
FROM public.fahrradstaender_bonn bonn
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(bonn.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Bonn';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Bonn', 'fahrradstaender_bonn', 'missing_parking_bonn', 'Stadt Bonn - Standorte der Fahrradstellplätze (Creative Commons CC Zero License)', 50.73438, 7.09549, 15);