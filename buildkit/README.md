# BuildKit

This build template builds source into a container image using [Moby BuildKit](https://github.com/moby/buildkit).

Rootless mode is used by default.

## Parameters

* **IMAGE**: The Docker image name to apply to the newly built image.
  (_required_)
* **DOCKERFILE**: The path to the `Dockerfile` to execute (_default:_
  `./Dockerfile`)
* **PUSH**: Whether to push or not (_default:_`true`)
* **DIRECTORY**: Workspace directory (_default:_`/workspace`)
* **BUILDKIT_CLIENT_IMAGE**: BuildKit client image (_default:_`moby/buildkit:v0.3.1-rootless@sha256:2407cc7f24e154a7b699979c7ced886805cac67920169dcebcca9166493ee2b6`)
* **BUILDKIT_DAEMON_ADDRESS**: BuildKit daemon address  (_default:_`tcp://buildkitd:1234`)

## Set up

### Step 0: Deploy BuildKit daemon

First, you need to deploy BuildKit daemon as follows:

```console
$ kubectl apply -f 0-buildkitd.yaml
```

The default image is set to `moby/buildkit:v0.3.1-rootless@sha256:2407cc7f24e154a7b699979c7ced886805cac67920169dcebcca9166493ee2b6`, but you can also build the image manually as follows:

```console
$ git clone https://github.com/moby/buildkit.git
$ cd buildkit
$ git checkout v0.3.1
$ git rev-parse HEAD
867bcd343f06228862a33643ae16e55c6a1e5fdb
$ DOCKER_BUILDKIT=1 docker build --target rootless -f hack/dockerfiles/test.buildkit.Dockerfile .
```

Although the BuildKit daemon runs as an unprivileged user (UID=1000), on Kubernetes prior to v1.12, you need to set `securityContext.privileged` to `true` in order to allow runc in the container to mount `/proc`. See [@jessfraz's blog](https://blog.jessfraz.com/post/building-container-images-securely-on-kubernetes/) for further information.
On Kubernetes v1.12 and later, you may use [`securityContext.procMount`](https://github.com/kubernetes/kubernetes/commit/39004e852bb523d0497343705ee2bf42b4e9c3e3) instead of `securityContext.privileged`.
To use `securityContext.procMount`, either Docker v18.06, containerd v1.2, or CRI-O v1.12 is also required as the CRI runtime.

If you are using Debian (not Ubuntu) or Arch Linux kernel on each of kubelet nodes, `sudo sh -c "echo 1 > /proc/sys/kernel/unprivileged_userns_clone"` is required.

You can also use "rootful" BuildKit image (`moby/buildkit:v0.3.1`) at your own risk.

### Step 1: Register BuildKit build template

```console
$ kubectl apply -f 1-buildtemplate.yaml
```

## Usage

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: buildkit-build-my-repo
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: buildkit
    arguments:
    - name: IMAGE
      value: gcr.io/my-project/my-app
```

In this example, the Git repo being built is expected to have a `Dockerfile` at
the root of the repository.
