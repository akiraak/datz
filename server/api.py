from config import Config
from flask import Blueprint, request, jsonify, render_template, redirect
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from app import app, db
from models import User, DBConfig
from tools import fcm

api_routes = Blueprint('api', __name__)
login_manager = LoginManager(app)


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(user_id)


def responseSuccess(data):
    return jsonify({'status': 'ok', 'data': data})


def responseFailed(message):
    return jsonify({'status': 'ng', 'message': message})


@api_routes.route('/v1/apis')
@login_required
def v1_apis():
    return render_template('apis.html')


@api_routes.route('/v1/signup', methods=['POST'])
def v1_signup():
    username = request.json.get('username')
    password = request.json.get('password')
    name_display = request.json.get('name_display')
    if username is None or username == '' or password is None or password == '':
        return responseFailed('Missing arguments.')
    if User.query.filter_by(name=username).first() is not None:
        return responseFailed('Already exists.')

    user = User.create(
        name=username,
        name_display=name_display,
        password=password)
    return responseSuccess(user.to_dict())


@api_routes.route('/v1/signup_form', methods=['GET', 'POST'])
def v1_signup_form():
    if request.method == "POST":
        username = request.form.get('username')
        password = request.form.get('password')
        if username is None or username == '' or password is None or password == '':
            return responseFailed('Missing arguments.')
        if User.query.filter_by(name=username).first() is not None:
            return responseFailed('Already exists.')

        User.create(name=username, name_display=username, password=password)
        return responseSuccess({})
    return render_template('signup.html')


@api_routes.route('/v1/signin', methods=['POST'])
def v1_signin():
    if current_user.is_authenticated:
        return responseSuccess(current_user.to_dict())

    username = request.json.get('username')
    password = request.json.get('password')
    push_fcm_token = request.json.get('push_fcm_token')
    if username is None or username == '' or password is None or password == '':
        return responseFailed('Missing arguments.')

    user = User.query.filter_by(name=username).first()
    if user is None or not user.check_password(password):
        return responseFailed('Invalid email or password')
    login_user(user, remember=True)
    user.set_push_fcm_token(push_fcm_token=push_fcm_token)

    return responseSuccess(user.to_dict())


@api_routes.route('/v1/signin_form', methods=['GET', 'POST'])
def v1_signin_form():
    if request.method == "POST":
        username = request.form.get('username')
        password = request.form.get('password')
        user = User.query.filter_by(name=username).first()
        if user and user.check_password(password):
            login_user(user)
            return redirect('/api/v1/user')
    return render_template('signin.html')


@api_routes.route('/v1/signout')
@login_required
def v1_signout():
    logout_user()
    return responseSuccess({})


@api_routes.route('/v1/set_push_fcm_token', methods=['POST'])
@login_required
def v1_set_push_fcm_token():
    push_fcm_token = request.json.get('push_fcm_token')
    print("push_fcm_token:", push_fcm_token)
    user = User.query.get(current_user.id)
    user.set_push_fcm_token(push_fcm_token=push_fcm_token)
    return responseSuccess({})


@api_routes.route('/v1/user')
@login_required
def v1_user():
    return responseSuccess(current_user.to_dict())
