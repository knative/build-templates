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
