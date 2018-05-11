# Elafros Build Templates

This repository contains a library of `BuildTemplate` resources which are
designed to be reusable by many applications.

## Using Build Templates

First, install a build template onto your cluster:

```
$ kubectl apply -f buildpack.yaml
buildtemplate "buildpack" created
```

You can see which build templates are installed using `kubectl` as well:

```
$ kubectl get buildtemplates
NAME       AGE
buildpack  3s
```

With the build template installed, you can define a build that uses that
template, being sure to provide values for required parameters:

```
apiVersion: build.dev/v1alpha1
kind: Build
metadata:
  name: buildpack-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      branch: master
  template:
  name: buildpack
  arguments:
  - name: IMAGE
    value: us.gcr.io/my-project/my-app
```

Next, create the build you defined:

```
$ kubectl apply -f build.yaml
build "buildpack-build" created
```

You can check the status of the build using `kubectl`:

```
$ kubectl get build buildpack-build -oyaml
```
