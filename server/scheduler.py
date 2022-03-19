from app import app
from apscheduler.schedulers.background import BackgroundScheduler
from config import Config
from datetime import datetime
import pytz
import re
import time
from tools import fcm


def send_daily_push(*args):
    app.logger.warning("==== send_daily_push() ====")
    pst_time = datetime.now(pytz.timezone('America/Los_Angeles'))
    jst_time = datetime.now(pytz.timezone('Asia/Tokyo'))
    app.logger.warning("PST:{}".format(pst_time))
    app.logger.warning("JST:{}".format(jst_time))
    id = args[0]
    app.logger.warning("id:{}".format(id))
    dp = DailyPush.query.get(id)
    app.logger.warning("title:{}".format(dp.title))
    app.logger.warning("body:{}".format(dp.body))
    serverToken = Config.FIREBASE_FCM_KEY
    users = User.query.all()
    for user in users:
        deviceToken = user.push_fcm_token
        if deviceToken != None and deviceToken != "":
            response = fcm.send_push(
                serverToken=serverToken,
                deviceToken=deviceToken,
                title=dp.title,
                body=dp.body)


scheduler = None


def init():
    global scheduler
    scheduler = BackgroundScheduler(timezone=pytz.timezone('Asia/Tokyo'))
    scheduler.start()
