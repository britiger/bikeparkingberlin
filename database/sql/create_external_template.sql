SET client_min_messages TO WARNING;

CREATE OR REPLACE VIEW extern.missing_parking_#CITY# AS
SELECT #CITY#.*,  ST_AsGeoJSON(st_transform(#CITY#.geom,4326)) as geojson
FROM extern.all_parking_#CITY# #CITY#
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(#CITY#.geom,3857), 50)
WHERE osm.osm_id IS NULL;

CREATE OR REPLACE VIEW extern.existing_parking_#CITY# AS
SELECT *, ST_AsGeoJSON(st_transform(#CITY#.geom,4326)) as geojson
FROM extern.all_parking_#CITY# #CITY#
WHERE #CITY#.ogc_fid NOT IN (SELECT ogc_fid FROM extern.missing_parking_#CITY#);
