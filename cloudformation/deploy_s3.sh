#!/bin/sh

ENVIRONMENT="dev"
CUSTOMER="atb"
APP="web"
MODULE="ssl"
COMPONENT="s3"
REGION="us-east-1"

STACK_NAME="${CUSTOMER}-${APP}-${MODULE}-${COMPONENT}-${ENVIRONMENT}"
PRIVATE_BUCKET="${CUSTOMER}-${APP}-${MODULE}-private-${ENVIRONMENT}"

aws cloudformation deploy --stack-name $STACK_NAME --region $REGION --capabilities CAPABILITY_NAMED_IAM \
	--template-file  "${COMPONENT}_template.yml" --no-fail-on-empty-changeset \
	--tags \
	    application=$APP \
	    customer=$CUSTOMER \
	    environment=$ENVIRONMENT \
	--parameter-overrides \
	    EnvironmentName=$ENVIRONMENT \
	    PrivateBucket=$PRIVATE_BUCKET
