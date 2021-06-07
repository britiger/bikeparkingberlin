FROM postgres:13

RUN apt-get update; \
    apt install -y --no-install-recommends \
        postgis \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        osm2pgsql \
        postgresql-13-postgis-3 \
        unzip \
        wget \
        gcc \
        libz-dev

# install/build current ogr2ogr into /usr/local
RUN cd / ; \
    apt install -y --no-install-recommends g++ libsqlite3-dev sqlite3 pkg-config libtiff-dev libcurl4-openssl-dev make libpq-dev; \
    wget https://github.com/OSGeo/gdal/releases/download/v3.2.3/gdal-3.2.3.tar.gz; \
    wget https://download.osgeo.org/proj/proj-8.0.1.tar.gz; \
    tar xzf gdal-3.2.3.tar.gz; \
    tar xzf proj-8.0.1.tar.gz; \
    cd /proj-8.0.1; \
    ./configure; \
    make -j8 ; \
    make install ; \
    ldconfig ; \
    cd /gdal-3.2.3 ; \
    ./configure ; \
    make -j8 ; \
    make install ; \
    ldconfig ; \
    rm -f gdal-3.2.3 proj-8.0.1 gdal-3.2.3.tar.gz proj-8.0.1.tar.gz

ADD docker/create_db.sql /docker-entrypoint-initdb.d/create_db.sql

EXPOSE 5432 5000
