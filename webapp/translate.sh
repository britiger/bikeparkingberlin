#!/bin/bash

source ../config

python3 -m venv venv
source venv/bin/activate
pip install --upgrade setuptools
pip install --upgrade pip
pip install -r requirements.txt

# Searxh all Texts
pybabel extract -F babel.cfg -k _l -o messages.pot .
# Update tanslation files
pybabel update -i messages.pot -d app/translations
# compile po files
pybabel compile -d app/translations

# Only for New Languages:
#pybabel init -i messages.pot -d app/translations -l nl
