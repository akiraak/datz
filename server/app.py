from flask import Flask
#from flask_httpauth import HTTPBasicAuth
#from flask_login import LoginManager
from flask_migrate import Migrate
from flask_session import Session
from flask_sqlalchemy import SQLAlchemy
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
db = SQLAlchemy(app)
migrate = Migrate(app, db)
session = Session(app)
session.app.session_interface.db.create_all()
#login_manager = LoginManager(app)

from admin import setup_flask_admin
setup_flask_admin()
from api import api_routes
app.register_blueprint(api_routes, url_prefix='/api')


@app.route('/')
def hello_world():
    return 'Welcome datz'


import scheduler
scheduler.init()