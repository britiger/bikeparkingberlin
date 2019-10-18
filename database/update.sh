#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`

source ../config
source ./tools/bash_functions.sh

export PATH=`pwd`/tools/:$PATH
oupdate=`which osmupdate 2> /dev/null`
oconvert=`which osmconvert 2> /dev/null` # needed by osmupdate

# Creating directories for updates
mkdir -p tmp

# if not find compile
if [ -z "$oupdate" ]
then
  echo_time "Try to complie osmupdate ..."
  wget -O - http://m.m.i24.cc/osmupdate.c | cc -x c - -o tools/osmupdate
  if [ ! -f tools/osmupdate ]
  then
    echo_time "Unable to compile osmupdate, please install osmupdate into \$PATH or in tools/ directory."
    exit 1
  fi
fi
if [ -z "$oconvert" ]
then
  echo_time "Try to complie osmconvert ..."
  wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o tools/osmconvert
  if [ ! -f tools/osmconvert ]
  then
    echo_time "Unable to compile osmconvert, please install osmconvert into \$PATH or tools/ directory."
    exit 1
  fi
fi

if [ -f tmp/old_update.osc.gz ]
then
  # 2nd Update
  osmupdate -v tmp/old_update.osc.gz tmp/update.osc.gz
else
  # 1st Update using dump
  osmupdate -v ${IMPORT_PBF} tmp/update.osc.gz
fi

imposm3 diff -config config.json -connection "postgis://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE}" -dbschema-production imposm3 tmp/update.osc.gz
RESULT=$?
if [ $RESULT -ne 0 ]
then
  echo_time "imposm3 exits with error code $RESULT."
  exit 1
fi

mv tmp/update.osc.gz tmp/old_update.osc.gz

psql -f sql/update_statistic.sql > /dev/null
