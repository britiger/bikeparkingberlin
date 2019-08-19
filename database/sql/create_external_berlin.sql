SET client_min_messages TO WARNING;

CREATE OR REPLACE VIEW missing_parking_berlin AS
SELECT bln.*,  ST_AsGeoJSON(st_transform(bln.geom,4326)) as geojson
FROM public.s_fahrradstaender bln
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(bln.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Berlin';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Berlin', 's_fahrradstaender', 'missing_parking_berlin', 'Geoportal Berlin / Vermessungstechnische Straßenbefahrung 2014/2015 - Fahrradständer', 52.520008, 13.404954, 15);