# makisu

This build template builds source into a container image using uber's
[`makisu`](https://github.com/uber/makisu) tool.

>Makisu is a fast and flexible Docker image build tool designed for unprivileged
>containerized environments such as Mesos or Kubernetes.
> - [makisu website](https://github.com/uber/makisu)

makisu is meant to be run as an image, `gcr.io/makisu-project/makisu`. This
makes it a perfect tool to be part of a Knative build.

## Create the registry configuration

makisu uses a [registry configuration](https://github.com/uber/makisu/blob/master/docs/REGISTRY.md) which should be stored as a secret in Kubernetes. Adjust the `registry.yaml` in this diretroy to contain your user and password for the Docker hub (or configure a different [registry](https://github.com/uber/makisu/blob/master/docs/REGISTRY.md#examples)). Keep in mind that the secret must exist in the same namespace as the build runs.:

```bash
kubectl --namespace default create secret generic docker-registry-config --from-file=./registry.yaml
```

## Create the template

```
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/makisu/makisu.yaml
```

## Parameters

* **IMAGE**: The Docker image name to apply to the newly built image.
  (_required_)
* **CONTEXTPATH**: The path to the build context (_default:_
  `/workspace`)
* **PUSH_REGISTRY**: The Registry to push the image to (_default:_
  `index.docker.io`)
* **REGISTRY_SECRET**: Secret containing information about the used regsitry (_default:_
  `docker-registry-config`) **This Parameter currently doesn't work: https://github.com/knative/build/pull/550**

## Usage

Write a `Build` manifest and use the `template` section to refer to the makisu
build template. Set the value of the parameters such as the destination Docker
image.

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: makisu-build
spec:
  serviceAccountName: makisu-build
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: makisu
    arguments:
    - name: IMAGE
      value: us.gcr.io/my-project/my-app
```

In this example, the Git repo being built is expected to have a `Dockerfile` at
the root of the repository.
