SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS extern.all_parking_jena CASCADE;
CREATE TABLE extern.all_parking_jena (
    ogc_fid INT,
    id INT,
    org_lat FLOAT,
    org_lon FLOAT,
    name VARCHAR(255),
    geom geometry
);

DELETE FROM extern.external_data WHERE city='Jena';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level)
    VALUES ('Jena', 
        'jena', 
        'Open Data Jena - Fahrradabstellanlagen',
        'https://opendata.jena.de/dataset/fahrradabstellanlagen',
        'Datenlizenz Deutschland - Namensnenung 2.0',
        'https://www.govdata.de/dl-de/by-2-0',
        50.92878, 11.5899, 13);