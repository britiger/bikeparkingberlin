CREATE USER osm PASSWORD 'osm';
CREATE DATABASE osm_parking OWNER osm;
\c osm_parking
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;