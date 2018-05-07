# Kaniko

This build template builds source into a container image using Google's
[`kaniko`](https://github.com/GoogleCloudPlatform/kaniko) tool.

Kaniko understands the
[`Dockerfile`](https://docs.docker.com/engine/reference/builder/) format used by
Docker to build container images using `docker build`, but is able to build
images without requiring access to the Docker daemon socket, which gives
expansive power to your build system and is not secure to run inside a
Kubernetes cluster.

Instead, Kaniko executes directives in the `Dockerfile` inside a container,
and takes snapshots and uploads layers to the container registry after each
directive, without requiring access to the daemon socket.

## Parameters

* **IMAGE**: The Docker image name to apply to the newly built image.
  (_required_)
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)

## Usage

```
apiVersion: build.dev/v1alpha1
kind: Build
metadata:
  name: kaniko-build
spec:
  build:
    source:
      git:
        url: https://github.com/my-user/my-repo
        branch: master
    template:
      name: kaniko
      arguments:
      - name: IMAGE
        value: us.gcr.io/my-project/my-app
```

In this example, the Git repo being built is expected to have a `Dockerfile` at
the root of the repository.
