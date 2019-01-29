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
# built images to ECR.
#
# This script assumes the following environment:
#
# 1. `aws`, 'kubectl` and `jq` installed and in $PATH.
#
# 2. `aws` configured with a default credential.
#
# 3. The current `aws` credentials have permissions to create
#    call `ecr:GetAuthorizationToken` action, as well as other actions
#    that are required for pushing images.
#    You may use `AmazonEC2ContainerRegistryPowerUser` managed policy.
#
# 4. kubectl context configured, or appropriate flags passed on the
#    command line to select namespace and (optionally) builder service
#    account name.
#
# The script should warn if any of these preconditions cannot be met.
#
# Once all arguments are validated, this script will create a kubernetes
# secret with the appropriate metadata for usage by build steps, accessible
# by a service account named "builder" (by default).

##
## Validate environment.
##

checkBinary() {
    if ! which $1 >&/dev/null; then
        echo "Unable to locate $1, please ensure it is installed and on your \$PATH."
        exit 1
    fi
}

checkBinary aws
checkBinary jq
checkBinary kubectl

readonly KUBECTL_FLAGS="${1:+ -n $1}"

if ! kubectl $KUBECTL_FLAGS get sa >& /dev/null; then
    echo "Unable to read Kubernetes service accounts with 'kubectl $KUBECTL_FLAGS get sa'."
    exit 1
fi

readonly KUBE_SA=${2:-"builder"}


##
## Begin doing things
##

# Supress stderr, as many of the check queries will print extra output
# if the resources are not present. Keep stderr on FD 3 to allow
# printing output from explicit create commands.
exec 3>&2
exec 2>/dev/null

# The token expires in 12 hours, as of October, 2018.
DATA=$(aws ecr get-authorization-token)
if [[ $? != 0 ]]; then
    echo '`aws ecr get-authorization-token failed`'
    exit 1
fi

ENDPOINT=$(echo $DATA | jq -r .authorizationData[0].proxyEndpoint)
if [[ -z $ENDPOINT ]]; then
    echo "got empty endpoint"
    exit 1
fi
EXPIRES_AT=$(echo $DATA | jq -r .authorizationData[0].expiresAt)

TOKEN=$(echo $DATA | jq -r .authorizationData[0].authorizationToken | openssl base64 -a -A -d)
IFS=:
set -- $TOKEN
USERNAME=$1
PASSWORD=$2
unset IFS

if [[ -z $USERNAME ]]; then
    echo "got empty username"
    exit 1
fi

if [[ -z $PASSWORD ]]; then
    echo "got empty password"
    exit 1
fi

cat <<EOF | kubectl $KUBECTL_FLAGS apply -f - 2>&3
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $KUBE_SA
secrets:
- name: ecr-creds
---
apiVersion: v1
kind: Secret
metadata:
  name: ecr-creds
  annotations:
    build.knative.dev/docker-0: $ENDPOINT
type: kubernetes.io/basic-auth
data:
  username: $(echo -n $USERNAME | openssl base64 -a -A)
  password: $(echo -n $PASSWORD | openssl base64 -a -A)
EOF

readonly EXIT=$?

echo "the secret will expire at $(date -d @${EXPIRES_AT})."

exit $EXIT
