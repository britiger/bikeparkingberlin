SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Zürich';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Zürich', 
        'zuerich', 
        'Stadt Zürich - Zweiradabstellplätze in der Stadt Zürich',
        'https://data.stadt-zuerich.ch/dataset/zweiradabstellplatz',
        'Creative Commons CCZero',
        'http://www.opendefinition.org/licenses/cc-zero',
         47.37, 8.55, 14, -1690227);