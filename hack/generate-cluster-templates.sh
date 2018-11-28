#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

build_templates=($(egrep -ir --include="*.yaml" "kind: BuildTemplate" * | sed -e "s/:.*//"))
for namespace_template in "${build_templates[@]}"; do
  cluster_template=$(echo $namespace_template | sed -e "s%\.yaml%-cluster.yaml%")
  cat $namespace_template | sed -e "s%kind: BuildTemplate%kind: ClusterBuildTemplate%" > $cluster_template
done