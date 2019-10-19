from flask import render_template as flask_render_template, request, abort
from app.main import bp
from app import db
from os import environ

from sqlalchemy import text


def render_template(template, **kwargs):
    sql = text('SELECT * FROM extern.external_data ORDER BY city')
    external_data = db.engine.execute(sql)
    kwargs.update({'_external_data': external_data.fetchall()})
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

    sql = text('SELECT count(*), typ, sum(capacity::int) FILTER (WHERE capacity ~ E\'^\\\\d+$\') AS sum_capacity FROM imposm3.view_parking ' + where_condition + ' GROUP BY typ ORDER BY count DESC')
    main = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), access from imposm3.view_parking ' + where_condition + ' GROUP BY access ORDER BY count DESC')
    access = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), covered from imposm3.view_parking ' + where_condition + ' GROUP BY covered ORDER BY count DESC')
    covered = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), bicycle_parking from imposm3.view_parking ' + where_condition + ' GROUP BY bicycle_parking ORDER BY count DESC')
    bicycle_parking = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), fee from imposm3.view_parking ' + where_condition + ' GROUP BY fee ORDER BY count DESC')
    fee = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), operator from imposm3.view_parking ' + where_condition + ' GROUP BY operator ORDER BY count DESC')
    operator = db.engine.execute(sql, filter_execute)

    sql = text('SELECT count(*), all_tags->\'bicycle_parking:position\' AS position from imposm3.view_parking ' + where_condition + ' GROUP BY all_tags->\'bicycle_parking:position\' ORDER BY count DESC')
    position = db.engine.execute(sql, filter_execute)

    return render_template('statistics.html', city_name=city_name, main=main, access=access, covered=covered, bicycle_parking=bicycle_parking, fee=fee, operator=operator, osm_id=osm_id, position=position)


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

    sql = text('SELECT count(*) from extern.missing_parking_' + suffix)
    missing_parking = db.engine.execute(sql).fetchone()[0]

    return render_template('missing_map.html', city=city, all_parking=all_parking, missing_parking=missing_parking, external_data=external_data, is_cluster=is_cluster)
