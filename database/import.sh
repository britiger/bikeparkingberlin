#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`

# TODO: Check availibility of imposm3, config.json, ${IMPORT_PBF}

source ../config
source ./tools/bash_functions.sh

export PATH=`pwd`/tools/:$PATH

imposm3 import -srid 3857 -overwritecache ${IMPOSM_PARAMETER}  -connection "postgis://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE}" -config config.json -read ${IMPORT_PBF} -write -dbschema-production imposm3 -deployproduction

# create views
psql -f sql/create_views.sql


# Delete all tmp files for update
rm -rf tmp/*
