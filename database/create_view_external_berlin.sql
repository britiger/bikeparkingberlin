CREATE OR REPLACE VIEW missing_parking_berlin AS
SELECT bln.*,  ST_AsGeoJSON(st_transform(bln.geom,4326)) as geojson
FROM public.s_fahrradstaender bln
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(bln.geom,3857), 50)
WHERE osm.osm_id IS NULL;