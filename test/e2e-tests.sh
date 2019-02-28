#!/bin/bash

# Copyright 2018 The Knative Authors
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

# This script runs the end-to-end tests for build templates.

# If you already have a Knative Build cluster setup and kubectl pointing
# to it, call this script with the --run-tests arguments and it will use
# the cluster and run the tests.

# Calling this script without arguments will create a new cluster in
# project $PROJECT_ID, run the tests and delete the cluster.

source $(dirname $0)/../vendor/github.com/knative/test-infra/scripts/e2e-tests.sh

# Helper functions.

function run_buildpack_test() {
  subheader "Running buildpack test"
  echo "Installing template:"
  kubectl apply -f buildpack/buildpack.yaml || return 1
  echo "Checking that template is installed:"
  kubectl get buildtemplates || return 1
  echo "Creating build:"
  kubectl apply -f test/build-buildpack.yaml || return 1
  # Wait 5s for processing to start
  sleep 5
  echo "Checking that build was successed:"
  for i in {1..100};do
     kubectl get build buildpack-build -o 'jsonpath={.status.conditions[?(@.type=="Succeeded")].status}'  1>/dev/null 2>&1
     if [ $? -ne 1 ]; then
      break
     fi
     echo "The build was successed."
     sleep 2
  done
}

# Script entry point.

initialize $@

# Install Knative Build if not using an existing cluster
if (( ! USING_EXISTING_CLUSTER )); then
  start_latest_knative_build || fail_test
fi

header "Running tests"

# TODO(adrcunha): Add more tests.
run_buildpack_test || fail_test

success
