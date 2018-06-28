#!/bin/bash
#
# Copyright 2018 Google, Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A simple script to create or validate credentials to allow pushing
# built images to gcr.io.
#
# This script assumes the following environment:
#
# 1. `gcloud`, `gsutil`, 'kubectl` and `jq` installed and in $PATH.
#
# 2. gcloud configured with a default project, or the $PROJECT_ID
#    environment variable set.
#
# 3. The current `gcloud` credentials have permissions to create
#    service accounts and change IAM ACLs.
#
# 4. kubectl context configured, or appropriate flags passed on the
#    command line to select namespace and (optionally) builder service
#    account name.
#
# The script should warn if any of these preconditions cannot be met.
#
# Once all arguments are validated, this script will:
#
# 1. Provision a GCP Service Account and grant it access to all
#    existing GCR buckets.
#
# 2. Create a kubernetes secret with the appropriate metadata for
#    usage by build steps, accessible by a service account named
#    "builder" (by default).

##
## Validate environment.
##

checkBinary() {
    if ! which $1 >&/dev/null; then
        echo "Unable to locate $1, please ensure it is installed and on your \$PATH."
        exit 1
    fi
}

checkBinary gcloud
checkBinary gsutil
checkBinary jq
checkBinary kubectl

if [[ -z "${PROJECT_ID:=$(gcloud config get-value project)}" ]]; then
    echo "Could not determine project id from $PROJECT_ID or gcloud defaults."
    exit 1
fi

readonly KUBECTL_FLAGS="${1:+ -n $1}"

if ! kubectl $KUBECTL_FLAGS get sa >& /dev/null; then
    echo "Unable to read Kubernetes service accounts with 'kubectl $KUBECTL_FLAGS get sa'."
    exit 1
fi

readonly KUBE_SA=${2:-"builder"}


##
## Begin doing things
##

: ${GCP_SA_NAME:=push-image}
readonly GCP_SA=$GCP_SA_NAME@$PROJECT_ID.iam.gserviceaccount.com

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
	gcloud services enable $SERVICE.googleapis.com 2>&3 || exit 2
    fi
done

if gcloud iam service-accounts describe $GCP_SA >&/dev/null; then
    echo "Using existing service account $GCP_SA"
else
    echo "Could not find $GCP_SA, creating..."
    gcloud iam service-accounts create $GCP_SA_NAME 2>&3 || exit 2
fi

ensureIamPermission() {
    local BUCKET=$1
    gsutil iam get $BUCKET | \
	jq -e ".bindings | map(select(.role == \"roles/storage.admin\" )) | any(.members | any(. == \"serviceAccount:$GCP_SA\"))" >/dev/null
    if [ $? -eq 0 ]; then
	echo "$GCP_SA already has access to $BUCKET"
    else
	echo "Granting $GCP_SA admin access to $BUCKET"
	gsutil iam ch serviceAccount:$GCP_SA:admin $BUCKET 2>&3 || exit 2
    fi
}

# GCR objects are stored in "artifacts.$PROJECT_ID.appspot.com" buckets
# Grant access for the known regions and global bucket.
for B in artifacts us.artifacts eu.artifacts asia.artifacts; do
    ensureIamPermission gs://$B.$PROJECT_ID.appspot.com
done


# See if secrets are already loaded. If not, add them.
if [[ $(kubectl $KUBECTL_FLAGS get -o jsonpath='{.secrets[?(@.name=="gcr-creds")].name}' sa $KUBE_SA) == 'gcr-creds' ]]; then
    echo "Found serviceAccount '$KUBE_SA' with access to 'gcr-creds'"
    if [[ $(kubectl $KUBECTL_FLAGS get -o jsonpath={.type} secrets gcr-creds) == 'kubernetes.io/basic-auth' ]]; then
	echo "Secrets set up already, exiting"
	exit 0
    fi
fi
    

# Temporarily store a local JSON key for the service account.
gcloud iam service-accounts keys create image-push-key.json --iam-account $GCP_SA 2>&3 || exit 2

cat <<EOF | kubectl $KUBECTL_FLAGS apply -f - 2>&3
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $KUBE_SA
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
  username: $(echo -n "_json_key" | base64 -w 0) # Should be X2pzb25fa2V5
  password: $(base64 -w 0 image-push-key.json)
EOF

readonly EXIT=$?

rm image-push-key.json

exit $EXIT
