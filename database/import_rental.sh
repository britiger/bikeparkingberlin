#!/bin/bash

# Nextbike:
# Use https://deezer.nextbike.net/maps/nextbike-live.json?list_cities=1 to find cities

# goto this path
cd `dirname $(readlink -f $0)`

source ../config
source ./tools/bash_functions.sh

#  activate Python from webapp
python3 -m venv ../webapp/venv
source ../webapp/venv/bin/activate
pip install --upgrade setuptools
pip install --upgrade pip
pip install -r ../webapp/requirements.txt

# Download data if not exists
function download_external {
    text="$1"
    url="$2"
    project="$3"
    filename="$4"

    mkdir -p external_data/$project

    if [ ! -f external_data/$project/$filename ]
    then
        echo "Download $text"
        wget -O external_data/$project/$filename "$url"
        if [[ $filename == *.zip ]]
        then
            # Extract Data if zip-file
            unzip -o -d external_data/$project/ external_data/$project/$filename
        fi
    fi
}

# Import data
psql -f sql/create_rental_table.sql
echo "Importing Rental Data ..."

download_external "Deezer Nextbike Berlin" "https://api.nextbike.net/maps/nextbike-live.json?city=362" nextbike deezer-362.json
download_external "Nextbike Potsdam" "https://api.nextbike.net/maps/nextbike-live.json?city=158" nextbike deezer-158.json
#download_external "ADFC fLotte Berlin" "https://flotte-berlin.de/wp-admin/admin-ajax.php" flotte flotte-berlin.json
mkdir -p external_data/flotte
if [ ! -f external_data/flotte/flotte-berlin.json ]
then
  curl 'https://flotte-berlin.de/wp-admin/admin-ajax.php' -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8' --data 'nonce=cb5852ab0b&action=cb_map_locations&cb_map_id=4160' -o external_data/flotte/flotte-berlin.json
fi

python3 python/import_nextbike.py 362 external_data/nextbike/deezer-362.json
python3 python/import_nextbike.py 158 external_data/nextbike/deezer-158.json
python3 python/import_flotte.py external_data/flotte/flotte-berlin.json
psql -c 'UPDATE extern.all_rental_nextbike SET geom=ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat),4326),3857)'
psql -c 'UPDATE extern.all_rental_flotte SET geom=ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat),4326),3857)'

psql -f sql/create_rental_berlin.sql
cat sql/create_rental_template.sql | \
    sed -e 's/#CITY#/Berlin/g' | \
    sed -e 's/#BRAND#/nextbike/g' | \
    sed -e 's/#SUFFIX#/nextbike_berlin/g' | \
    sed -e 's/#AREA#/berlin/g' | psql
cat sql/create_rental_template.sql | \
    sed -e 's/#CITY#/Berlin/g' | \
    sed -e 's/#BRAND#/fLotte/g' | \
    sed -e 's/#SUFFIX#/flotte/g' | \
    sed -e 's/#AREA#/berlin_flotte/g' | psql

psql -f sql/create_rental_potsdam.sql
cat sql/create_rental_template.sql | \
    sed -e 's/#CITY#/Potsdam/g' | \
    sed -e 's/#BRAND#/nextbike/g' | \
    sed -e 's/#SUFFIX#/nextbike_potsdam/g' | \
    sed -e 's/#AREA#/potsdam_nb/g' | psql

