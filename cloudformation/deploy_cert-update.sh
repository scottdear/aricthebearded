#!/bin/sh
# This script would be called by your continuous delivery application, e.g. Ansible, Octopus, etc.
# Cut paste/glue/hack/gouge - you know the drill
ENVIRONMENT="dev"
RELEASE="0.1"     # Update this to force lambda code to update when no other config changes
CUSTOMER="atb"
APP="web"
MODULE="ssl"
COMPONENT="cert-update"
REGION="us-east-1"
HOSTED_ZONE_ID="<YOUR_HOSTED_ZONE_ID>"
PARENT_IAM_STACK="${CUSTOMER}-${APP}-${MODULE}-cert-iam-${ENVIRONMENT}"
SCRIPT_PREFIX="cert_lambda/${RELEASE}" # This is where the magic of updating code only happens


STACK_NAME="${CUSTOMER}-${APP}-${MODULE}-${COMPONENT}-${ENVIRONMENT}"
PRIVATE_BUCKET="${CUSTOMER}-${APP}-${MODULE}-private-${ENVIRONMENT}"

# The buildy bits
rm -f acme-dns-route53.git
git clone git@github.com:scottdear/acme-dns-route53.git
cd acme-dns-route53
env GOOS=linux GOARCH=amd64 go build

rm -f acme-dns-route53.zip
zip -j acme-dns-route53.zip acme-dns-route53

# The deployment bits
aws s3 cp acme-dns-route53.zip "s3://${PRIVATE_BUCKET}/${SCRIPT_PREFIX}/acme-dns-route53.zip"

cd ..

aws cloudformation deploy --stack-name $STACK_NAME --region $REGION --capabilities CAPABILITY_NAMED_IAM \
	--template-file  "${COMPONENT}_template.yml" --no-fail-on-empty-changeset \
	--tags \
	    application=$APP \
	    customer=$CUSTOMER \
	    environment=$ENVIRONMENT \
	--parameter-overrides \
	    EnvironmentName=$ENVIRONMENT \
        ParentIAMStack=$PARENT_IAM_STACK \
	    PrivateBucket=$PRIVATE_BUCKET \
	    ScriptBucket=$PRIVATE_BUCKET \
	    ScriptPrefix=$SCRIPT_PREFIX \
	    HostedZoneID=$HOSTED_ZONE_ID

