SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Bonn';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Bonn', 
        'bonn', 
        'open.nrw - Stadt Bonn - Standorte der Fahrradstellplätze',
        'https://open.nrw/dataset/standorte-der-fahrradstellplaetze-bn',
        'Creative Commons CC Zero License (cc-zero)',
        'http://www.opendefinition.org/licenses/cc-zero',
        50.73438, 7.09549, 15, -62508);