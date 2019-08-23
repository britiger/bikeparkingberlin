SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Moers';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level)
    VALUES ('Moers',
        'moers',
        'open.nrw - Stadt Moers - Fahrradständer', 
        'https://open.nrw/dataset/fahrradstaender-odp',
        'Datenlizenz Deutschland – Zero – Version 2.0',
        'https://www.govdata.de/dl-de/zero-2-0',
        51.45342, 6.6326, 15);