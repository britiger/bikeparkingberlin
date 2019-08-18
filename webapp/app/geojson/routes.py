from flask import jsonify, render_template, request
from app.geojson import bp
from app import db

from sqlalchemy import text


@bp.route('/geojson/parking/<valueType>')
def geojson_parking(valueType):
    bbox = request.args.get('bbox', '')

    (southwest_lng, southwest_lat, northeast_lng, northeast_lat) = bbox.split(',')
    linestring = 'LINESTRING(' + southwest_lng + ' ' + southwest_lat + ',' + northeast_lng + ' ' + northeast_lat + ')'
    sql = text('SELECT *, ST_X(ST_Centroid(ST_Transform(geom, 4326))) AS lon, ST_Y(ST_Centroid(ST_Transform(geom, 4326))) AS lat FROM imposm3.view_parking WHERE ST_WITHIN(st_transform(geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )')
    result = db.engine.execute(sql, {'linestring': linestring})

    return render_geojson_nodes(result, valueType)


@bp.route('/geojson/missing/<city>')
def geojson_missing(city):
    bbox = request.args.get('bbox', '')

    (southwest_lng, southwest_lat, northeast_lng, northeast_lat) = bbox.split(',')
    linestring = 'LINESTRING(' + southwest_lng + ' ' + southwest_lat + ',' + northeast_lng + ' ' + northeast_lat + ')'
    sql = text('SELECT *, ST_X(ST_Centroid(ST_Transform(geom, 4326))) AS lon, ST_Y(ST_Centroid(ST_Transform(geom, 4326))) AS lat FROM missing_parking_berlin WHERE ST_WITHIN(st_transform(geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )')
    result = db.engine.execute(sql, {'linestring': linestring})

    return render_geojson_nodes_external(result, city)

@bp.route('/geojson/value/<valueType>')
def get_values(valueType):
    json_result = []

    bbox = request.args.get('bbox', '')
    (southwest_lng, southwest_lat, northeast_lng, northeast_lat) = bbox.split(',')
    linestring = 'LINESTRING(' + southwest_lng + ' ' + southwest_lat + ',' + northeast_lng + ' ' + northeast_lat + ')'
    sql = text('SELECT * FROM imposm3.view_parking WHERE ST_WITHIN(st_transform(geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )')

    result = db.engine.execute(sql, {'linestring': linestring })
    for row in result:
        if row[valueType] not in json_result and str(row[valueType]) != '':
            json_result.append(row[valueType])
    json_result.sort()

    return jsonify(json_result)


def render_geojson_nodes_external(result, city):
    features = []
    for row in result:
        prop = {'popupContent': render_template('node_popup_' + city + '.html', node=row)}
        geom = {'type': 'Point', 'coordinates': [row['lon'], row['lat']]}
        entry = {'type': 'Feature', 'properties': prop, 'geometry': geom}
        features.append(entry)

    json_result = {'type': 'FeatureCollection', 'features': features}
    return jsonify(json_result)


def render_geojson_nodes(result, valueType):
    features = []
    for row in result:        
        prop = { 'osm_id' : row['osm_id'],
            'requestedField' : valueType,
            'requestedValue' : row[valueType], 

            'popupContent' : render_template('node_popup.html', node=row) }
        geom = { 'type' : 'Point', 'coordinates' : [ row['lon'], row['lat'] ] }
        entry = { 'type' : 'Feature', 'properties' : prop, 'geometry' : geom }
        features.append(entry)

    json_result = { 'type' : 'FeatureCollection', 'features' : features }
    return jsonify(json_result)
