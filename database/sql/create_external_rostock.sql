SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS extern.all_parking_rostock CASCADE;
CREATE TABLE extern.all_parking_rostock (
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

DELETE FROM extern.external_data WHERE city='Rostock';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Rostock', 
        'rostock', 
        'OpenData.HRO - Fahrradabstellanlagen',
        'https://www.opendata-hro.de/dataset/fahrradabstellanlagen',
        'Creative Commons Zero Universal 1.0 Public Domain Dedication',
        'https://creativecommons.org/publicdomain/zero/1.0/',
        54.0887, 12.14049, 13,-62405);