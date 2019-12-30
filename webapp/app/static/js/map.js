var mymap = L.map('mapid', {
    fullscreenControl: {
        pseudoFullscreen: false
    }
});

var mapNodes = [];

var areaStyle = {
    "color": "#888",
    "weight": 2,
    "opacity": 0.9
};

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
            if ( typeof feature.properties.requestedValue !== 'undefined' && feature.properties.requestedValue != '' ) {
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
            } else if( typeof feature.properties.requestedValue !== 'undefined' ) {
                // feature.properties.requestedValue == '' if exists
                if (!document.getElementById("show_red").checked)
                    return null;
            }
            // for external data
            if ( feature.properties.missing && feature.properties.missing == 'no') {
                colorm = 'green';
            }
            if ( feature.properties.do_not_exists ) {
                colorm = 'blue';
                if (!document.getElementById("show_"+colorm).checked) {
                    return null;
                }
            }
            // for rental data
            if ( feature.properties._color ) {
                colorm = feature.properties._color;
                if (!document.getElementById("show_"+colorm).checked)
                    return null;
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
loadHash(51.505, 13.09, 7);
// geomlayer
var geomlayer = null;

function onEachFeaturePopup(feature, layer) {
    stateTimeout = setTimeout(function(){ stateMapMove = false;}, 300);

    // does this feature have a property named popupContent?
    if (feature.properties) {
        if (feature.properties.popupContent) {
            layer.bindPopup(feature.properties.popupContent, {maxHeight: document.getElementById('mapid').clientHeight - 125, autoPan: false});
        }

        if (feature.properties.osm_id) {
            layer.on('popupopen', function(e) { setHashID(feature.properties.osm_id); });
            layer.on('popupclose', function(e) { if(!stateMapMove) setHashID(null); } );
            mapNodes[feature.properties.osm_id] = layer;
        } else if (feature.properties.ogc_fid) {
            layer.on('popupopen', function(e) { setHashID(feature.properties.ogc_fid); });
            layer.on('popupclose', function(e) { if(!stateMapMove) setHashID(null); } );
            mapNodes[feature.properties.ogc_fid] = layer;
        } else if (feature.properties.int_osm_id) {
            layer.on('popupopen', function(e) { setHashID(feature.properties.int_osm_id); });
            layer.on('popupclose', function(e) { if(!stateMapMove) setHashID(null); } );
            mapNodes[feature.properties.int_osm_id] = layer;
        } else if (feature.properties.uid) {
            layer.on('popupopen', function(e) { setHashID(feature.properties.uid) });
            layer.on('popupclose', function(e) { if(!stateMapMove) setHashID(null); } );
            mapNodes[feature.properties.uid] = layer;
        }
        if (feature.properties.geojson) {
            layer.on('popupopen', function(e) { geomlayer = L.geoJson(JSON.parse(feature.properties.geojson)); if(feature.properties.geojson.indexOf("Point")==-1) geomlayer.addTo(mymap); } );
            layer.on('popupclose', function(e) {mymap.removeLayer(geomlayer); } );
        }
    }
}

var stateMapMove = false;
var stateTimeout = null;
var hashID = null;
var hashLoaded = false;
mymap.on('movestart', function(e) { if(stateTimeout) clearTimeout(stateTimeout); stateMapMove = true; });
mymap.on('moveend', createHash );

function openNode(osm_id) {
    if (mapNodes[osm_id]) {
        mapNodes[osm_id].openPopup();
    }
}
function setHashID(id) {
    hashID = id;
    createHash();
}
function createHash() {
    if(!hashLoaded)
        loadHashId();
    if (hashID) {
        hash = [mymap.getCenter().lat, mymap.getCenter().lng, mymap.getZoom(), hashID].join('/');
    } else {
        hash = [mymap.getCenter().lat, mymap.getCenter().lng, mymap.getZoom()].join('/');
    }
    window.location.hash = hash;
}
function loadHashId() {
    splitHash = window.location.hash.split('/');

    if (splitHash.length == 4) {
        // also includes nodeId
        hashID = splitHash[3];
        openNode(splitHash[3]);
    }
    hashLoaded = true;
}
function loadHash(defaultLat, defaultLon, defaultZoom) {
    splitHash = window.location.hash.split('/');

    if (splitHash.length >= 3) {
        if(splitHash[0].indexOf('#') === 0)
            splitHash[0] = splitHash[0].substr(1);
        mymap.setView([parseFloat(splitHash[0]), parseFloat(splitHash[1])], parseInt(splitHash[2]));
    } else {
        mymap.setView([defaultLat, defaultLon], defaultZoom);
    }
    loadHashId();
}
if ("onhashchange" in window) {
    // move popup for node if anchor is changed
    window.onhashchange = function () {
        openNode(window.location.hash.substring(1));
    }
}
