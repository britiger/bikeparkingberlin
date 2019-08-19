SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS all_parking_rostock CASCADE;
CREATE TABLE all_parking_rostock (
    ogc_fid INT,
    id SERIAL,
    org_lon FLOAT,
    org_lat FLOAT,
    uuid VARCHAR(255),
    kreis_name VARCHAR(255),
    kreis_schluessel VARCHAR(255),
    gemeindeverband_name VARCHAR(255),
    gemeindeverband_schluessel VARCHAR(255),
    gemeinde_name VARCHAR(255),
    gemeinde_schluessel VARCHAR(255),
    gemeindeteil_name VARCHAR(255),
    gemeindeteil_schluessel VARCHAR(255),
    strasse_name VARCHAR(255),
    strasse_schluessel  VARCHAR(255),
    hausnummer  VARCHAR(255),
    hausnummer_zusatz VARCHAR(255),
    postleitzahl VARCHAR(255),
    art VARCHAR(255),
    stellplaetze VARCHAR(255),
    gebuehren VARCHAR(255),
    ueberdacht VARCHAR(255),
    geom geometry
);

CREATE OR REPLACE VIEW missing_parking_rostock AS
SELECT rostock.*,  ST_AsGeoJSON(st_transform(rostock.geom,4326)) as geojson
FROM public.all_parking_rostock rostock
LEFT JOIN imposm3.view_parking osm
ON osm.geom && ST_Expand(st_transform(rostock.geom,3857), 50)
WHERE osm.osm_id IS NULL;

DELETE FROM external_data WHERE city='Rostock';
INSERT INTO external_data (city, table_all_parking, table_missing_parking, datasource, center_lat, center_lon, zoom_level) 
    VALUES ('Rostock', 'all_parking_rostock', 'missing_parking_rostock', 'Open Data Rostock Fahhradabstellanlagen (CC0)', 54.0887, 12.14049, 13);