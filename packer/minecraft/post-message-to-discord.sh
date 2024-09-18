#!/bin/bash
SECRET_NAME=$1

# Set the webhook URL
WEBHOOK_URL=`gcloud secrets versions access latest --secret ${SECRET_NAME}`

# Set the message content
MESSAGE=$2

# Send the message using cURL
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$MESSAGE\"}" $WEBHOOK_URL
