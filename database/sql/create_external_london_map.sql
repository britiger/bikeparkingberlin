SET client_min_messages TO WARNING;

DELETE FROM extern.external_data WHERE city='London-MapInfo';
INSERT INTO extern.external_data (city, suffix, datasource, datasource_link, license, license_link, center_lat, center_lon, zoom_level) 
    VALUES ('London-MapInfo',
        'london_map',
        'Transport for London - Transport Data Service -  CycleParking (MapInfo)',
        'https://cycling.data.tfl.gov.uk/',
        'Open Government License Version 2.0 - Powered by TfL Open Data',
        'https://tfl.gov.uk/corporate/terms-and-conditions/transport-data-service',
        51.509865, -0.1180, 15);