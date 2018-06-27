# FTL

This build template builds source into a container image using the "FTL" model
for quickly and efficiently building container images from source.

Currently the only supported source language in this repo is NodeJS. More
languages will be supported in the future.

## Parameters

* **IMAGE**: The Docker image name to apply to the newly built image.
  (_required_)
**DIRECTORY:** The directory in the source repository where source
  should be found. (_default:_ `/workspace`)

## Usage

```
apiVersion: build.dev/v1alpha1
kind: Build
metadata:
  name: node-ftl-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      branch: master
  template:
    name: node-ftl
    arguments:
    - name: IMAGE
      value: us.gcr.io/my-project/my-app
```
