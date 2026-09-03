"""AI Usage Collection Lambda Handler.

Validates incoming usage events and writes them to S3 with Hive-style partitioning.
"""

import json
import os
import re
from datetime import datetime

import boto3

s3 = boto3.client("s3")
USAGE_BUCKET = os.environ.get("USAGE_BUCKET", "")

VALID_CATEGORIES = frozenset([
    "debug", "feature", "review", "ops", "learning",
    "refactor", "security", "incident", "uncategorized",
])

UUID_REGEX = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", re.IGNORECASE
)


def validate_event(event_data: dict) -> list[str]:
    """Validate a usage event. Returns list of error messages (empty = valid)."""
    errors = []

    required = [
        "event_id", "timestamp", "user", "team", "category",
    ]
    for field in required:
        if field not in event_data:
            errors.append(f"Missing required field: {field}")

    if errors:
        return errors

    if not UUID_REGEX.match(str(event_data["event_id"])):
        errors.append("event_id must be a valid UUID")

    try:
        datetime.fromisoformat(event_data["timestamp"].replace("Z", "+00:00"))
    except (ValueError, AttributeError):
        errors.append("timestamp must be a valid ISO-8601 datetime")

    if not isinstance(event_data["user"], str) or not event_data["user"].strip():
        errors.append("user must be a non-empty string")

    if not isinstance(event_data["team"], str) or not event_data["team"].strip():
        errors.append("team must be a non-empty string")

    if event_data["category"] not in VALID_CATEGORIES:
        errors.append(f"category must be one of: {sorted(VALID_CATEGORIES)}")

    optional_numerics = ["session_credits", "duration_seconds"]
    for field in optional_numerics:
        if field in event_data:
            val = event_data[field]
            if not isinstance(val, (int, float)) or val < 0:
                errors.append(f"{field} must be a non-negative number")

    return errors


def build_s3_key(event_data: dict) -> str:
    """Build Hive-style partitioned S3 key from event data."""
    ts = datetime.fromisoformat(event_data["timestamp"].replace("Z", "+00:00"))
    team = event_data["team"]
    event_id = event_data["event_id"]
    return f"team={team}/year={ts.year}/month={ts.month:02d}/day={ts.day:02d}/{event_id}.json"


def lambda_handler(event, context):
    """API Gateway proxy handler for usage event ingestion."""
    try:
        body = json.loads(event.get("body") or "{}")
    except (json.JSONDecodeError, TypeError):
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": "Invalid JSON body"}),
        }

    errors = validate_event(body)
    if errors:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"errors": errors}),
        }

    s3_key = build_s3_key(body)

    # Remove 'team' from the JSON payload to avoid duplication with
    # the Hive-style partition key already present in the S3 path.
    body_for_s3 = {k: v for k, v in body.items() if k != "team"}

    s3.put_object(
        Bucket=USAGE_BUCKET,
        Key=s3_key,
        Body=json.dumps(body_for_s3),
        ContentType="application/json",
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"event_id": body["event_id"]}),
    }
