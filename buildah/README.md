# Buildah

This build template builds source into a container image using Project Atomic's
[Buildah](https://github.com/projectatomic/buildah) build tool.

This build template uses Buildah's support for building from
[`Dockerfile`](https://docs.docker.com/engine/reference/builder/)s, using its
`buildah bud` command. This command executes the directives in the `Dockerfile`
to assemble a container image, then pushes that image to a container registry.


## Create the template

```bash
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/buildah/buildah.yaml
```

## Parameters

* **BUILDER_IMAGE:**: The name of the image containing the Buildah tool. See
  note below.
  (_required_)
* **IMAGE**: The Docker image name to apply to the newly built image.
  (_required_)
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)
* **TLSVERIFY**: Verify the TLS on the registry endpoint (for push/pull to a
  non-TLS registry) (_default:_ `true`)

## Usage

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: buildah-build-my-repo
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: buildah
    arguments:
    - name: BUILDER_IMAGE
      value: gcr.io/my-project/buildah
    - name: IMAGE
      value: gcr.io/my-project/my-app
```

In this example, the Git repo being built is expected to have a `Dockerfile` at
the root of the repository.

## Note: BUILDER_IMAGE

Currently, you must build and host the builder image yourself. This is expected
to change in the future. You can build the image from [the Dockerfile in this
directory](./Dockerfile), e.g.:

```
docker build -t <user>/buildah . && docker push <user>/buildah
```

You need a relatively recent version of Docker (>= 17.05).
You could also build the image using `buildah` itself, or `kaniko`
