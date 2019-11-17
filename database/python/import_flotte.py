# Script for Import data into flotte table
# 1 Parameter: <filename>
import sys
import os
import json

from sqlalchemy import create_engine, text

# TODO: Check arguments
filename = sys.argv[1]

# DB-Connection
SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
    'postgresql://' + os.environ.get('PGUSER') + ':' + os.environ.get('PGPASSWORD') + '@' + os.environ.get('PGHOST') + ':' + os.environ.get('PGPORT') + '/' + os.environ.get('PGDATABASE')
engine = create_engine(SQLALCHEMY_DATABASE_URI)


def parse_place(place):
    items_cnt = len(place['items'])
    sql = text('INSERT INTO extern.all_rental_flotte (location_name, street, city, zip, lat, lon, capacity) VALUES (:location_name, :street, :city, :zip, :lat, :lon, :items_cnt)')
    engine.execute(sql, {'location_name': place['location_name'], 'street': place['address']['street'], 'city': place['address']['city'], 'zip': place['address']['zip'], 'lat': place['lat'], 'lon': place['lon'], 'items_cnt': items_cnt})


def parse_file():

    json_file = open(filename)
    data = json.load(json_file)

    for line in data:
        parse_place(line)


parse_file()
