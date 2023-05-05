import base64, boto3, json, os, sys
from urllib.error import HTTPError
import urllib.request, urllib.parse
from string import Template
import smtplib, ssl
from email.message import EmailMessage

# Environment Variables
# --------------------------------------------------
# AWS_REGION
# EMAIL_FROM
# EMAIL_TO
# TEAMS_WEBHOOK_GREEN
# TEAMS_WEBHOOK_YELLOW
# TEAMS_WEBHOOK_RED
# TEAMS_WEBHOOK_SECURITY
# --------------------------------------------------

##
## Alert
## Abstract Class
## Performs the basic functions of sending MSTeams and Email alerts/messages
class Alert:
  def __init__(self, record):
    self.record = record
    self.ses_client = client = boto3.client('ses')

  def send_alert(self, message):
    try:
      url = SeverityLevel.get_webhook_url(self.record.severity.color)
      req = urllib.request.Request(url, message.encode('utf-8'), {'Content-Type': 'application/json'})
      result = urllib.request.urlopen(req)
    except HTTPError as e:
      print(json.dumps({"code": e.getcode(), "info": e.info().as_string()}, indent=2))
      raise

  def send_email(self, plain_text, hyper_text):
    from_email = os.environ.get('EMAIL_FROM', 'undefined')
    to_email = os.environ.get('EMAIL_TO', 'undefined')
    print(f'EmailFrom: {from_email}')
    print(f'EmailTo: {to_email}')
    #TODO: in the future we should use a simple regex to validate email format
    if from_email == 'undefined' or to_email == 'undefined':
      print(f'Email notifications are disabled, EmailFrom = {from_email}, EmailTo = {to_email}')
    else:
      result = self.ses_client.send_email(
        Source = from_email,
        Destination = {
          'ToAddresses': [to_email],
          'CcAddresses': [],
          'BccAddresses': []
        },
        Message = {
          'Subject': {
            'Data': 'Automated Notification',
            'Charset': 'utf-8'
          },
          'Body': {
            'Text': {
              'Data': plain_text,
              'Charset': 'utf-8'
            },
            'Html': {
              'Data': hyper_text,
              'Charset': 'utf-8'
            }
          }
        }
      )

##
## TeamsAlert
## Derived Class from Alert
## Generates template text accordingly and utilized the base class functions to send alerts/messages
class TeamsAlert(Alert):
  def __init__(self, record):
    super().__init__(record)

  def __send_cloud_watch_alert(self):
    alarm = {}
    page_link = f"https://console.aws.amazon.com/cloudwatch/home?region={self.record.region}#alarm:alarmFilter=ANY;name={urllib.parse.quote(self.record.message['AlarmName'])}"
    alarm.update({'AlarmName': self.record.message['AlarmName']})
    if self.record.message['NewStateValue'] == 'OK' and self.record.severity.level == 0:
      alarm.update({'AlarmDescription': f'{self.record.message["AlarmName"]} has returned to normal/expected operational levels'})
    else:
      alarm.update({'AlarmDescription': self.record.message['AlarmDescription']})
    alarm.update({'schema': '$schema'})
    alarm.update({'PageLink': page_link})
    alarm.update({'NewStateValue': self.record.message['NewStateValue']})
    with open('templates/cloudwatch.json', 'r') as t:
      cw_template = Template(t.read())
      self.send_alert(cw_template.substitute(alarm))
    # we only send email when the severity level is red/security
    if self.record.severity.level >= 2:
      with open('templates/cloudwatch.txt', 'r') as txt:
        with open('templates/cloudwatch.html', 'r') as htm:
          txt_template = Template(txt.read())
          htm_template = Template(htm.read())
          print(f'EmailText: {txt_template.substitute(alarm)}')
          print(f'EmailHtml: {htm_template.substitute(alarm)}')
          self.send_email(txt_template.substitute(alarm), htm_template.substitute(alarm))

  def __send_backup_job_alert(self):
    alarm = {}
    if self.record["Message"].__contains__("failed"):
      self.record.change_severity('red')
    alarm.update({'schema': '$schema'})
    alarm.update({'AlertType': 'AWS Backup Event Notification'})
    alarm.update({'Message': self.record["Message"]})
    alarm.update({'EventType': self.record["MessageAttributes"]["EventType"]["Value"]})
    alarm.update({'Status': self.record["MessageAttributes"]["State"]["Value"]})
    with open('templates/default.json', 'r') as t:
      vault_template = Template(t.read())
      self.send_alert(vault_template.substitute(alarm))
    # we only send email when the severity level is red/security
    if self.record.severity.level >= 2:
      with open('templates/default.txt', 'r') as txt:
        with open('templates/default.html', 'r') as htm:
          txt_template = Template(txt.read())
          htm_template = Template(htm.read())
          print(f'EmailText: {txt_template.substitute(alarm)}')
          print(f'EmailHtml: {htm_template.substitute(alarm)}')
          self.send_email(txt_template.substitute(alarm), htm_template.substitute(alarm))

  def alert(self):
    if self.record.is_cloudwatch_alarm:
      self.__send_cloud_watch_alert()
    elif self.record.is_backup_job:
      self.__send_backup_job_alert()
    else:
      print(json.dumps(self.record, indent=2))
      raise NotImplementedError('Notification Not Supported')

##
## SeverityLevel
## Stand Alone Class
## Determines the color and level of an alert based on the TopicArn or TopicName
class SeverityLevel:
  def __init__(self, name):
    if 'green' in name:
      self.color = 'green'
      self.level = 0
    elif 'yellow' in name:
      self.color = 'yellow'
      self.level = 1
    elif 'red' in name:
      self.color = 'red'
      self.level = 2
    else:
      self.color = 'security'
      self.level = 3

  @staticmethod
  def get_webhook_url(color):
    return os.environ.get(f'TEAMS_WEBHOOK_{color.upper()}', 'undefined')

##
## SnsRecord
## Stand Alone Class
## Determines how an SNS notification is handled
class SnsRecord:
  def __init__(self, record):
    self.record = record
    self.region = os.environ.get('AWS_REGION', 'us-east-1')
    self.topic_arn = record['TopicArn']
    self.topic_name = record['TopicArn'].split(':')[-1]
    self.severity = SeverityLevel(self.topic_name)
    print(f'Region = {self.region}')
    print(f'TopicArn = {self.topic_arn}')
    print(f'TopicName = {self.topic_name}')
    print(f'Level = {self.severity.level}')
    print(f'Color = {self.severity.color}')
    try:
      self.message = json.loads(record['Message'])
    except json.decoder.JSONDecodeError as e:
      self.message = record['Message']
    self.is_cloudwatch_alarm = (isinstance(self.message, dict) and 'AlarmArn' in self.message.keys())
    print(f'IsCloudWatchAlarm = {self.is_cloudwatch_alarm}')
    self.is_backup_job = (isinstance(self.record, dict)
      and 'MessageAttributes' in self.record.keys()
      and 'EventType' in self.record['MessageAttributes'].keys()
      and self.record['MessageAttributes']['EventType']['Value'] == 'BACKUP_JOB')
    print(f'IsBackupJob = {self.is_backup_job}')

  def change_severity(self, color):
    self.severity = SeverityLevel(color)

  def alert(self):
    teams = TeamsAlert(self)
    return teams.alert()

##
## Lambda Handler
## Required Method for AWS Lambda
## Determine the type of Notification and act accordingly
def lambda_handler(event, context):
  for r in event['Records']:
    try:
      # test to see if this is an SNS notificaiton
      if isinstance(r, dict) and 'Sns' in r.keys():
        record = SnsRecord(r['Sns'])
        record.alert()
        return json.dumps({'code': 200, 'info': 'Success'})
      else:
        # when this exception is raised then we need to write some code to support this event
        raise NotImplementedError('Event Not Supported')
    except Exception as e:
      print('Error: Event could not be processed.')
      print(json.dumps(event, indent=2))
      raise

##
## Unit Testing
## Used when testing from the local machine.
if __name__ == "__main__":
  if len(sys.argv) != 2:
    print(f'Usage: python3 lambda_handler.py [file(json)]')
    sys.exit(1)

  with open(sys.argv[1], 'r') as f:
    e = json.load(f)
    lambda_handler(e, None)

