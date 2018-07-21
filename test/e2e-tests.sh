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

# Load github.com/knative/test-infra/images/prow-tests/scripts/e2e-tests.sh
[ -f /workspace/e2e-tests.sh ] \
  && source /workspace/e2e-tests.sh \
  || eval "$(docker run --entrypoint sh gcr.io/knative-tests/test-infra/prow-tests -c 'cat e2e-tests.sh')"
[ -v KNATIVE_TEST_INFRA ] || exit 1

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
  echo "Checking that build was started:"
  kubectl get build buildpack-build -oyaml
  # TODO(adrcunha): Add proper verification.
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
