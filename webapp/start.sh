#!/bin/bash

cd  `dirname $0`

source ../config

export PGHOST
export PGPORT
export PGUSER
export PGPASSWORD
export PGDATABASE

export FLASK_APP=webapp.py
export FLASK_DEBUG=1

python3 -m venv venv
source venv/bin/activate
pip install --upgrade setuptools
pip install --upgrade pip
pip install -r requirements.txt

flask run --host=0.0.0.0
