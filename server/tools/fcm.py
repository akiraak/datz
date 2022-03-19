import requests
import json


def send_push(serverToken, deviceToken, title, body):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=' + serverToken,
    }
    body = {
        'notification': {
            'title': title,
            'body': body
        },
        'to': deviceToken,
        'priority': 'high',
    }
    response = requests.post(
        "https://fcm.googleapis.com/fcm/send",
        headers=headers,
        data=json.dumps(body))
    #print(response.status_code)
    #print(response.json())
    return response.json()
