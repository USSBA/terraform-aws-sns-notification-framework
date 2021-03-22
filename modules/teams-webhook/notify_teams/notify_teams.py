import os, boto3, json, base64
from urllib.error import HTTPError
import urllib.request, urllib.parse
from string import Template

def lambda_handler(event, context):
  subject = event['Records'][0]['Sns']['Subject']
  message = event['Records'][0]['Sns']['Message']
  region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]

  if is_cloudwatch(message):
    webhook_body = process_cloudwatch(message, region)
  else:
    webhook_body = json.dumps({'text': message})

  response = notify_teams(webhook_body, region)
  if json.loads(response)["code"] != 200:
    print("Error sending Teams: received status `{}`".format(json.loads(response)["info"]))
    print(f"****EVENT: {event}")
    print(f"****CONTEXT: {context}")
    print(f"****WEBHOOK_BODY: {webhook_body}")
  return response


def notify_teams(webhook_body, region):
  teams_url = os.environ['TEAMS_WEBHOOK_URL']
  url = os.environ['TEAMS_WEBHOOK_URL']
  data = webhook_body.encode("utf-8")
  headers = {'Content-Type': 'application/json'}

  req = urllib.request.Request(url, data, headers)

  try:
    result = urllib.request.urlopen(req)
    print(result)
    return json.dumps({"code": result.getcode(), "info": result.info().as_string()})

  except HTTPError as e:
    print("{}: result".format(e))
    return json.dumps({"code": e.getcode(), "info": e.info().as_string()})

def is_cloudwatch(message):
  return "AlarmName" in message

def process_cloudwatch(message, region):
  alarm = json.loads(message)
  with open('cloudwatch_template.json', 'r') as cloudwatch_template:
    alarm.update({'schema': '$schema'})
    #teams_color_map = {'OK': 'good', 'INSUFFICIENT_DATA': 'warning', 'ALARM': 'attention'}
    #alarm.update({'NewStateColor': teams_color_map[alarm['NewStateValue']]})
    alarm_url = f"https://console.aws.amazon.com/cloudwatch/home?region={region}#alarm:alarmFilter=ANY;name={urllib.parse.quote(alarm['AlarmName'])}"
    alarm.update({'ALARM_URL': alarm_url})
    src = Template(cloudwatch_template.read())
    result = src.substitute(alarm)
    return result
