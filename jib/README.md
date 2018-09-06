# Jib

This build template builds source into a container image using Google's
[Jib](https://github.com/GoogleContainerTools/jib) tool.

Jib provides both a
[Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin)
and a
[Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin)
plugin, and this template comes in two flavors,
[`jib-maven.yaml`](./jib-maven.yaml) and [`jib-gradle.yaml`](./jib-gradle.yaml),
to invoke those plugins to build and push container images.

## Usage (Maven)

To use the `jib-maven` template, first install the template:

```shell
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/jib/jib-maven.yaml
```

Then, define a `Build` that instantiates the template:

`jib-maven-build.yaml`:
```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: jib-maven-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: jib-maven
    arguments:
    - name: IMAGE
      value: gcr.io/my-project/my-app
```

Run the build:

```shell
kubectl apply -f jib-maven-build.yaml
```

If you would like to customize the container, configure the `jib-maven-plugin` in your `pom.xml`. 
See [setup instructions for Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#setup) for more information.

### Speed up builds

Using a persistent volume for caching can speed up your builds. To set up the cache, define a `PersistentVolumeClaim` and attach a corresponding volume to the `Build`:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: jib-maven-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: jib-maven
    arguments:
    - name: IMAGE
      value: gcr.io/my-project/my-app
    - name: CACHE
      value: persistent-cache

  volumes:
  - name: persistent-cache
    persistentVolumeClaim:
      claimName: jib-build-cache
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jib-build-cache
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 8Gi
```

This creates a `PersistentVolumeClaim` with 8Gi of storage and attaches it to the build by setting the `CACHE` argument on `spec.template.arguments`.

Future builds should now run much faster.

## Usage (Gradle)

This assumes the source repo is using the Gradle plugin, configured in
`build.gradle`:

```groovy
plugins {
  id 'com.google.cloud.tools.jib' version '0.9.10'
}
```

See [setup instructions for
Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin#setup).

To use the `jib-gradle` template, first install the template:

```shell
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/jib/jib-gradle.yaml
```

Then, define a build that instantiates the template:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: jib-gradle-build
spec:
  source:
    git:
      url: https://github.com/my-user/my-repo
      revision: master
  template:
    name: jib-gradle
    arguments:
    - name: IMAGE
      value: gcr.io/my-project/my-app
```
