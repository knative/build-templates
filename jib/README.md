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

This assumes the source repo is using the Maven plugin, configured in your
`pom.xml`:

```
<plugin>
  <groupId>com.google.cloud.tools</groupId>
  <artifactId>jib-maven-plugin</artifactId>
  <version>0.9.8</version>
</plugin>
```

See [setup instructions for
Maven](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin#setup)
for more information.

To use the `jib-maven` template, first install the template:

```
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/jib/jib-maven.yaml
```

Then, define a build that instantiates the template:

```
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

## Usage (Gradle)

This assumes the source repo is using the Gradle plugin, configured in
`build.gradle`:

```
plugins {
  id 'com.google.cloud.tools.jib' version '0.9.8'
}
```

See [setup instructions for
Gradle](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin#setup).

To use the `jib-gradle` template, first install the template:

```
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/jib/jib-gradle.yaml
```

Then, define a build that instantiates the template:

```
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
