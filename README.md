# Knative Build Templates

This repository contains a library of
`BuildTemplate` [resources](https://github.com/knative/docs/blob/master/docs/build/build-templates.md) which are designed to be reusable by many applications.

Each build template is in a separate directory along with a README.md and a Kubernetes manifest, so you can choose which build templates to install on your cluster.

## Build Templates Kinds

There are two kinds of build templates:

 1. `ClusterBuildTemplates` with a Cluster scope
 2. `BuildTemplates` with a Namespace scope

 A default kind of `BuildTemplate` is used if the field `kind` is not set.

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

*OR*

```
$ kubectl get clusterbuildtemplates
NAME        AGE
buildpack   9s
```

With the build template installed, you can define a build that uses that
template, being sure to provide values for required parameters:

```
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: buildpack-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: buildpack
    kind: BuildTemplate # (or ClusterBuildTemplate)
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

## Contributing and Support

If you want to contribute to this repository, please see our [contributing](./CONTRIBUTING.md) guidelines.

If you are looking for support, enter an [issue](https://github.com/knative/build-templates/issues/new) or join our [Slack workspace](https://knative.slack.com/)
