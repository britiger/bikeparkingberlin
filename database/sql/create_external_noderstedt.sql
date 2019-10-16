SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS extern.all_parking_nstedt CASCADE;
CREATE TABLE extern.all_parking_nstedt (
    ogc_fid INT,
    IDENT INT,
    BEZEICH VARCHAR(255),
    OEPNV VARCHAR(255),
    ART VARCHAR(255),
    ANZAHL INT,
    X INT,
    Y INT,
    geom geometry
);

DELETE FROM extern.external_data WHERE city='Norderstedt';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Norderstedt', 
        'nstedt', 
        'Open Data Schleswig-Holstein Fahhradabstellanlagen an ÖPNV-Haltestellen, Standort und Ausstattung Norderstedt',
        'https://opendata.schleswig-holstein.de/dataset/bike-and-ride',
        'Datenlizenz Deutschland – Zero – Version 2.0', 
        'https://www.govdata.de/dl-de/zero-2-0',
        53.692139, 9.995334, 13, -422634);