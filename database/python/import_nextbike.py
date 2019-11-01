# Script for Import data into nextbike table
# 2 Parameter: <api_id> <filename>
import sys
import os
import json

from sqlalchemy import create_engine, text

# TODO: Check arguments
api_id = sys.argv[1]
filename = sys.argv[2]

# DB-Connection
SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
    'postgresql://' + os.environ.get('PGUSER') + ':' + os.environ.get('PGPASSWORD') + '@' + os.environ.get('PGHOST') + ':' + os.environ.get('PGPORT') + '/' + os.environ.get('PGDATABASE')
engine = create_engine(SQLALCHEMY_DATABASE_URI)


def parse_place(place):
    if place['bike']:
        # Skip bikes, only use stations
        return
    sql = text('INSERT INTO extern.all_rental_nextbike (api_id, uid, lat, lon, name, number) VALUES (:api_id, :uid, :lat, :lon, :name, :number)')
    engine.execute(sql, {'api_id': api_id, 'uid': place['uid'], 'lat': place['lat'], 'lon': place['lng'], 'name': place['name'], 'number': place['number']})


def parse_file():

    json_file = open(filename)
    data = json.load(json_file)

    for country in data['countries']:
        print('Import ' + country['country_name'] + ' - ' + country['name'] + ' ...')
        for city in country['cities']:
            print('Import ' + city['name'] + ' ...')
            for place in city['places']:
                parse_place(place)


parse_file()
