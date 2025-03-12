import json
import boto3
import urllib.request
import os
import time

# AWS SQS Client
sqs = boto3.client("sqs")

# Environment Variables
SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")
MESSAGE_FIELDS = os.getenv(
    "MESSAGE_FIELDS",
    "detail.instance-id,detail.state,time,region,account"
)
MESSAGE_TITLE = os.getenv(
    "MESSAGE_TITLE", "SQS Message Received"
)
STATUS_COLORS = os.getenv("STATUS_COLORS", "")
STATUS_FIELD = os.getenv("STATUS_FIELD", "detail.state")
STATUS_MAPPING = os.getenv("STATUS_MAPPING", "")

MESSAGE_FIELDS = [field.strip() for field in
                  MESSAGE_FIELDS.split(",")] if MESSAGE_FIELDS else []

STATUS_COLOR_MAP = {}
if STATUS_COLORS:
    STATUS_COLOR_MAP = {pair.split(":")[0]: pair.split(":")[1] for pair in
                        STATUS_COLORS.split(",") if ":" in pair}

STATE_MAP = {}
if STATUS_MAPPING:
    STATE_MAP = {pair.split(":")[0]: pair.split(":")[1] for pair in
                 STATUS_MAPPING.split(",") if ":" in pair}


def exponential_backoff(retries):
    return min(2 ** retries, 60)


def extract_field(message, field_path):
    keys = field_path.split(".")
    value = message
    for key in keys:
        if isinstance(value, dict) and key in value:
            value = value[key]
        else:
            return "N/A"
    return value


def map_custom_state(status):
    return STATE_MAP.get(status.lower(), status)


def get_status(message):
    raw_status = extract_field(message, STATUS_FIELD)
    return map_custom_state(raw_status)


def get_status_color(status):
    if not STATUS_COLOR_MAP:
        return None
    return STATUS_COLOR_MAP.get(status.upper(), None)


def format_slack_message(message):
    if not MESSAGE_FIELDS:
        return {"text": "⚠️ No fields specified in "
                        "MESSAGE_FIELDS environment variable."}

    status = get_status(message)
    color = get_status_color(status)
    print(f"🔹 Extracted status: {status} → Mapped to color: {color}")

    formatted_fields = []
    for field in MESSAGE_FIELDS:
        value = extract_field(message, field)
        formatted_fields.append({"title": field.replace(".", " ").title(),
                                "value": f"`{value}`", "short": False})

    slack_message = {
        "attachments": [
            {
                "pretext": f"*{MESSAGE_TITLE}*",
                "fields": formatted_fields
            }
        ]
    }

    if color:
        slack_message["attachments"][0]["color"] = color

    return slack_message


def send_slack_notification(message):
    formatted_message = format_slack_message(message)
    data = json.dumps(formatted_message).encode("utf-8")
    req = urllib.request.Request(
        SLACK_WEBHOOK_URL,
        data=data,
        headers={"Content-Type": "application/json"}
    )

    retries = 0
    while retries < 5:
        try:
            with urllib.request.urlopen(req) as response:
                response_body = response.read().decode("utf-8")
                if response.status == 200:
                    print(
                        f"✅ Slack notification sent successfully! "
                        f"Response: {response_body}"
                    )
                    return
                else:
                    print(
                        f"⚠️ Slack responded with status {response.status}: "
                        f"{response_body}"
                    )
        except Exception as e:
            print(f"❌ Failed to send to Slack (Attempt {retries+1}): {str(e)}")
            time.sleep(exponential_backoff(retries))
            retries += 1

    raise Exception("Slack API failed after multiple retries")


def lambda_handler(event, context):
    if not SLACK_WEBHOOK_URL:
        print("❌ SLACK_WEBHOOK_URL is not set. Exiting.")
        raise Exception("SLACK_WEBHOOK_URL variable is empty.")

    if not MESSAGE_FIELDS:
        print("⚠️ No fields specified in MESSAGE_FIELDS environment variable.")
        raise Exception("MESSAGE_FIELDS environment variable is empty.")

    for record in event.get("Records", []):
        try:
            message_body = json.loads(record["body"])
            print(f"📨 Processing SQS Message: {message_body}")
            send_slack_notification(message_body)

        except Exception as e:
            print(f"⚠️ Error processing queue message: {str(e)}")
            raise e
