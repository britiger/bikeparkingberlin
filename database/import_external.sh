#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`

source ../config
source ./tools/bash_functions.sh

mkdir -p external_data

# Download data if not exists
if [ ! -f external_data/s_Fahrradstaender.gml ]
then
    echo "Download Berlin Fahrradständer Befahrung 2014"
    wget -O external_data/s_Fahrradstaender.gml https://fbinter.stadt-berlin.de/fb/wfs/data/senstadt/s_Fahrradstaender\?service\=WFS\&version\=1.1.0\&request\=GetFeature\&typeName\=fis:s_Fahrradstaender
fi

if [ -z `which ogr2ogr` ]
then
    echo "Please install ogr2ogr e.g. 'apt install gdal-bin'"
    exit 1
fi

# Import data
echo "Importing External Data ..."
# Berlin Fahrradständer
echo "Import Berlin Fahrradständer Befahrung 2014"
ogr2ogr -f "PostgreSQL" PG:"host=$PGHOST port=$PGPORT dbname=$PGDATABASE user=$PGUSER password=$PGPASSWORD" \
    -progress -overwrite -lco GEOMETRY_NAME=geom \
    -s_srs EPSG:25833 -t_srs EPSG:3857 \
    external_data/s_Fahrradstaender.gml

# create views
psql -f sql/create_view_external_berlin.sql
