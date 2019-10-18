SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Wien';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Wien', 
        'wien', 
        'Stadt Wien - https://data.wien.gv.at - Fahrradabstellanlagen ',
        'https://www.data.gv.at/katalog/dataset/stadt-wien_fahrradabstellanlagenstandortewien',
        'Creative Commons Namensnennung 4.0 International',
        'https://creativecommons.org/licenses/by/4.0/deed.de',
         48.20849, 16.37208, 14, -109166);