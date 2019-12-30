from flask import render_template as flask_render_template, request, abort
from app.main import bp
from app import db
from os import environ

from sqlalchemy import text


def render_template(template, **kwargs):
    sql = text('SELECT * FROM extern.external_data ORDER BY city')
    external_data = db.engine.execute(sql)
    kwargs.update({'_external_data': external_data.fetchall()})
    sql = text('SELECT *, count(*) OVER (PARTITION BY city) AS per_city, rank() OVER (PARTITION BY city ORDER BY brand) AS city_rank FROM extern.rental_data ORDER BY city, brand')
    rental_data = db.engine.execute(sql)
    kwargs.update({'_rental_data': rental_data.fetchall()})
    return flask_render_template(template, **kwargs)


@bp.route('/')
@bp.route('/index')
def index():
    return render_template('index.html')


@bp.route('/imprint')
def imprint():
    return render_template('imprint.html', imprint_addr=environ.get('imprint_addr'), imprint_mail=environ.get('imprint_mail'))


@bp.route('/statistics')
@bp.route('/statistics/<filter_text>')
def statistics(filter_text=' '):
    rental = request.args.get('rental', False)
    city_name = ''
    osm_id = 0

    if (len(filter_text) > 0 and filter_text.isnumeric()):
        osm_id = int(filter_text) * -1
        sql = text('SELECT * FROM imposm3.osm_borders WHERE osm_id=:osm_id LIMIT 1')
        city_res = db.engine.execute(sql, {'osm_id': osm_id})
        for row in city_res:
            city_name = row['name']
        if (city_name == ''):
            # Not found, show all
            osm_id = 0
    else:
        sql = text('SELECT * FROM imposm3.osm_borders WHERE name=:name ORDER BY admin_level LIMIT 1')
        city_res = db.engine.execute(sql, {'name': filter_text})
        for row in city_res:
            city_name = row['name']
            osm_id = row['osm_id']

    if (osm_id == 0):
        # Show all
        where_condition = ''
        filter_execute = {}
    else:
        where_condition = ' WHERE st_within(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=:osm_id)) '
        filter_execute = {'osm_id': osm_id}

    access = False
    bicycle_parking = False
    covered = False
    fee = False
    network = False
    position = False

    if rental:
        # bicycle_rental
        table_name = 'imposm3.view_rental'

        sql = text('SELECT count(*), network from imposm3.view_rental ' + where_condition + ' GROUP BY network ORDER BY count DESC')
        network = db.engine.execute(sql, filter_execute)

    else:
        # bicycle_parking
        table_name = 'imposm3.view_parking'

        sql = text('SELECT count(*), access from imposm3.view_parking ' + where_condition + ' GROUP BY access ORDER BY count DESC')
        access = db.engine.execute(sql, filter_execute)

        sql = text('SELECT count(*), covered from imposm3.view_parking ' + where_condition + ' GROUP BY covered ORDER BY count DESC')
        covered = db.engine.execute(sql, filter_execute)

        sql = text('SELECT count(*), bicycle_parking from imposm3.view_parking ' + where_condition + ' GROUP BY bicycle_parking ORDER BY count DESC')
        bicycle_parking = db.engine.execute(sql, filter_execute)

        sql = text('SELECT count(*), fee from imposm3.view_parking ' + where_condition + ' GROUP BY fee ORDER BY count DESC')
        fee = db.engine.execute(sql, filter_execute)

        sql = text('SELECT count(*), all_tags->\'bicycle_parking:position\' AS position from imposm3.view_parking ' + where_condition + ' GROUP BY all_tags->\'bicycle_parking:position\' ORDER BY count DESC')
        position = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), typ, sum(capacity::int) FILTER (WHERE capacity ~ E\'^\\\\d+$\') AS sum_capacity FROM ' + table_name + ' ' + where_condition + ' GROUP BY typ ORDER BY count DESC')
    main = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), operator from ' + table_name + ' ' + where_condition + ' GROUP BY operator ORDER BY count DESC')
    operator = db.engine.execute(sql, filter_execute)

    return render_template('statistics.html', city_name=city_name, main=main, access=access, covered=covered, bicycle_parking=bicycle_parking, fee=fee, operator=operator, osm_id=osm_id, position=position, network=network, rental=rental)


@bp.route('/parkingmap')
def parkingmap():

    return render_template('parking_map.html')


@bp.route('/missingmap/<city>')
def missingmap(city):
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
        is_cluster = True

    sql = text('SELECT count(*) from extern.all_parking_' + suffix)
    all_parking = db.engine.execute(sql).fetchone()[0]

    sql = text('SELECT count(*) from extern.missing_parking_' + suffix  + ' mp LEFT JOIN extern.external_feedback fb ON ST_EQUALS(mp.geom,fb.geom) WHERE fb.do_not_exists IS NULL OR NOT fb.do_not_exists' )
    missing_parking = db.engine.execute(sql).fetchone()[0]

    sql = text('SELECT count(*) from extern.external_feedback WHERE suffix=:suffix')
    do_not_exists = db.engine.execute(sql, {'suffix' : suffix}).fetchone()[0]

    return render_template('missing_map.html', city=city, all_parking=all_parking, missing_parking=missing_parking, do_not_exists=do_not_exists, external_data=external_data, is_cluster=is_cluster)


@bp.route('/rentalmap/<city>/<brand>')
def rentalmap(city, brand):

    sql = text('SELECT * FROM extern.rental_data WHERE city=:city AND brand=:brand')
    rental_data = db.engine.execute(sql, {'city': city, 'brand': brand}).fetchone()

    if rental_data is None:
        abort(404)

    suffix = rental_data['suffix']

    sql = text('SELECT count(*) from extern.all_rental_' + suffix)
    all_rental = db.engine.execute(sql).fetchone()[0]

    sql = text('SELECT count(*) from extern.missing_rental_' + suffix)
    missing_rental = db.engine.execute(sql).fetchone()[0]

    sql = text('SELECT count(*) from extern.unknown_rental_' + suffix)
    unknown_rental = db.engine.execute(sql).fetchone()[0]

    return render_template('rental_map.html', city=city, brand=brand, all_rental=all_rental, missing_rental=missing_rental, unknown_rental=unknown_rental, rental_data=rental_data)
