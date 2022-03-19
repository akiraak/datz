import datetime
from flask import Flask, Blueprint, render_template, send_from_directory, request, redirect, url_for, jsonify, session, flash
from flask_admin import Admin, AdminIndexView, expose
from flask_admin.contrib.fileadmin.s3 import S3FileAdmin
from flask_admin.contrib.sqla import ModelView
from flask_wtf.file import FileField, FileRequired, FileAllowed
import json
from libs.flask_admin_s3_upload import S3ImageUploadField
import os
import os.path as op
import urllib.request
from app import app, db
from config import Config
from models import DBConfig, User


class AppModelView(ModelView):
    column_default_sort = ('id', True)
    column_display_pk = True
    create_modal = True
    edit_modal = True


class UserView(AppModelView):
    column_exclude_list = ['password_hash', ]
    form_excluded_columns = ['password_hash', 'created_at']


class MyHomeView(AdminIndexView):
    @expose('/')
    def index(self):
        return self.render('admin/index.html')


def setup_flask_admin():
    app.config['FLASK_ADMIN_SWATCH'] = 'cerulean'

    admin = Admin(app, index_view=MyHomeView())
    admin.add_view(AppModelView(DBConfig, db.session, name='サーバパラメータ'))
    admin.add_view(UserView(User, db.session, category='ユーザー'))
