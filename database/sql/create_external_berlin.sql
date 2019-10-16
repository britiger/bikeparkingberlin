SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Berlin';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id) 
    VALUES ('Berlin',
        'berlin',
        'FIS-Brocker - Geoportal Berlin / Straßenbefahrung 2014 - Fahrradständer (WFS)',
        'https://fbinter.stadt-berlin.de/fb/index.jsp',
        'Datenlizenz Deutschland - Namensnennung - Version 2.0',
        'https://www.govdata.de/dl-de/by-2-0',
        52.520008, 13.404954, 15, -62422);