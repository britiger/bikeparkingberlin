from flask import jsonify, render_template, request, abort
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
    is_cluster = request.args.get('is_cluster', False)

    sql = text('SELECT * FROM extern.external_data WHERE city=:city')
    external_data = db.engine.execute(sql, {'city': city}).fetchone()

    if external_data is None:
        abort(404)

    suffix = external_data['suffix']
    if is_cluster is not False and external_data['is_cluster'] is False:
        abort(404)
    if is_cluster is not False:
        suffix += '_cluster'

    where_condition = ''
    filter_execute = {}
    lessContent = True
    if bbox != '':
        (southwest_lng, southwest_lat, northeast_lng, northeast_lat) = bbox.split(',')
        linestring = 'LINESTRING(' + southwest_lng + ' ' + southwest_lat + ',' + northeast_lng + ' ' + northeast_lat + ')'
        where_condition = ' WHERE ST_WITHIN(st_transform(geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )'
        filter_execute = {'linestring': linestring}
        lessContent = False

    sql = text('SELECT *, ST_X(ST_Centroid(ST_Transform(geom, 4326))) AS lon, ST_Y(ST_Centroid(ST_Transform(geom, 4326))) AS lat FROM extern.missing_parking_' + suffix + where_condition)
    result = db.engine.execute(sql, filter_execute)

    return render_geojson_nodes_external(result, city, lessContent=lessContent)


@bp.route('/geojson/existing/<city>')
def geojson_existing(city):
    bbox = request.args.get('bbox', '')
    is_cluster = request.args.get('is_cluster', False)

    sql = text('SELECT * FROM extern.external_data WHERE city=:city')
    external_data = db.engine.execute(sql, {'city': city}).fetchone()

    if external_data is None:
        abort(404)

    suffix = external_data['suffix']
    if is_cluster is not False and external_data['is_cluster'] is False:
        abort(404)

    if is_cluster is not False:
        suffix += '_cluster'

    (southwest_lng, southwest_lat, northeast_lng, northeast_lat) = bbox.split(',')
    linestring = 'LINESTRING(' + southwest_lng + ' ' + southwest_lat + ',' + northeast_lng + ' ' + northeast_lat + ')'
    sql = text('SELECT existing_data.*, osm.osm_id int_osm_id, osm.typ int_typ, osm.name int_name, osm.bicycle_parking int_bicycle_parking, osm.access int_access, osm.capacity int_capacity, osm.covered int_covered, ST_X(ST_Centroid(ST_Transform(existing_data.geom, 4326))) AS lon, ST_Y(ST_Centroid(ST_Transform(existing_data.geom, 4326))) AS lat FROM extern.existing_parking_' + suffix + ' existing_data LEFT JOIN imposm3.view_parking osm ON osm.geom && ST_Expand(existing_data.geom, 50) WHERE ST_WITHIN(st_transform(existing_data.geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) ) ORDER BY st_distance(existing_data.geom,osm.geom)')
    result = db.engine.execute(sql, {'linestring': linestring})

    return render_geojson_nodes_external(result, city, True)


@bp.route('/geojson/value/<valueType>')
def get_values(valueType):
    json_result = []

    bbox = request.args.get('bbox', '')
    (southwest_lng, southwest_lat, northeast_lng, northeast_lat) = bbox.split(',')
    linestring = 'LINESTRING(' + southwest_lng + ' ' + southwest_lat + ',' + northeast_lng + ' ' + northeast_lat + ')'
    sql = text('SELECT * FROM imposm3.view_parking WHERE ST_WITHIN(st_transform(geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )')

    result = db.engine.execute(sql, {'linestring': linestring})
    for row in result:
        if row[valueType] not in json_result and str(row[valueType]) != '':
            json_result.append(row[valueType])
    json_result.sort()

    return jsonify(json_result)


@bp.route('/geojson/rental/<city>/<brand>')
def geojson_rental(city, brand):
    bbox = request.args.get('bbox', '')

    sql = text('SELECT * FROM extern.rental_data WHERE city=:city AND brand=:brand')
    rental_data = db.engine.execute(sql, {'city': city, 'brand': brand}).fetchone()

    if rental_data is None:
        abort(404)

    suffix = rental_data['suffix']

    (southwest_lng, southwest_lat, northeast_lng, northeast_lat) = bbox.split(',')
    linestring = 'LINESTRING(' + southwest_lng + ' ' + southwest_lat + ',' + northeast_lng + ' ' + northeast_lat + ')'

    sql = text('SELECT existing_data.* FROM extern.existing_rental_' + suffix + ' existing_data WHERE ST_WITHIN(st_transform(existing_data.geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )')
    result_existing = db.engine.execute(sql, {'linestring': linestring})
    sql = text('SELECT existing_data.* FROM extern.missing_rental_' + suffix + ' existing_data WHERE ST_WITHIN(st_transform(existing_data.geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )')
    result_missing = db.engine.execute(sql, {'linestring': linestring})
    sql = text('SELECT existing_data.* FROM extern.unknown_rental_' + suffix + ' existing_data WHERE ST_WITHIN(st_transform(existing_data.geom,4326), ST_Envelope(ST_GeomFromText(:linestring, 4326) ) )')
    result_unknown = db.engine.execute(sql, {'linestring': linestring})

    return render_geojson_nodes_rental(result_existing, result_missing, result_unknown, city, rental_data['brand'], rental_data['target_operator'], rental_data['target_network'])


def render_geojson_nodes_external(result, city, existing=False, lessContent=False):
    features = []
    for row in result:
        if not lessContent:
            prop = {'popupContent': render_template('node_popup_external.html', node=row)}
        else:
            prop = {}
        for col_name in row.keys():
            if not lessContent or (row[col_name] is not None and col_name not in ['geom', 'lat', 'lon', 'x', 'y', 'long__mapinfo_', 'lat__mapinfo_', 'geojson', 'ogc_fid', 'int_osm_id', 'int_typ', 'int_name', 'int_access', 'int_bicycle_parking', 'int_capacity', 'int_covered', 'int_ranking']):
                prop[col_name] = row[col_name]
        if existing is True:
            prop['missing'] = 'no'
        geom = {'type': 'Point', 'coordinates': [row['lon'], row['lat']]}
        entry = {'type': 'Feature', 'properties': prop, 'geometry': geom}
#        if lessContent:
#            # Add id for maproulette
#            if prop['gml_id']:
#                entry['@id'] = prop['gml_id']
#            elif prop['stellplatz_nr']:
#                entry['@id'] = prop['stellplatz_nr']
#            elif prop['uuid']:
#                entry['@id'] = prop['uuid']
#            elif prop['ident']:
#                entry['@id'] = prop['ident']
#            elif prop['id']:
#                entry['@id'] = prop['id']

        features.append(entry)

    json_result = {'type': 'FeatureCollection', 'features': features}
    return jsonify(json_result)


def render_geojson_nodes_rental(result_existing, result_missing, result_unknown, city, target_brand, target_operator, target_network):
    features = []
    for row in result_existing:
        prop = {'popupContent': render_template('node_popup_rental.html', node=row)}
        prop['_color'] = 'green'
        check_names = True
        for col_name in row.keys():
            prop[col_name] = row[col_name]
        if 'int_brand' in prop:
            if target_brand and prop['int_brand'] != target_brand:
                check_names = False
        else:
            check_names = False

        if 'int_network' in prop:
            if target_network and prop['int_network'] != target_network:
                check_names = False
        else:
            check_names = False

        if 'int_operator' in prop:
            if target_operator and prop['int_operator'] != target_operator:
                check_names = False
        else:
            check_names = False

        if 'int_capacity' in prop:
            if 'capacity' in prop and str(prop['int_capacity']) != str(prop['capacity']):
                check_names = False
        else:
            check_names = False

        if not check_names:
            prop['_color'] = 'yellow'

        geom = {'type': 'Point', 'coordinates': [row['lon'], row['lat']]}
        entry = {'type': 'Feature', 'properties': prop, 'geometry': geom}

        features.append(entry)

    for row in result_missing:
        prop = {'popupContent': render_template('node_popup_rental.html', node=row)}
        prop['_color'] = 'red'
        for col_name in row.keys():
            prop[col_name] = row[col_name]

        geom = {'type': 'Point', 'coordinates': [row['lon'], row['lat']]}
        entry = {'type': 'Feature', 'properties': prop, 'geometry': geom}

        features.append(entry)

    for row in result_unknown:
        prop = {'popupContent': render_template('node_popup_rental.html', node=row)}
        prop['_color'] = 'purple'
        for col_name in row.keys():
            prop[col_name] = row[col_name]

        geom = {'type': 'Point', 'coordinates': [row['lon'], row['lat']]}
        entry = {'type': 'Feature', 'properties': prop, 'geometry': geom}

        features.append(entry)

    json_result = {'type': 'FeatureCollection', 'features': features}
    return jsonify(json_result)


def render_geojson_nodes(result, valueType):
    features = []
    for row in result:
        prop = {'osm_id': row['osm_id'],
                'requestedField': valueType,
                'requestedValue': row[valueType],
                'popupContent': render_template('node_popup.html', node=row)}
        geom = {'type': 'Point', 'coordinates': [row['lon'], row['lat']]}
        entry = {'type': 'Feature', 'properties': prop, 'geometry': geom}
        features.append(entry)

    json_result = {'type': 'FeatureCollection', 'features': features}
    return jsonify(json_result)
