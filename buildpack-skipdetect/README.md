# Buildpack - Skip Detection

This build template builds source into a container image using Cloud Foundry's
Buildpack build system with an explicitly configured buildpack.

When you execute a Buildpack on your application source, the Buildpack build
system identifies a suitable base image, and builds the application source on
top of that base image, and pushes the resulting application image to a Docker
registry under the provided name.

Unlike the buildpack build template, this build template does not autodetect
the buildpack and must be explicit configured with the desired buildpack. This
build template should be used when:

- the buildpack detection logic fails
- a custom buildpack is desired
- multi-stage buildpacks are desired

## Parameters

* **IMAGE:** The Docker image name to apply to the newly built image.
    (_required_)
* **BUILDPACK:** The name or URL for the buildpack to use (comma separated list)
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
      name: buildpack-skipdetect
      arguments:
      - name: IMAGE
        value: us.gcr.io/my-project/my-app
      - name: BUILDPACK
        value: https://github.com/my-user/my-buildpack/archive/v1.0.0.zip
```
