from flask import render_template, abort
from app.main import bp
from app import db

from sqlalchemy import text

@bp.route('/')
@bp.route('/index')
def index():
    return render_template('index.html')

@bp.route('/statistics')
def statistics():
    osm_id = int(-62422)

    sql = text('SELECT count(*), typ, sum(capacity::int) FILTER (WHERE capacity ~ E\'^\\\\d+$\') AS sum_capacity FROM imposm3.view_parking WHERE st_within(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=:osm_id)) GROUP BY typ ORDER BY count DESC')
    main = db.engine.execute(sql,{ 'osm_id' : osm_id })

    sql = text('SELECT count(*), access from imposm3.view_parking WHERE st_within(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=:osm_id)) GROUP BY access ORDER BY count DESC')
    access = db.engine.execute(sql,{ 'osm_id' : osm_id })
    
    sql = text('SELECT count(*), covered from imposm3.view_parking WHERE st_within(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=:osm_id)) GROUP BY covered ORDER BY count DESC')
    covered = db.engine.execute(sql,{ 'osm_id' : osm_id })

    sql = text('SELECT count(*), bicycle_parking from imposm3.view_parking WHERE st_within(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=:osm_id)) GROUP BY bicycle_parking ORDER BY count DESC')
    bicycle_parking = db.engine.execute(sql,{ 'osm_id' : osm_id })

    sql = text('SELECT count(*), fee from imposm3.view_parking WHERE st_within(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=:osm_id)) GROUP BY fee ORDER BY count DESC')
    fee = db.engine.execute(sql,{ 'osm_id' : osm_id })

    sql = text('SELECT count(*), operator from imposm3.view_parking WHERE st_within(geom, (SELECT geom FROM imposm3.osm_borders WHERE osm_id=:osm_id)) GROUP BY operator ORDER BY count DESC')
    operator = db.engine.execute(sql,{ 'osm_id' : osm_id })

    return render_template('statistics.html', main=main, access=access, covered=covered, bicycle_parking=bicycle_parking, fee=fee, operator=operator)

@bp.route('/parkingmap')
def parkingmap():

    return render_template('parking_map.html')
