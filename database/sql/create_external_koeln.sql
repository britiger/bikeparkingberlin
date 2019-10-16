SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='Köln';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id) 
    VALUES ('Köln',
        'koeln',
        'Fahrrad Förderung Köln',
        'https://open.nrw/dataset/fahrrad-foerderung-koeln-k',
        'Creative Commons Namensnennung (CC-BY)',
        'http://www.opendefinition.org/licenses/cc-by',
        50.93333, 6.95, 15, -62578);

DELETE FROM extern.all_parking_koeln WHERE art!=1; -- Delete all exept bike parking
DELETE FROM extern.all_parking_koeln WHERE massnahme ILIKE '%mobile%'; -- Delete all temporary installed
ALTER TABLE extern.all_parking_koeln ADD ogc_fid SERIAL;
