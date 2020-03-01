#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`

source ../config
source ./tools/bash_functions.sh

mkdir -p external_data

# Check unzip
if [ -z `which unzip` ]
then
    echo "Please install unzip e.g. 'apt install unzip'"
    exit 1
fi
# Check ogr2ogr
if [ -z `which ogr2ogr` ]
then
    echo "Please install ogr2ogr e.g. 'apt install gdal-bin'"
    exit 1
fi

# Download data if not exists
function download_external {
    text="$1"
    url="$2"
    filename="$3"

    if [ ! -f external_data/$filename ]
    then
        echo "Download $text"
        wget -O external_data/$filename "$url"
        if [[ $filename == *.zip ]]
        then
            # Extract Data if zip-file
            unzip -o -d external_data/ external_data/$filename
        fi
    fi
}

download_external "Berlin Fahrradständer Befahrung 2014" "https://fbinter.stadt-berlin.de/fb/wfs/data/senstadt/s_Fahrradstaender?service=WFS&version=1.1.0&request=GetFeature&typeName=fis:s_Fahrradstaender" s_Fahrradstaender.gml
download_external "Norderstedt Fahhradabstellanlagen an ÖPNV-Haltestellen" http://185.223.104.6/data/norderstedt/13_Bike_und_ride.csv 13_Bike_und_ride.csv
download_external "Jena Fahrradabstellanlagen" https://opendata.jena.de/data/fahrradabstellanlagen.csv fahrradabstellanlagen_jena.csv
download_external "Rostock Fahrradabstellanlagen" https://geo.sv.rostock.de/download/opendata/fahrradabstellanlagen/fahrradabstellanlagen.csv fahrradabstellanlagen_rostock.csv
download_external "Hamburg Bike + Ride Anlagen" http://archiv.transparenz.hamburg.de/hmbtgarchive/HMDK/hh_wfs_verkehr_opendata_26217_snap_7.XML hh_wfs_verkehr_opendata_26217_snap_7.XML
download_external "Moers Fahrradständer" http://geoportal-niederrhein.de/files/opendatagis/Moers/fahrradstaender.geojson fahrradstaender_moers.geojson
download_external "Bonn Fahrradstellplätze" https://stadtplan.bonn.de/geojson?Thema=24840 fahrradstellplaetze_bonn.geojson
download_external "Wuppertal Fahrradstellplätze" https://www.offenedaten-wuppertal.de/node/1257/download Radabstellanlagen_wuppertal.zip
download_external "Köln Fahrrad Förderung" "https://geoportal.stadt-koeln.de/arcgis/rest/services/Fahrradverkehr_Ma%C3%9Fnahmen/MapServer/0/query?where=objectid+is+not+null&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=4326&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&resultOffset=&resultRecordCount=&f=pjson" fahrrad_massnahme_koeln.geojson
download_external "London Cycling Infrastructure" https://cycling.data.tfl.gov.uk/CyclingInfrastructure/data/points/cycle_parking.json london_parking.geojson
download_external "London Cycling Infrastructure MapInfo" https://cycling.data.tfl.gov.uk/CycleParking/cycle-parking-map-info.zip london_mapinfo.zip
download_external "Düsseldorf Bike + Ride" "https://opendata.duesseldorf.de/sites/default/files/Bike%20%2B%20Ride-Stationen.geojson" BikeRideDuesseldorf.geojson 
download_external "Wien Fahrradabstellanlagen" "https://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:FAHRRADABSTELLANLAGEOGD&srsName=EPSG:4326&outputFormat=json" WienWFSFahrradabstellanlagen.geojson
download_external "Graz Fahrradständer" http://www.opendatagraz.at/wp-content/uploads/2013/03/Fahrradabstellpl%C3%A4tze.zip Fahrradstellplaetze.zip
download_external "Zürich Zweiradabstellplatz" https://data.stadt-zuerich.ch/dataset/11b61777-800c-4ebe-a340-bbe4affaedfd/resource/2eaa9ce6-7a21-429e-b1a0-54b1826a817d/download/zweiradabstellplatz.json zweiradabstellplatz.geojson

# Import data
psql -f sql/create_external_table.sql
echo "Importing External Data ..."

OGR2OGR_PGSQL="host=$PGHOST port=$PGPORT dbname=$PGDATABASE user=$PGUSER password=$PGPASSWORD SCHEMAS=extern"

# Berlin Fahrradständer
echo "Import Berlin Fahrradständer Befahrung 2014"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -progress -overwrite -lco GEOMETRY_NAME=geom \
    -s_srs EPSG:25833 -t_srs EPSG:3857 \
    -nln all_parking_berlin \
    external_data/s_Fahrradstaender.gml
psql -f sql/create_external_berlin.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/berlin/g' | psql
cat sql/create_external_template.sql | sed -e 's/#CITY#/berlin_cluster/g' | psql

# Norderstedt Fahrrad ÖPNV
echo "Import Norderstedt Fahhradabstellanlagen an ÖPNV-Haltestellen"
psql -f sql/create_external_noderstedt.sql
cat external_data/13_Bike_und_ride.csv | psql -c "COPY extern.all_parking_nstedt(IDENT,BEZEICH,OEPNV,ART,ANZAHL,X,Y) FROM STDIN DELIMITER ';' CSV HEADER;"
psql -c "UPDATE extern.all_parking_nstedt SET ogc_fid=IDENT, geom=ST_TRANSFORM(ST_SetSRID(ST_MakePoint(X, Y),32632),3857)"
cat sql/create_external_template.sql | sed -e 's/#CITY#/nstedt/g' | psql

# Jena Fahrradabstellanlagen
echo "Import Jena Fahrradabstellanlagen"
psql -f sql/create_external_jena.sql
cat external_data/fahrradabstellanlagen_jena.csv | psql -c "COPY extern.all_parking_jena(id,org_lat,org_lon,name) FROM STDIN DELIMITER ',' CSV HEADER;"
psql -c "UPDATE extern.all_parking_jena SET ogc_fid=id, geom=ST_TRANSFORM(ST_SetSRID(ST_MakePoint(org_lon, org_lat),4326),3857)"
cat sql/create_external_template.sql | sed -e 's/#CITY#/jena/g' | psql

# Rostock Fahrradabstellanlagen
echo "Import Rostock Fahrradabstellanlagen"
psql -f sql/create_external_rostock.sql
cat external_data/fahrradabstellanlagen_rostock.csv | psql -c "COPY extern.all_parking_rostock(org_lat,org_lon,uuid,kreis_name,kreis_schluessel,gemeindeverband_name,gemeindeverband_schluessel,gemeinde_name,gemeinde_schluessel,gemeindeteil_name,gemeindeteil_schluessel,strasse_name,strasse_schluessel,hausnummer,hausnummer_zusatz,postleitzahl,art,stellplaetze,gebuehren,ueberdacht) FROM STDIN DELIMITER ',' CSV HEADER;"
psql -c "UPDATE extern.all_parking_rostock SET ogc_fid=id, geom=ST_TRANSFORM(ST_SetSRID(ST_MakePoint(org_lon, org_lat),4326),3857)"
cat sql/create_external_template.sql | sed -e 's/#CITY#/rostock/g' | psql

# Hamburg Bike + Rode
echo "Import Hamburg Bike + Ride"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_hamburg \
    external_data/hh_wfs_verkehr_opendata_26217_snap_7.XML
psql -f sql/create_external_hamburg.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/hamburg/g' | psql

# Moers Fahrradständer
echo "Import Moers Fahrradständer"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_moers \
    external_data/fahrradstaender_moers.geojson
psql -f sql/create_external_moers.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/moers/g' | psql

# Bonn Fahrradständer
echo "Import Bonn Fahrradstellplätze"
PGCLIENTENCODING=LATIN1 ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_bonn \
    external_data/fahrradstellplaetze_bonn.geojson
psql -f sql/create_external_bonn.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/bonn/g' | psql

# Wuppertal Radabstellanlagen
echo "Import Wuppertal Radabstellanlagen"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_wuppertal \
    external_data/Radabstellanlagen_EPSG3857_SHAPE.shp
psql -f sql/create_external_wuppertal.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/wuppertal/g' | psql

# Köln Fahrrad Förderung
echo "Import Köln Fahrrad Förderung"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_koeln \
    external_data/fahrrad_massnahme_koeln.geojson
psql -f sql/create_external_koeln.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/koeln/g' | psql

# London TFL Cycling Infrastructure
echo "Import London TFL Cycling Infrastructure"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_london_map \
    external_data/CycleParking\ 2015.TAB
cat sql/create_external_template.sql | sed -e 's/#CITY#/london_map/g' | psql
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_london \
    external_data/london_parking.geojson
cat sql/create_external_template.sql | sed -e 's/#CITY#/london/g' | psql
psql -f sql/create_external_london.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/london_mix/g' | psql
cat sql/create_external_template.sql | sed -e 's/#CITY#/london_mix_cluster/g' | psql

# Bike + Ride Stationen in Düsseldorf
echo "Import Düsseldorf Bike + Ride"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    -nln all_parking_duesseldorf \
    external_data/BikeRideDuesseldorf.geojson
psql -f sql/create_external_duesseldorf.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/duesseldorf/g' | psql

# Fahrradabstellanlagen in Wien
echo "Import Wien Fahrradabstellanlagen"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -t_srs EPSG:3857 \
    -nln all_parking_wien \
    external_data/WienWFSFahrradabstellanlagen.geojson
psql -f sql/create_external_wien.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/wien/g' | psql

echo "Import Graz Fahrradständer"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -s_srs EPSG:31256 \
    -t_srs EPSG:3857 \
    -nln all_parking_graz \
    external_data/Fahrradabstellpl?tze.shp
psql -f sql/create_external_graz.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/graz/g' | psql

echo "Import Zürich Zweiradabstellplätze"
ogr2ogr -f "PostgreSQL" PG:"$OGR2OGR_PGSQL" \
    -overwrite -lco GEOMETRY_NAME=geom \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    -nln all_parking_zuerich \
    external_data/zweiradabstellplatz.geojson
psql -f sql/create_external_zuerich.sql
cat sql/create_external_template.sql | sed -e 's/#CITY#/zuerich/g' | psql

# Berlin Neukölln Fahrradabstellanlagen
# Quelle: https://www.berlin.de/ba-neukoelln/aktuelles/bezirksticker/radverkehrsprojekte-in-neukoelln-886182.php
# Nachträglich geokodiert, sofern möglich
echo "Import Berlin Neukölln Fahrradabstellanlagen"
psql -f sql/create_external_berlin_neukoelln.sql
cat external_data/neukoelln_fahrrad.csv | psql -c "COPY extern.all_parking_berlin_neukoelln(id,anzahl,art,ueberdacht,oepnv,ort,jahr,adresse,projekt,lat,lon) FROM STDIN DELIMITER ';' CSV HEADER;"
psql -c "UPDATE extern.all_parking_berlin_neukoelln SET ogc_fid=id, geom=ST_TRANSFORM(ST_SetSRID(ST_MakePoint(lon, lat),4326),3857)"
cat sql/create_external_template.sql | sed -e 's/#CITY#/berlin_neukoelln/g' | psql


## Manuell feedback => until finish https://github.com/britiger/bikeparkingberlin/issues/45
echo "Import Feedback"
psql -c "TRUNCATE TABLE extern.file_feedback"
cat external_data/parking_non_existing.csv | psql -c "COPY extern.file_feedback(suffix,obj_id,osm_user,feedback) FROM STDIN DELIMITER ';' CSV HEADER;"
# Import for Berlin
psql -c "DELETE FROM extern.external_feedback WHERE suffix='berlin'"
psql -c "INSERT INTO extern.external_feedback (suffix, do_not_exists, osm_user, feedback, geom) (SELECT suffix, true, osm_user, feedback, (SELECT geom from extern.all_parking_berlin WHERE gml_id=obj_id) FROM extern.file_feedback WHERE suffix='berlin');"
# Import for Berlin Neukölln
psql -c "DELETE FROM extern.external_feedback WHERE suffix='berlin_neukoelln'"
psql -c "INSERT INTO extern.external_feedback (suffix, do_not_exists, osm_user, feedback, geom) (SELECT suffix, true, osm_user, feedback, (SELECT geom from extern.all_parking_berlin_neukoelln WHERE id::text=obj_id) FROM extern.file_feedback WHERE suffix='berlin_neukoelln');"
