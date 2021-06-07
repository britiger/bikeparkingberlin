#!/bin/bash

# goto this path
cd `dirname $(readlink -f $0)`

docker pull postgres:13
docker build -t bikeparking:latest .
