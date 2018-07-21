# Buildpack

This build template builds source into a container image using Cloud Foundry's
Buildpack build system.

When you execute a Buildpack on your application source, the Buildpack build
system detects the source language and runtime, identifies a suitable base
image, and builds the application source on top of that base image, and pushes
the resulting application image to a Docker registry under the provided name.

## Create the template

```
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/buildpack/buildpack.yaml
```

## Parameters

* **IMAGE:** The Docker image name to apply to the newly built image.
    (_required_)
* **BUILDPACK_ORDER:** A comma separated list of names or URLs for the
    buildpacks to use. Each buildpack is applied in order. (_default:_ `""`)
* **SKIP_DETECT:** By default, the first buildpack to match is used. If true,
    detection is skipped and each buildpack contributes in order.
    (_default:_ `"false"`)
* **DIRECTORY:** The directory in the source repository where source
    should be found. (_default:_ `/workspace`)
* **CACHE:** The directory where data should be persistently cached
    between builds. (_default:_ `app-cache`)

## Usage

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: buildpack-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: buildpack
    arguments:
    - name: IMAGE
      value: us.gcr.io/my-project/my-app
```
