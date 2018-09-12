# Buildpack V3

This build template builds source into a container image using [Cloud Native Buildpacks](https://buildpacks.io).

The Cloud Native Buildpacks website describes v3 buildpacks as:

> ... pluggable, modular tools that translate source code into container-ready artifacts
> such as OCI images. They replace Dockerfiles in the app development lifecycle with a higher level
> of abstraction. ...  Cloud Native Buildpacks embrace modern container standards, such as the OCI
> image format. They take advantage of the latest capabilities of these standards, such as remote
> image layer rebasing on Docker API v2 registries.

**Note**: This Buildpack v3 template is distinct from Buildpack.

## Create the template

```
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/buildpack_v3/template.yaml
```

## Parameters

* **IMAGE:** The Docker image name to apply to the newly built image.
    (_required_)
* **RUN_IMAGE:** The run image buildpacks will use as the base for IMAGE.
* **USE_CREDENTIAL_HELPERS:** Use Docker credential helpers. Set to `"true"` or `"false"` as string values.

## Usage

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: buildpackv3-example-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: buildpackv3
    arguments:
    - name: IMAGE
      value: us.gcr.io/my-project/my-app
```
