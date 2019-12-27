from flask import Blueprint

bp = Blueprint('geojson', __name__)

from app.geojson import routes
