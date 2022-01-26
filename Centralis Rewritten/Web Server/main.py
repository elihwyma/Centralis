from apns2.client import APNsClient
from apns2.payload import PayloadAlert, Payload

device_token = "0833f94ec6e32dbf1fff2ff989b2eeda03b64b0773621d4bcdda3435353117f3"
payload = PayloadAlert(title="New Message", body="Hello World!")
alert = Payload(alert=payload, badge=1)
topic = 'com.amywhile.Centralis'
client = APNsClient('CentralisNotificationKey.pem', use_sandbox=True, use_alternative_port=False)
for i in range(1, 100):
    client.send_notification(device_token, alert, topic)
