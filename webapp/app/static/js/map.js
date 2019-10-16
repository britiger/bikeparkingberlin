var mymap = L.map('mapid', {
    fullscreenControl: {
        pseudoFullscreen: false
    }
})
.setView([51.505, 13.09], 7);

var mapNodes = [];

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
    maxZoom: 19,
    id: 'OrgMap'
}).addTo(mymap);

$('#mapid').css("position", "sticky");

var clusterGroup = L.markerClusterGroup({showCoverageOnHover: false, maxClusterRadius: 50, disableClusteringAtZoom: 16});
var nodes = new L.geoJson(null, {onEachFeature: onEachFeaturePopup,
    pointToLayer:
        function (feature, latlng) {
            var colorm = 'red';
            // for osm-point
            if ( feature.properties.requestedValue && feature.properties.requestedValue != '' ) {
                selectBox = document.getElementById("selectValue");
                if (selectBox.value == '-' || selectBox.value == feature.properties.requestedValue) {
                    colorm = 'green';
                    if (!document.getElementById("show_green").checked)
                        return null;
                } else {
                    colorm = 'yellow';
                    if (!document.getElementById("show_yellow").checked)
                        return null;
                }
            } else if( feature.properties.requestedValue ) {
                // feature.properties.requestedValue == '' if exists
                if (!document.getElementById("show_red").checked)
                    return null;
            }
            // for external data
            if ( feature.properties.missing && feature.properties.missing == 'no') {
                colorm = 'green';
            }
            var redMarker = L.ExtraMarkers.icon({
                icon: 'fa-number',
                markerColor: colorm,
                shape: 'circle'
            });
            return L.marker(latlng, {icon: redMarker }); 
        }
    });
// nodes.addTo(mymap);
clusterGroup.addTo(mymap);
clusterGroup.addLayer(nodes);
// geomlayer
var geomlayer = null;

function onEachFeaturePopup(feature, layer) {
    // does this feature have a property named popupContent?
    if (feature.properties) {
        if (feature.properties.popupContent) {
            layer.bindPopup(feature.properties.popupContent, {maxHeight: document.getElementById('mapid').clientHeight - 125});
        }
        if (feature.properties.osm_id) {
            layer.on('popupopen', function(e) { window.location.href = '#' + feature.properties.osm_id; });
            mapNodes[feature.properties.osm_id] = layer;
        }
        if (feature.properties.ogc_fid) {
            layer.on('popupopen', function(e) { window.location.href = '#' + feature.properties.ogc_fid; });
            layer.on('popupclose', function(e) { if(!stateMapMove) window.location.href = '#'; } );
            mapNodes[feature.properties.ogc_fid] = layer;
        }
        if (feature.properties.geojson) {
            layer.on('popupopen', function(e) { geomlayer = L.geoJson(JSON.parse(feature.properties.geojson)); if(feature.properties.geojson.indexOf("Point")==-1) geomlayer.addTo(mymap); console.log(feature.properties.geojson.indexOf("Point")); } );
            layer.on('popupclose', function(e) {mymap.removeLayer(geomlayer); } );
        }
    }
}

var stateMapMove = false;
var stateTimeout = null;
mymap.on('movestart', function(e) { if(stateTimeout) clearTimeout(stateTimeout); stateMapMove = true; });
mymap.on('moveend', function(e) { stateTimeout = setTimeout(function(){ stateMapMove = false;}, 300); });

function openNode(osm_id) {
    if (mapNodes[osm_id]) {
        mapNodes[osm_id].openPopup();
    }
}
if ("onhashchange" in window) {
    // move popup for node if anchor is changed
    window.onhashchange = function () {
        openNode(window.location.hash.substring(1));
    }
}