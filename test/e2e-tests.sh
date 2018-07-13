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

[ -f /library.sh ] && source /library.sh || eval "$(docker run --entrypoint sh gcr.io/knative-tests/test-infra/prow-tests -c 'cat library.sh')"
[ -v KNATIVE_TEST_INFRA ] || exit 1

# Test cluster parameters and location of test files
readonly E2E_CLUSTER_NAME=bldtpl-e2e-cluster${BUILD_NUMBER}
readonly E2E_NETWORK_NAME=bldtpl-e2e-net${BUILD_NUMBER}
readonly E2E_CLUSTER_ZONE=us-central1-a
readonly E2E_CLUSTER_NODES=2
readonly E2E_CLUSTER_MACHINE=n1-standard-2
readonly TEST_RESULT_FILE=/tmp/bldtpl-e2e-result

# This script.
readonly SCRIPT_CANONICAL_PATH="$(readlink -f ${BASH_SOURCE})"

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

function exit_if_test_failed() {
  [[ $? -eq 0 ]] && return 0
  [[ -n $1 ]] && echo "ERROR: $1"
  echo "***************************************"
  echo "***           TEST FAILED           ***"
  echo "***    Start of information dump    ***"
  echo "***************************************"
  echo ">>> All resources:"
  kubectl get all --all-namespaces
  echo "***************************************"
  echo "***           TEST FAILED           ***"
  echo "***     End of information dump     ***"
  echo "***************************************"
  exit 1
}

# Script entry point.

cd ${REPO_ROOT_DIR}

# Show help if bad arguments are passed.
if [[ -n $1 && $1 != "--run-tests" ]]; then
  echo "usage: $0 [--run-tests]"
  exit 1
fi

# No argument provided, create the test cluster.

if [[ -z $1 ]]; then
  header "Creating test cluster"
  # Smallest cluster required to run the end-to-end-tests
  CLUSTER_CREATION_ARGS=(
    --gke-create-args="--enable-autoscaling --min-nodes=1 --max-nodes=${E2E_CLUSTER_NODES} --scopes=cloud-platform"
    --gke-shape={\"default\":{\"Nodes\":${E2E_CLUSTER_NODES}\,\"MachineType\":\"${E2E_CLUSTER_MACHINE}\"}}
    --provider=gke
    --deployment=gke
    --gcp-node-image=cos
    --cluster="${E2E_CLUSTER_NAME}"
    --gcp-zone="${E2E_CLUSTER_ZONE}"
    --gcp-network="${E2E_NETWORK_NAME}"
    --gke-environment=prod
  )
  if (( ! IS_PROW )); then
    CLUSTER_CREATION_ARGS+=(--gcp-project=${PROJECT_ID:?"PROJECT_ID must be set to the GCP project where the tests are run."})
  fi
  # SSH keys are not used, but kubetest checks for their existence.
  # Touch them so if they don't exist, empty files are create to satisfy the check.
  touch $HOME/.ssh/google_compute_engine.pub
  touch $HOME/.ssh/google_compute_engine
  # Assume test failed (see more details at the end of this script).
  echo -n "1"> ${TEST_RESULT_FILE}
  kubetest "${CLUSTER_CREATION_ARGS[@]}" \
    --up \
    --down \
    --extract "gke-${GKE_VERSION}" \
    --test-cmd "${SCRIPT_CANONICAL_PATH}" \
    --test-cmd-args --run-tests
  result="$(cat ${TEST_RESULT_FILE})"
  echo "Test result code is $result"
  exit $result
fi

# --run-tests passed as first argument, run the tests.

# Install Knative Build if not using an existing cluster
if (( IS_PROW )) || [[ -n ${PROJECT_ID} ]]; then
  # Make sure we're in the default namespace. Currently kubetest switches to
  # test-pods namespace when creating the cluster.
  kubectl config set-context \
    $(kubectl config current-context) --namespace=default

  header "Starting Knative Build"
  acquire_cluster_admin_role \
    $(gcloud config get-value core/account) ${E2E_CLUSTER_NAME} ${E2E_CLUSTER_ZONE}
  subheader "Installing Istio"
  kubectl apply -f ${KNATIVE_ISTIO_YAML}
  wait_until_pods_running istio-system
  exit_if_test_failed "could not install Istio"

  subheader "Installing Knative Build"
  kubectl apply -f ${KNATIVE_BUILD_RELEASE}
  exit_if_test_failed "could not install Knative Build"

  wait_until_pods_running knative-build || exit_if_test_failed
fi

header "Running tests"
run_buildpack_test
exit_if_test_failed
# TODO(adrcunha): Add more tests.

# kubetest teardown might fail and thus incorrectly report failure of the
# script, even if the tests pass.
# We store the real test result to return it later, ignoring any teardown
# failure in kubetest.
# TODO(adrcunha): Get rid of this workaround.
echo -n "0"> ${TEST_RESULT_FILE}
echo "**************************************"
echo "***        ALL TESTS PASSED        ***"
echo "**************************************"
exit 0
