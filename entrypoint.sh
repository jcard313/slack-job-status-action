#!/bin/sh

set -eu

# Lowercase job status
JOB_STATUS=$(echo "$1" | tr '[:upper:]' '[:lower:]')
SLACK_BOT_TOKEN=$2
CHANNEL=$3
PARTNER_NAME=$4

REPO_NAME=${GITHUB_REPOSITORY##*/}
REPOSITORY=$GITHUB_REPOSITORY
WORKFLOW=$GITHUB_WORKFLOW
BRANCH=${GITHUB_REF##*/}
RUN_ID=$GITHUB_RUN_ID

slackMsg() {
    title=$1
    color=$2
    msg="{\"channel\":\"$CHANNEL\", \"attachments\": [ { \"title\":\"$title [ $REPO_NAME ] : [ $WORKFLOW ] : [ $BRANCH ]\", \"text\": \"https://github.com/$REPOSITORY/actions/runs/$RUN_ID\", \"color\": \"$color\" } ]}"
}

if [ "$JOB_STATUS" = 'success' ]; then
    slackMsg "SUCCESS [$PARTNER_NAME]" "#00FF00"
    elif [ "$JOB_STATUS" = 'cancelled' ]; then
    slackMsg "CANCELLED [$PARTNER_NAME]" "#EE6F47"
else
    slackMsg "FAILURE [$PARTNER_NAME]" "#FF0000"
fi

curl -X POST \
-H "Content-type: application/json" \
-H "Authorization: Bearer $SLACK_BOT_TOKEN" \
-d "$msg" \
https://slack.com/api/chat.postMessage
