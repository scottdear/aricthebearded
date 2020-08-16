#!/bin/sh
# This script would be called by your continuous delivery application, e.g. Ansible, Octopus, etc.
ENVIRONMENT="dev"
RELEASE="0.1"     # Update this to force lambda code to update when no other config changes
CUSTOMER="atb"
APP="web"
MODULE="ssl"
COMPONENT="cert_update"
REGION="us-east-1"
HOSTED_ZONE_ID="Z04156561UJTD1JXFR76"
PARENT_IAM_STACK="${CUSTOMER}-${APP}-${MODULE}-cert_iam-${ENVIRONMENT}"
SCRIPT_PREFIX="cert_lambda/${RELEASE}"


STACK_NAME="${CUSTOMER}-${APP}-${MODULE}-${COMPONENT}-${ENVIRONMENT}"
PRIVATE_BUCKET="${CUSTOMER}-${APP}-${MODULE}-private-${ENVIRONMENT}"

git clone git@github.com:scottdear/acme-dns-route53.git
cd acme-dns-route53
env GOOS=linux GOARCH=amd64 go build

zip -j acme-dns-route53.zip acme-dns-route53

aws s3 cp acme-dns-route53.zip "s3://${PRIVATE_BUCKET}/${SCRIPT_PREFIX}/acme-dns-route53.zip"

cd ../cloudformation

aws cloudformation deploy --stack-name $STACK_NAME --region $REGION --capabilities CAPABILITY_NAMED_IAM \
	--template-file  "${COMPONENT}_template.yml" --no-fail-on-empty-changeset \
	--tags \
	    application=$APP \
	    customer=$CUSTOMER \
	    environment=$ENVIRONMENT \
	--parameter-overrides \
        ParentIAMStack=PARENT_IAM_STACK \
	    PrivateBucket=$PRIVATE_BUCKET \
	    ScriptBucket=$SCRIPT_BUCKET \
	    ScriptPrefix=$SCRIPT_PREFIX

