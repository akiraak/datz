from flask_login import UserMixin
from pytz import timezone
from sqlalchemy.sql.functions import current_timestamp
from werkzeug.security import generate_password_hash, check_password_hash
#from app import db, login
from app import db
from . import DBConfig


class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), index=True, unique=True, nullable=False)
    name_display = db.Column(db.String(120))
    password_hash = db.Column(db.String(128), nullable=False)
    push_fcm_token = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, server_default=current_timestamp())

    @classmethod
    def create(cls, name, name_display, password):
        user = User(
            name=name,
            name_display=name_display,
            password_hash = generate_password_hash(password))
        db.session.add(user)
        db.session.commit()
        return user

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def set_push_fcm_token(self, push_fcm_token):
        if push_fcm_token != None:
            self.push_fcm_token = push_fcm_token
            db.session.commit()

    def to_dict(self):
        db_config = DBConfig.get()
        return {
            'id': self.id,
            'name': self.name,
            'name_display': self.name_display,
            'push_fcm_token': self.push_fcm_token if self.push_fcm_token != None else "",
        }

    @classmethod
    def ids_dict(cls, ids):
        objs = cls.query.filter(cls.id.in_(ids)).all()
        return {o.id: o.to_dict() for o in objs}
