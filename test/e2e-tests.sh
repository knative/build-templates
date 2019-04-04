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

function run_cloudfoundry_buildpacks_test() {
  subheader "Running cloudfoundry test"
  echo "Installing template:"
  kubectl apply -f buildpacks/cf.yaml || return 1
  echo "Checking that template is installed:"
  kubectl get buildtemplates || return 1
  echo "Creating build:"
  kubectl apply -f test/build-cf.yaml || return 1
  # Wait 5s for processing to start
  sleep 5
  echo "Checking that build was started:"
  kubectl get build cf-build -oyaml
  # TODO(adrcunha): Add proper verification.
}


function run_cloud_native_buildpacks_test() {
  subheader "Running cloud native buildpacks test"
  echo "Installing template:"
  kubectl apply -f buildpacks/cnb.yaml || return 1
  echo "Checking that template is installed:"
  kubectl get buildtemplates || return 1
  echo "Creating build:"
  kubectl apply -f test/build-cnb.yaml || return 1
  # Wait 5s for processing to start
  sleep 5
  echo "Checking that build was started:"
  kubectl get build cnb-build -oyaml
  # TODO(adrcunha): Add proper verification.
}

function knative_setup() {
  header "Starting Knative Build"
  subheader "Installing Knative Build"
  echo "Installing Build from ${KNATIVE_BUILD_RELEASE}"
  kubectl apply -f ${KNATIVE_BUILD_RELEASE} || return 1
  wait_until_pods_running knative-build || return 1
}

# Script entry point.

initialize $@

header "Running tests"

# TODO(adrcunha): Add more tests.
run_cloudfoundry_buildpacks_test || fail_test
run_cloud_native_buildpacks_test || fail_test

success
