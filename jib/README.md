# Jib

This build template builds Java/Kotlin/Groovy/Scala source into a container image using Google's [Jib](https://github.com/GoogleContainerTools/jib) tool.

Jib works with [Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin) and [Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin) projects, and this template comes in two flavors, [`jib-maven.yaml`](./jib-maven.yaml) for Maven projects and [`jib-gradle.yaml`](./jib-gradle.yaml) for Gradle projects.

## Create the template

Maven:

```shell
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/jib/jib-maven.yaml
```

Gradle:

```shell
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/jib/jib-gradle.yaml
```

## Parameters

- **IMAGE**: The Docker image name to apply to the newly built image. (*required*)
- **DIRECTORY**: The directory in the source repository where source should be found. (*default: .*)
- **CACHE**: The name of the volume for caching Maven artifacts and base image layers (*default: empty-dir-volume*)

## ServiceAccount

Jib builds an image and pushes it to the destination defined as the **IMAGE** parameter. In order to properly authenticate to the remote container registry, the build needs to have the proper credentials. This is achieved using a build `ServiceAccount`.

For an example on how to create such a `ServiceAccount`, see the [Authentication](https://github.com/knative/docs/blob/master/build/auth.md#basic-authentication-docker) documentation page.

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
---
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
