SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Düsseldorf';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Düsseldorf',
        'duesseldorf',
        'open.nrw - Landeshauptstadt Düsseldorf - Standorte der Bike- und Ride-Stationen sowie Radstationen', 
        'https://open.nrw/dataset/standorte-der-bike-und-ride-stationen-sowie-radstationen-duesseldorf-d',
        'Datenlizenz Deutschland – Zero – Version 2.0',
        'https://www.govdata.de/dl-de/zero-2-0',
        51.22172, 6.77616, 14, -62539);