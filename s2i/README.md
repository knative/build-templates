# Source-to-image (a.k.a. `s2i`)

This build template builds source into a container image using
Openshift [`source-to-image`](https://github.com/openshift/source-to-image)
build tool.

> Source-to-Image (S2I) is a toolkit and workflow for building
> reproducible Docker images from source code. S2I produces
> ready-to-run images by injecting source code into a Docker container
> and letting the container prepare that source code for execution. By
> creating self-assembling builder images, you can version and control
> your build environments exactly like you use Docker images to
> version your runtime environments.

This build template uses `s2i` support for generating a `Dockerfile`
and a build context, that can be later build by [`buildah`](https://github.com/containers/buildah).
This allows user to have, *somewhat*, similar builds as Openshift
[`Source-to-Image` build stragety](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/builds_and_image_streams.html#source-build)

## Parameters

* **BUILDER_IMAGE** : The name of the image containing the `s2i` tool
* **BUILDAH_BUILDER_IMAGE** : The name of the image containing the
  `buildah` tool (_default:_ docker.io/vdemeester/buildah-builder)
* **IMAGE**: The Docker image name to apply to the newly built image.
  (_required_)
* **BASE_IMAGE**: The base image to use with `s2i` to build from.
  (_required_)
* **TLSVERIFY**: Verify the TLS on the registry endpoint (for push/pull to a
  non-TLS registry) (_default:_ `true`)

## Usage

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: s2i-build-my-repo
spec:
  source:
    git:
      url: https://github.com/OpenShiftDemos/os-sample-python # replace with your s2i-compatible repository
      revision: master
  template:
    name: s2i
    arguments:
    - name: BASE_IMAGE
      value: centos/python-36-centos7
    - name: IMAGE
      value: gcr.io/my-project/my-app
```

In this example, the Git repo being built is expected to be a python project

## Note: *_BUILDER_IMAGE

Currently, you must build and host the builder image yourself. This is expected
to change in the future. You can build the images (for `s2i`
and `buildah`) from the `Dockerfile`(s)
([`Dockerfile`](./Dockerfile) and
[`../buildah/Dockerfile`](../buildah/Dockerfile)), e.g.:

```
docker build -t s2i -f Dockerfile . && docker push s2i
```
