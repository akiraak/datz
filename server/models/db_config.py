from app import db
from datetime import datetime
from sqlalchemy.sql.functions import current_timestamp


default = {
    'updated_at': datetime.now(),
}

class DBConfig(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    updated_at = db.Column(db.DateTime, server_default=current_timestamp())

    @classmethod
    def get(cls):
        obj = cls.query.get(1)
        if obj == None:
            obj = cls()
            for k, v in default.items():
                setattr(obj, k, v)
            db.session.add(obj)
            db.session.commit()
        return obj

    def to_dict(self):
        return {
            'id': self.id,
            'updated_at': self.updated_at,
        }
