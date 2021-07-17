#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`

docker build --pull -t bikeparking:latest .
