SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Hamburg';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Hamburg', 
        'hamburg', 
        'Transparenzportal Hamburg - Freie und Hansestadt Hamburg, Behörde für Wirtschaft, Verkehr und Innovation - Bike + Ride Anlagen Hamburg', 
        'http://suche.transparenz.hamburg.de/dataset/bike-ride-anlagen-hamburg12',
        'Datenlizenz Deutschland - Namensnennung - Version 2.0',
        'https://www.govdata.de/dl-de/by-2-0',
        53.551086, 9.993682, 15, -62782);