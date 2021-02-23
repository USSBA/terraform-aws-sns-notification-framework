import os, boto3, json, base64
from urllib.error import HTTPError
import urllib.request, urllib.parse
def lambda_handler(event, context):
  subject = event['Records'][0]['Sns']['Subject']
  message = event['Records'][0]['Sns']['Message']
  region = event['Records'][0]['Sns']['TopicArn'].split(":")[3]

  response = notify_teams(subject, message, region)
  if json.loads(response)["code"] != 200:
    print("Error sending Teams: received status `{}` using event `{}` and context `{}`".format(json.loads(response)["info"], event, context))
  return response
def notify_teams(subject, message, region):
  teams_url = os.environ['TEAMS_WEBHOOK_URL']
  url = os.environ['TEAMS_WEBHOOK_URL']
  data = json.dumps({'text': message}).encode("utf-8")
  headers = {'Content-Type': 'application/json'}

  req = urllib.request.Request(url, data, headers)

  try:
    result = urllib.request.urlopen(req)
    print(result)
    return json.dumps({"code": result.getcode(), "info": result.info().as_string()})

  except HTTPError as e:
    print("{}: result".format(e))
    return json.dumps({"code": e.getcode(), "info": e.info().as_string()})
