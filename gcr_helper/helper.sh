#!/bin/bash
#
# A simple script to create or 


PROJECT_ID=$(gcloud config get-value project)
ACCOUNT_NAME=push-image
SERVICE_ACCOUNT=$ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com

# Supress stderr, as many of the check queries will print extra output
# if the resources are not present. Keep stderr on FD 3 to allow
# printing output from explicit create commands.
exec 3>&2
exec 2>/dev/null

# Enable IAM and container registry if needed
for SERVICE in iam containerregistry; do
    gcloud services list | grep -q $SERVICE.googleapis.com
    if [ $? -eq 0 ]; then
	echo "$SERVICE.googleapis.com already enabled"
    else
	echo "Enabling $SERVICE.googleapis.com..."
	gcloud services enable $SERVICE.googleapis.com 2>&3
    fi
done

SA=$(gcloud iam service-accounts describe $SERVICE_ACCOUNT)
if [ $? -eq 0 ]; then
    echo "Using existing service account $SERVICE_ACCOUNT"
else
    echo "Could not find $SERVICE_ACCOUNT, creating..."
    gcloud iam service-accounts create $ACCOUNT_NAME 2>&3
    SA=$(gcloud iam service-accounts describe $SERVICE_ACCOUNT)
fi

ensureIamPermission() {
    BUCKET=$1
    gsutil iam get $BUCKET | \
	jq -e ".bindings | map(select(.role == \"roles/storage.admin\" )) | any(.members | any(. == \"serviceAccount:$SERVICE_ACCOUNT\"))" >/dev/null
    if [ $? -eq 0 ]; then
	echo "$SERVICE_ACCOUNT already has access to $BUCKET"
    else
	echo "Granting $SERVICE_ACCOUNT admin access to $BUCKET"
	gsutil iam ch serviceAccount:$SERVICE_ACCOUNT:admin $BUCKET 2>&3
    fi
}

# GCR objects are stored in "artifacts.$PROJECT_ID.appspot.com" buckets
# Grant access for the known regions and global bucket.
for B in artifacts us.artifacts eu.artifacts asia.artifacts; do
    ensureIamPermission gs://$B.$PROJECT_ID.appspot.com
done


## See if secrets are already loaded. If not, add them.
if [[ $(kubectl get -o jsonpath='{.secrets[?(@.name=="gcr-creds")].name}' sa builder) == 'gcr-creds' ]]; then
    echo "Found serviceAccount 'builder' with access to 'gcr-creds'"
    if [[ $(kubectl get -o jsonpath={.type} secrets gcr-creds) == 'kubernetes.io/basic-auth' ]]; then
	echo "Secrets set up already, exiting"
	exit 0
    fi
fi
    

# Temporarily store a local JSON key for the service account.
gcloud iam service-accounts keys create image-push-key.json --iam-account $SERVICE_ACCOUNT 2>&3

cat <<EOF | kubectl apply -f - 2>&3
apiVersion: v1
kind: ServiceAccount
metadata:
  name: builder
secrets:
- name: gcr-creds
---
apiVersion: v1
kind: Secret
metadata:
  name: gcr-creds
  annotations:
    build.dev/docker-0: https://us.gcr.io
    build.dev/docker-1: https://gcr.io
    build.dev/docker-2: https://eu.gcr.io
    build.dev/docker-3: https://asia.gcr.io
type: kubernetes.io/basic-auth
data:
  username: X2pzb25fa2V5  # _json_key, base64 encoded
  password: $(base64 -w 0 image-push-key.json)
EOF

rm image-push-key.json
