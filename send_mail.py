import sendgrid
import os
import json
import datetime
import sys
from sendgrid.helpers.mail import *

with open(sys.argv[1], 'r') as config_file:
    config = json.load(config_file)

with open(sys.argv[2], 'r') as summary_file:
    summary = summary_file.read()

sg = sendgrid.SendGridAPIClient(apikey=config['sendgrid_api_key'])
from_email = Email(config['from_email'])
to_email = Email(config['to_email'])
subject = "e2erunner results " + str(datetime.datetime.utcnow()) + " UTC"
content = Content("text/plain", summary)
mail = Mail(from_email, subject, to_email, content)
response = sg.client.mail.send.post(request_body=mail.get())
print(response.status_code)
print(response.body)
print(response.headers)
