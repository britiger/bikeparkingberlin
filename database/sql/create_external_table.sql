SET client_min_messages TO WARNING;

CREATE TABLE IF NOT EXISTS external_data (
    id SERIAL,
    city VARCHAR(255) NOT NULL UNIQUE,
    table_all_parking VARCHAR(255),
    table_missing_parking VARCHAR(255),
    datasource TEXT,
    center_lat FLOAT,
    center_lon FLOAT,
    zoom_level INT
);
