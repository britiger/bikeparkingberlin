SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS extern.all_parking_berlin_neukoelln CASCADE;
CREATE TABLE extern.all_parking_berlin_neukoelln (
    ogc_fid INT,
    id SERIAL,
    lon FLOAT,
    lat FLOAT,
    anzahl INT,
    art VARCHAR(255),
    ueberdacht VARCHAR(255),
    oepnv VARCHAR(255),
    ort VARCHAR(255),
    jahr VARCHAR(255),
    adresse VARCHAR(255),
    projekt VARCHAR(255),
    geom geometry
);

DELETE FROM extern.external_data WHERE city='Berlin Neukölln';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level, admin_osm_id)
    VALUES ('Berlin Neukölln', 
        'berlin_neukoelln', 
        'Radverkehrsprojekte in Neukölln - Nachtäglich Geokodiert',
        'https://www.berlin.de/ba-neukoelln/aktuelles/bezirksticker/radverkehrsprojekte-in-neukoelln-886182.php',
        'Unknown',
        'https://www.berlin.de/ba-neukoelln/aktuelles/bezirksticker/radverkehrsprojekte-in-neukoelln-886182.php',
        52.483333, 13.45, 13, -162902);