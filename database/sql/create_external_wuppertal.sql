SET client_min_messages TO WARNING;

ALTER TABLE extern.all_parking_wuppertal ALTER COLUMN anzahl_abs TYPE int;
ALTER TABLE extern.all_parking_wuppertal ALTER COLUMN "anzahl_bÜg" TYPE int;

DELETE FROM extern.external_data WHERE city='Wuppertal';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level)
    VALUES ('Wuppertal', 
        'wuppertal', 
        'offenedaten‐wuppertal.de - Radabstellanlagen ',
        'https://www.offenedaten-wuppertal.de/dataset/radabstellanlagen-wuppertal',
        'Creative Commons Namensnennung 4.0 International Lizenz',
        'https://creativecommons.org/licenses/by/4.0/',
         51.27027, 7.16755, 15);