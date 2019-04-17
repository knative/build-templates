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
* **BUILDKIT_CLIENT_IMAGE**: BuildKit client image (_default:_`moby/buildkit:vX.Y.Z-rootless@sha256:...`)
* **BUILDKIT_DAEMON_ADDRESS**: BuildKit daemon address  (_default:_`tcp://buildkitd:1234`)

## Set up

### Step 0: Deploy BuildKit daemon

First, you need to deploy BuildKit daemon as follows:

```console
kubectl apply -f 0-buildkitd.yaml
```

The default image is set to `moby/buildkit:vX.Y.Z-rootless@sha256:...` (see YAML files for the actual revision), but you can also build the image manually as follows:

```console
git clone https://github.com/moby/buildkit.git
cd buildkit
DOCKER_BUILDKIT=1 docker build --target rootless -f hack/dockerfiles/test.buildkit.Dockerfile .
```

If you are using Debian (not Ubuntu) or Arch Linux kernel on each of kubelet nodes, `sudo sh -c "echo 1 > /proc/sys/kernel/unprivileged_userns_clone"` is required.
See the content of [`0-buildkitd.yaml`](./0-buildkitd.yaml) for further information about rootless mode.

You can also use "rootful" BuildKit image (`moby/buildkit:vX.Y.Z`) at your own risk.

### Step 1: Register BuildKit build template

```console
kubectl apply -f 1-buildtemplate.yaml
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
