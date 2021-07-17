#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`
CMD=$1

CONTAINER_NAME=bikeparkingcontainer

# Check Installed imposm
if ! [ -f "database/tools/imposm-0.11.1-linux-x86-64.tar.gz" ]
then
  wget -P database/tools/ https://github.com/omniscale/imposm3/releases/download/v0.11.1/imposm-0.11.1-linux-x86-64.tar.gz
  tar -xzf database/tools/imposm-0.11.1-linux-x86-64.tar.gz -C database/tools/
  mv -f database/tools/imposm-0.11.1-linux-x86-64/* database/tools/
  rm -rf database/tools/imposm-0.11.1-linux-x86-64
fi

if ! [ -f config ]
then
  cp config.sample config
fi

source ./config

if ! [ "$( docker container inspect -f '{{.State.Status}}' $CONTAINER_NAME )" == "running" ]
then
  echo "Container not running ..."
  # Start container
  docker run -e POSTGRES_PASSWORD=bikeparking -p 127.0.0.1:5000:5000 -v `pwd`:/bikeparking --rm -d --name $CONTAINER_NAME bikeparking
  echo "Waiting for statup ..."
  sleep 10
  DO_IMPORT=1
else
  echo "Container is running."
  if [ -z "${CMD}" ]
  then
    echo "Use Parameter: "
    echo "  external - Import/Update data of external sources"
    echo "  reimport - Reimport Database from PBF-File"
    echo "  rental   - Import/Update data of rental sources"
    echo "  update   - Update Database from osm"
    echo "  webapp   - Start Webapp"
  fi
fi

if [ "${CMD}" == "reimport" ] || [ -n "${DO_IMPORT}" ]
then
  # Import
  if [ -f "${IMPORT_PBF}" ]
    then
      docker exec -it $CONTAINER_NAME /bikeparking/database/import.sh
    else
      echo "Please Download a PBF-File (${IMPORT_PBF}) for import!"
      echo "After this you should run '$0 reimport' for import."
    fi
elif [ "${CMD}" == "webapp" ]
then
  # run webapp in container
  docker exec -it $CONTAINER_NAME /bikeparking/webapp/start.sh
elif [ "${CMD}" == "update" ]
then
  docker exec -it $CONTAINER_NAME /bikeparking/database/update.sh
elif [ "${CMD}" == "external" ]
then
  docker exec -it $CONTAINER_NAME /bikeparking/database/import_external.sh
elif [ "${CMD}" == "rental" ]
then
  docker exec -it $CONTAINER_NAME /bikeparking/database/import_rental.sh
elif [ "${CMD}" == "download_js" ]
then
  docker exec -it $CONTAINER_NAME /bikeparking/webapp/download_js.sh
fi
