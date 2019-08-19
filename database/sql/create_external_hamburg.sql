CREATE OR REPLACE VIEW missing_parking_hamburg AS
SELECT hh.*,  ST_AsGeoJSON(st_transform(hh.geom,4326)) as geojson
FROM public.bikeandride hh
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(hh.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Hamburg';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Hamburg', 'bikeandride', 'missing_parking_hamburg', 'Freie und Hansestadt Hamburg, Behörde für Wirtschaft, Verkehr und Innovation - Bike + Ride Anlagen', 53.551086, 9.993682, 15);