#!/bin/bash

# Set the webhook URL
WEBHOOK_URL=`gcloud secrets versions access latest --secret DISCORD_WEBHOOK_URL`

# Set the message content
MESSAGE=$1

# Send the message using cURL
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$MESSAGE\"}" $WEBHOOK_URL
