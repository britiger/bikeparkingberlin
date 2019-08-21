SET client_min_messages TO WARNING;

ALTER TABLE public.radabstellanlagen_wuppertal ALTER COLUMN anzahl_abs TYPE int;
ALTER TABLE public.radabstellanlagen_wuppertal ALTER COLUMN "anzahl_bÜg" TYPE int;

CREATE OR REPLACE VIEW missing_parking_wuppertal AS
SELECT wup.*,  ST_AsGeoJSON(st_transform(wup.geom,4326)) as geojson
FROM public.radabstellanlagen_wuppertal wup
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(wup.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Wuppertal';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Wuppertal', 'radabstellanlagen_wuppertal', 'missing_parking_wuppertal', 'Stadt Wuppertal ‐ offenedaten‐wuppertal.de - Radabstellanlagen (CC-BY-4.0)', 51.27027, 7.16755, 15);