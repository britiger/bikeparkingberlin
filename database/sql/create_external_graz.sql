SET client_min_messages TO WARNING;

ALTER TABLE extern.all_parking_graz ALTER COLUMN bügelanz TYPE int;
ALTER TABLE extern.all_parking_graz ALTER COLUMN p_länge TYPE float;
ALTER TABLE extern.all_parking_graz ALTER COLUMN p_breite TYPE float;

DELETE FROM extern.external_data WHERE city='Graz';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Graz', 
        'graz', 
        'Stadt Graz OGD - Fahrradparkplätze ',
        'http://www.opendatagraz.at/2013/02/25/osm-mpg-import-fahrradstaender/',
        'Creative Commons Namensnennung',
        'https://creativecommons.org/licenses/by/2.0/',
         47.07, 15.43, 14, -34719);