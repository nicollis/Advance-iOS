from flask import Flask

app = Flask(__name__)
from app import auth
from app import views
from app import prefs
