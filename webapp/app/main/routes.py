from flask import render_template, abort
from app.main import bp
from app import db

from sqlalchemy import text


@bp.route('/')
@bp.route('/index')
def index():
    return render_template('index.html')


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
        sql = text('SELECT * FROM imposm3.osm_borders WHERE name=:name LIMIT 1')
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

    return render_template('statistics.html', city_name=city_name, main=main, access=access, covered=covered, bicycle_parking=bicycle_parking, fee=fee, operator=operator)


@bp.route('/parkingmap')
def parkingmap():

    return render_template('parking_map.html')


@bp.route('/missingmap/<city>')
def missingmap(city):
    sql = text('SELECT * FROM public.external_data WHERE city=:city')
    external_data = db.engine.execute(sql, {'city': city}).fetchone()

    if external_data is None:
        abort(404)

    sql = text('SELECT count(*) from public.' + external_data['table_all_parking'])
    all_parking = db.engine.execute(sql).fetchone()[0]

    sql = text('SELECT count(*) from public.' + external_data['table_missing_parking'])
    missing_parking = db.engine.execute(sql).fetchone()[0]

    return render_template('missing_map.html', city=city, all_parking=all_parking, missing_parking=missing_parking, datasource=external_data['datasource'], lat=external_data['center_lat'], lon=external_data['center_lon'], zoom=external_data['zoom_level'])
