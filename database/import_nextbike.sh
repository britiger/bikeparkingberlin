#!/bin/bash

# Use https://deezer.nextbike.net/maps/nextbike-live.json?list_cities=1 to find cities

# goto this path
cd `dirname $(readlink -f $0)`

source ../config
source ./tools/bash_functions.sh

mkdir -p external_data/nextbike

# Download data if not exists
function download_external {
    text="$1"
    url="$2"
    filename="$3"

    if [ ! -f external_data/nextbike/$filename ]
    then
        echo "Download $text"
        wget -O external_data/nextbike/$filename "$url"
        if [[ $filename == *.zip ]]
        then
            # Extract Data if zip-file
            unzip -o -d external_data/nextbike/ external_data/nextbike/$filename
        fi
    fi
}

# Import data
psql -f sql/create_rental_table.sql
echo "Importing Nextbike Data ..."

download_external "Deezer Nextbike Berlin" "https://api.nextbike.net/maps/nextbike-live.json?city=362" deezer-362.json
download_external "Nextbike Potsdam" "https://api.nextbike.net/maps/nextbike-live.json?city=158" deezer-158.json

python3 python/import_nextbike.py 362 external_data/nextbike/deezer-362.json
python3 python/import_nextbike.py 158 external_data/nextbike/deezer-158.json
psql -c 'UPDATE extern.all_rental_nextbike SET geom=ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat),4326),3857)'
psql -f sql/create_rental_berlin.sql
psql -f sql/create_rental_potsdam.sql
