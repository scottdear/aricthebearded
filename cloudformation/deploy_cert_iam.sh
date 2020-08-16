#!/bin/sh

ENVIRONMENT="dev"
AWS_ACCOUNT_ID="<YOUR_ACCOUNT>"
CUSTOMER="atb"
APP="web"
MODULE="ssl"
COMPONENT="cert-iam"
REGION="us-east-1"
HOSTED_ZONE_ID="Z04156561UJTD1JXFR76"

STACK_NAME="${CUSTOMER}-${APP}-${MODULE}-${COMPONENT}-${ENVIRONMENT}"
PRIVATE_BUCKET="${CUSTOMER}-${APP}-${MODULE}-private-${ENVIRONMENT}"
CERT_LAMBDA_ROLE="${CUSTOMER}-${APP}-${MODULE}-${COMPONENT}-${ENVIRONMENT}-role"

aws cloudformation deploy --stack-name $STACK_NAME --region $REGION --capabilities CAPABILITY_NAMED_IAM \
	--template-file  "${COMPONENT}_template.yml" --no-fail-on-empty-changeset \
	--tags \
	    application=$APP \
	    customer=$CUSTOMER \
	    environment=$ENVIRONMENT \
	--parameter-overrides \
	    Region=$REGION \
	    EnvironmentName=$ENVIRONMENT \
	    AWSAccount=AWS_ACCOUNT_ID \
	    PrivateBucket=$PRIVATE_BUCKET \
	    HostedZoneID=$HOSTED_ZONE_ID \
	    CertLambaRoleName=$CERT_LAMBDA_ROLE
