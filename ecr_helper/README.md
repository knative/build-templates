# ECR Helper

This script loads your Amazon ECR credentials into a secret in your current kubernetes cluster and namespace.

By default, the following resources will be provisioned:

* A Kubernetes service account (named `builder` by default) with secrets (`ecr-creds`) to enable pushing to ECR.


To use, simply add a `serviceAccountName: builder` entry to your build definition

```yaml:
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: mybuild
spec:
  serviceAccountName: builder
  source: ...
  template: ...
```

## Usage

At least, you need to be allowed to call `ecr:GetAuthorizationToken` action, as well as other actions that are required for pushing images.
You should use [`AmazonEC2ContainerRegistryPowerUser` managed policy](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ecr_managed_policies.html).

```shell
aws configure
ecr_helper/helper.sh
```

Optionally, `helper.sh` accepts two positional arguments to specify
the namespace and kubernetes service account used:

```shell
ecr_helper/helper.sh $MY_NAMESPACE builder-serviceaccount
```

This will output a log of operations performed or skipped:

```
serviceaccount "builder" created
secret "ecr-creds" created
the secret will expire at Thu Oct  4 07:04:09 JST 2018.
```

NOTE: As of October 2018, you need to rerun `helper.sh` every 12 hours, because the credential expires every 12 hours.
