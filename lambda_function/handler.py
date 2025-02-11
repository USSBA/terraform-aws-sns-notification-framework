from email.message import EmailMessage
from string import Template
from datetime import datetime
from dateutil import tz
import boto3, json, os, sys
import smtplib, urllib, ssl

# Environment Variables
# --------------------------------------------------
# AWS_REGION
# EMAIL_FROM
# EMAIL_TO
# --------------------------------------------------

def format_event_time(time):
    try:
        input_datetime = datetime.strptime(time, "%Y-%m-%dT%H:%M:%S.%f%z")
        est = tz.gettz('US/Eastern')
        input_datetime_est = input_datetime.astimezone(est)
        output_str = input_datetime_est.strftime("%A, %B %d, %Y %I:%M:%S %p EDT")
        return output_str
    except ValueError as e:
        print(f"Error parsing time: {time} -> {str(e)}")
        return None

class Alert:
    def __init__(self, record):
        self.record = record
        self.ses_client = boto3.client('ses')

    def send_email(self, subject, plain_text, hyper_text):
        from_email = os.environ.get('EMAIL_FROM', 'undefined')
        to_email = os.environ.get('EMAIL_TO', 'undefined')
        print(f'EmailFrom: {from_email}')
        print(f'EmailTo: {to_email}')
        if from_email == 'undefined' or to_email == 'undefined':
            print(f'Email notifications are disabled, EmailFrom = {from_email}, EmailTo = {to_email}')
        else:
            result = self.ses_client.send_email(
                Source=from_email,
                Destination={
                    'ToAddresses': to_email.replace(" ","").split(","),
                    'CcAddresses': [],
                    'BccAddresses': []
                },
                Message={
                    'Subject': {
                        'Data': subject,
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
## EmailAlert
## Derived Class from Alert
## Generates template text accordingly and utilizes the base class functions to send email alerts/messages
class EmailAlert(Alert):
    def __init__(self, record):
        super().__init__(record)

    def __send_cloud_watch_alert(self):
        alarm = {}
        event_time = self.record.message.get('StateChangeTime', 'Unknown')
        if event_time != 'Unknown':
            event_time = format_event_time(event_time)
            if event_time:
                event_time = event_time

        alarm_name = self.record.message.get('AlarmName', 'Unknown Alarm')
        alarm_description = self.record.message.get('AlarmDescription', 'No description available')
        def convert_line_breaks(description):
            return description.replace("\\n\\n", "<br><br>)")
        alarm_description_html = convert_line_breaks(alarm_description)
        new_state_value = self.record.message.get('NewStateValue', 'Unknown State')
        metric_name = self.record.message.get('Trigger', {}).get('MetricName', 'Unknown Metric')
        namespace = self.record.message.get('Trigger', {}).get('Namespace', 'Unknown Namespace')
        threshold = self.record.message.get('Trigger', {}).get('Threshold', 'Unknown Threshold')
        page_link = f"https://console.aws.amazon.com/cloudwatch/home?region={self.record.region}#alarmsV2:alarm/{self.record.message.get('AlarmName', '')}"

        alarm.update({
            'AlertType': 'CloudWatch Alarm Notification',
            'EventTime': event_time,
            'AlarmName': alarm_name,
            'AlarmDescription': alarm_description_html,
            'NewStateValue': new_state_value,
            'MetricName': metric_name,
            'Namespace': namespace,
            'Threshold': threshold,
            'PageLink': page_link
        })

        subject = f"{alarm_name}"

        # Send email for CloudWatch alert
        with open('templates/cloudwatch.txt', 'r') as txt:
            with open('templates/cloudwatch.html', 'r') as htm:
                txt_template = Template(txt.read())
                htm_template = Template(htm.read())
                plain_text = txt_template.safe_substitute(alarm)
                html_text = htm_template.safe_substitute(alarm)
                print(f'EmailText: {plain_text}')
                print(f'EmailHtml: {html_text}')
                self.send_email(subject, plain_text, html_text)

    def __send_backup_job_alert(self):
        alarm = {}
        event_time = self.record.message.get('Time', 'Unknown')
        if event_time != 'Unknown':
            event_time = format_event_time(event_time)
            if event_time:
                event_time = event_time
        event_type = self.record.message.get('EventType', 'Unknown Event Type')
        status = self.record.record.get("MessageAttributes", {}).get("State", {}).get("Value", "Unknown Status")
        job_name = self.record.message.get('BackupJobName', 'Unknown Job')
        backup_plan = self.record.message.get('BackupPlanName', 'Unknown Plan')

        alarm.update({'AlertType': 'AWS Backup Event Notification'})
        alarm.update({'EventTime': event_time})
        alarm.update({'EventType': event_type})
        alarm.update({'Status': status})
        alarm.update({'JobName': job_name})
        alarm.update({'BackupPlan': backup_plan})

        subject = f"{job_name}"

        # Send email for backup job alert
        with open('templates/default.txt', 'r') as txt:
            with open('templates/default.html', 'r') as htm:
                txt_template = Template(txt.read())
                htm_template = Template(htm.read())
                plain_text = txt_template.safe_substitute(alarm)
                html_text = htm_template.safe_substitute(alarm)
                print(f'EmailText: {plain_text}')
                print(f'EmailHtml: {html_text}')
                self.send_email(subject, plain_text, html_text)


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
        # Default severity to red
        self.color = 'red'
        self.level = 2
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
        self.severity = SeverityLevel('red')

    def alert(self):
        email_alert = EmailAlert(self)
        return email_alert.alert()

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
