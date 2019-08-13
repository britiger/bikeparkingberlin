from flask import Flask, request, current_app
from config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_babel import Babel
from json import loads

db = SQLAlchemy()
babel = Babel()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    babel.init_app(app)
    
    from app.main import bp as main_bp
    app.register_blueprint(main_bp)

    from app.geojson import bp as geojson_bp
    app.register_blueprint(geojson_bp)
    
    # adding functions to jinja
    app.jinja_env.globals.update(json_loads=loads)

    return app

@babel.localeselector
def get_locale():
    return request.accept_languages.best_match(current_app.config['LANGUAGES'])