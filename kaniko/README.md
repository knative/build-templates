# Kaniko

This build template builds source into a container image using Google's
[`kaniko`](https://github.com/GoogleCloudPlatform/kaniko) tool.

>kaniko doesn't depend on a Docker daemon and executes each command within a
>Dockerfile completely in userspace.  This enables building container images in
>environments that can't easily or securely run a Docker daemon, such as a
>standard Kubernetes cluster.
> - [Kaniko website](https://github.com/GoogleCloudPlatform/kaniko)

kaniko is meant to be run as an image, `gcr.io/kaniko-project/executor`. This
makes it a perfect tool to be part of a Knative build.

## Create the template

```
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/kaniko/kaniko.yaml
```

## Parameters

* **IMAGE**: The Docker image name to apply to the newly built image.
  (_required_)
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)

## ServiceAccount

kaniko builds an image and pushes it to the destination defined as a parameter.
In order to properly authenticate to the remote container registry, the build
needs to have the proper credentials. This is achieved using a build
`ServiceAccount`.

For an example on how to create such a `ServiceAccount` to push an image to
Docker hub, see the
[Authentication](https://github.com/knative/docs/blob/master/build/auth.md#basic-authentication-docker)
documentation page.

## Usage

Write a `Build` manifest and use the `template` section to refer to the kaniko
build template. Set the value of the parameters such as the destination Docker
image. Note the use of the `serviceAccountName` to push the image to a remote
registry.

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: kaniko-build
spec:
  serviceAccountName: build-bot
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
