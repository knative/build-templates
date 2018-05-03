# Buildpack

This build template builds source into a container image using Cloud Foundry's
Buildpack build system.

When you execute a Buildpack on your application source, the Buildpack build
system detects the source language and runtime, identifies a suitable base
image, and builds the application source on top of that base image, and pushes
the resulting application image to a Docker registry under the provided name.

## Parameters

* **IMAGE:** The Docker image name to apply to the newly built image.
    (_required_)
* **DIRECTORY:** The directory in the source repository where source
    should be found. (_default:_ `/workspace`)
* **CACHE:** The directory where data should be persistently cached
    between builds. (_default:_ `app-cache`)

## Usage

```
apiVersion: build.dev/v1alpha1
kind: Build
metadata:
  name: buildpack-build
spec:
  build:
    source:
      git:
        url: https://github.com/my-user/my-repo
        branch: master
    template:
      name: buildpack
      arguments:
      - name: IMAGE
        value: us.gcr.io/my-project/my-app
```
