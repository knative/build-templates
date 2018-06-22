# GCR Helper

This script provisions (or verifies) a GCP service account with
permissions to push images to GCR, and loads the credentials into a
secret in your current kubernetes cluster and namespace.


## Usage

```shell
# Usage assumes that the user has IAM Owner permissions for the project.
gcloud config set core/project $PROJECT_ID
gcr_helper.sh
```

This will output a log of operations performed or skipped:

```
Enabling iam.googleapis.com...
Waiting for async operation operations/tmo-acf.11f13a3e-5b13-4a5e-91f0-9814e76708a3 to complete...
Operation finished successfully. The following command can describe the Operation details:
 gcloud services operations describe operations/tmo-acf.11f13a3e-5b13-4a5e-91f0-9814e76708a3
containerregistry.googleapis.com already enabled
Could not find push-image@$PROJECT_ID.iam.gserviceaccount.com, creating...
Created service account [push-image].
Granting push-image@$PROJECT_ID.iam.gserviceaccount.com admin access to gs://us.artifacts.$PROJECT_ID.appspot.com
push-image@$PROJECT_ID.iam.gserviceaccount.com already has access to gs://us.artifacts.$PROJECT_ID.appspot.com
push-image@$PROJECT_ID.iam.gserviceaccount.com already has access to gs://eu.artifacts.$PROJECT_ID.appspot.com
push-image@$PROJECT_ID.iam.gserviceaccount.com already has access to gs://asia.artifacts.$PROJECT_ID.appspot.com
Found serviceAccount 'builder' with access to 'gcr-creds'
created key [462561f97c7fc567f167b4cef8e9bfedde992143] of type [json] as [image-push-key.json] for [push-image@$PROJECT_ID.iam.gserviceaccount.com]
serviceaccount "builder" configured
secret "gcr-creds" created
```

To use, simply add a `serviceAccountName: builder` entry to your build definition

```yaml:
apiVersion: build.dev/v1alpha1
kind: Build
metadata:
  name: mybuild
spec:
  serviceAccountName: builder
  source: ...
  template: ...
```
