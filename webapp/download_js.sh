#!/bin/bash

# Download-Script for depending js libraries

webapp_dir=`dirname $(readlink -f $0)`

js_dir=${webapp_dir}/app/static/js
css_dir=${webapp_dir}/app/static/css
img_dir=${webapp_dir}/app/static/img

function download_file()
{
    file_name=$1
    url=$2
    if ! [ -f $file_name ]
    then
        wget -O $file_name $url
    fi
}

# Popper
download_file ${js_dir}/popper.min.js https://unpkg.com/popper.js@1.14.4/dist/umd/popper.min.js

# bootstrap4
download_file ${css_dir}/bootstrap.min.css https://unpkg.com/bootstrap@4.1.3/dist/css/bootstrap.min.css
download_file ${js_dir}/bootstrap.min.js https://unpkg.com/bootstrap@4.1.3/dist/js/bootstrap.min.js

# jquery
download_file ${js_dir}/jquery.min.js https://unpkg.com/jquery@3.3.1/dist/jquery.min.js

# leaflet
download_file ${js_dir}/leaflet.js https://unpkg.com/leaflet@1.3.4/dist/leaflet.js
download_file ${css_dir}/leaflet.css https://unpkg.com/leaflet@1.3.4/dist/leaflet.css
mkdir -p ${css_dir}/images 
download_file ${css_dir}/images/layers-2x.png https://unpkg.com/leaflet@1.3.4/dist/images/layers-2x.png
download_file ${css_dir}/images/layers.png https://unpkg.com/leaflet@1.3.4/dist/images/layers.png
download_file ${css_dir}/images/marker-icon.png https://unpkg.com/leaflet@1.3.4/dist/images/marker-icon.png
download_file ${css_dir}/images/marker-icon-2x.png https://unpkg.com/leaflet@1.3.4/dist/images/marker-icon-2x.png
download_file ${css_dir}/images/marker-shadow.png https://unpkg.com/leaflet@1.3.4/dist/images/marker-shadow.png
# leaflet-fullscreen (by mapbox)
download_file ${js_dir}/leaflet.fullscreen.min.js https://github.com/Leaflet/Leaflet.fullscreen/raw/v1.0.2/dist/Leaflet.fullscreen.min.js
download_file ${css_dir}/leaflet.fullscreen.css https://github.com/Leaflet/Leaflet.fullscreen/raw/v1.0.2/dist/leaflet.fullscreen.css
download_file ${css_dir}/fullscreen.png https://github.com/Leaflet/Leaflet.fullscreen/raw/v1.0.2/dist/fullscreen.png
download_file ${css_dir}/fullscreen@2x.png https://github.com/Leaflet/Leaflet.fullscreen/raw/v1.0.2/dist/fullscreen@2x.png
# leaflet-markercluster
download_file ${js_dir}/leaflet.markercluster.js https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js
download_file ${css_dir}/MarkerCluster.css https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css
download_file ${css_dir}/MarkerCluster.Default.css https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css
# leaflet-extramarkers
download_file ${js_dir}/leaflet.extra-markers.min.js https://raw.githubusercontent.com/coryasilva/Leaflet.ExtraMarkers/master/dist/js/leaflet.extra-markers.min.js
download_file ${css_dir}/leaflet.extra-markers.min.css https://raw.githubusercontent.com/coryasilva/Leaflet.ExtraMarkers/master/dist/css/leaflet.extra-markers.min.css
# Images
download_file ${img_dir}/markers_default.png https://github.com/coryasilva/Leaflet.ExtraMarkers/raw/master/dist/img/markers_default.png
download_file ${img_dir}/markers_default@2x.png https://github.com/coryasilva/Leaflet.ExtraMarkers/raw/master/dist/img/markers_default@2x.png
download_file ${img_dir}/markers_shadow.png https://github.com/coryasilva/Leaflet.ExtraMarkers/raw/master/dist/img/markers_shadow.png
download_file ${img_dir}/markers_shadow@2x.png https://github.com/coryasilva/Leaflet.ExtraMarkers/raw/master/dist/img/markers_shadow@2x.png