## Bazel

This build template builds source into a container image using the [Bazel build
tool](https://bazel.build), and [Bazel's container image
support](https://github.com/bazelbuild/rules_docker).

This assumes the source repo in question is using the
[`container_push`](https://github.com/bazelbuild/rules_docker/#container_push-1)
rule to build and push a container image. For example:

```
container_push(
  name = "push",
  format = "Docker", # Or "OCI"
  image = ":image",
  registry = "gcr.io",
  repository = "my-project/my-app",
  stamp = True,
)
```

This target instructs Bazel to build and push a container image containing the
application defined by the `:image` target, based on a suitable base image.

The `rules_docker` repo defines build rules to construct images for a variety of
popular programming languages, like
[Python](https://github.com/bazelbuild/rules_),
[Java](https://github.com/bazelbuild/rules_docker/#java_image),
[Go](https://github.com/bazelbuild/rules_docker/#go_image) and many more.

## Parameters

* **TARGET**: The Bazel `container_push` target to run.

## Usage

```
apiVersion: build.dev/v1alpha1
kind: Build
metadata:
  name: bazel-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      branch: master
  template:
    name: bazel
    arguments:
    - name: TARGET
      value: //path/to/build:target
```
