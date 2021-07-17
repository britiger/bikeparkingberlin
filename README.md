# [bikeparking.lorenz.lu](https://bikeparking.lorenz.lu/)

[bikeparking.lorenz.lu](https://bikeparking.lorenz.lu/) is a project
of the [OSM Verkehrswende Berlin Usergroup](https://wiki.openstreetmap.org/wiki/Berlin/Verkehrswende).

Core features are:

* **Show** existing bicyle parking data from OSM in as statistics and on a map.
* **Compare** external OpenData of **bicycle parking** data and **bicycle rental** data with data from OSM.
  This allows to validate OpenData sets and manually add bicycle parking infrastructure to OSM ([ground truth](https://wiki.openstreetmap.org/wiki/Ground_truth)).


## Development

You can start it by your own using Docker.

The script links your local development directory as volume into the container.

1. Building a local image:
```
./build-docker.sh
```
2. Download and Link a pbf-File:
```
# Here as example of Brandenburg incl. Berlin
wget http://download.geofabrik.de/europe/germany/brandenburg-latest.osm.pbf
ln -s brandenburg-latest.osm.pbf import.osm.pbf
```
3. Start container and import data
```
./run-docker.sh 
```
4. Work with the container
```
# Start Webapp
./run-docker.sh webapp
# Need to Open the Browser http://127.0.0.1:5000/

# Update Database
./run-docker.sh update

# Import or update external data
./run-docker.sh external

# Import or update rental stations
./run-docker.sh rental
```

If you want to persit your data in the database you need to edit `run-docker.sh` by adding a database volume:
```bash
# create a Volume / otherwise you can use a local directory
docker volume create pgdata

# docker run -e POSTGRES_PASSWORD=bikeparking -p 127.0.0.1:5000:5000 -v `pwd`:/bikeparking --rm -d --name $CONTAINER_NAME bikeparking
docker run -e POSTGRES_PASSWORD=bikeparking -p 127.0.0.1:5000:5000 -v `pwd`:/bikeparking -v pgdata:/var/lib/postgresql/data --rm -d --name $CONTAINER_NAME bikeparking
```