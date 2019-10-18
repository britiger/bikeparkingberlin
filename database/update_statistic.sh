#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`

source ../config
source ./tools/bash_functions.sh

# create views
psql -f sql/update_statistic.sql > /dev/null
