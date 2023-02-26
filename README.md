# helm-charts
A collection of Helm deployment charts for Sqrl Planner.

## Environments

The following environments are supported:

- `dev` - A development environment that is used for testing and (local) development
- `staging` - A staging environment that is used for testing the deployment of the Sqrl Planner application. This
  environment should mirror the production environment as closely as possible.
- `prod` - A production environment that is used to deploy the Sqrl Planner application to the public.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- A Kubernetes cluster that is accessible from your local machine

### Helm Plugins

The following Helm plugins are required to deploy the charts in this repository:

- [helm-secrets](https://github.com/jkroepke/helm-secrets) - A plugin that helps manage secrets in Git repositories using Mozilla SOPS

See each plugin's documentation for installation instructions.

## Sqrl Planner Backend

The `sqrl-planner` chart deploys all backend services needed to support the backend of the Sqrl Planner application.
It deploys the following resources:

- A MongoDB deployment that provides a shared MongoDB instancee accessible by the microservices in the cluster
- A `sqrl-server` deployment that runs the Sqrl Planner backend server
- A `gator-app` deployment that runs the Gator data aggregation application and a `data-pull` cron job that pulls and
  syncs data from tracked datasets on a schedule.

### Configuration and Secrets

Multiple configuration and secrets files are made available for configuring the backend services depending on the
deployment environment. The `values.yaml` file provides default values shared betweeen all environments. Each
environment has its own `values.<environment>.yaml` file that overrides the default values.

Similarly, each environment has its own `secrets.<environment>.yaml` file that contains the secrets for the
environment. These secrets are encrypted using the `helm secrets` plugin to ensure that they are safely stored in
the repository.

Note that the `secrets.dev.yaml` file is not encrypted as it is an **example** file that is only used for local
development.

### Deploying

From the root directory of the repository, run the following command to deploy the backend services to a specific
environment:
```bash

$ helm install sqrl-planner ./sqrl-planner -f sqrl-planner/environments/values.<env>.yaml -f sqrl-planner/environments/secrets.<env>.dec.yaml

```
where `<env>` is the environment to deploy to (one of `dev`, `staging`, or `prod`). You'll need to decrypt the secrets file (to obtain a `.dec.yaml` file) before running this command. To do so, run the following command:
```bash

$ helm secrets dec sqrl-planner/environments/secrets.<env>.yaml

```
which will decrypt the secrets file and store the decrypted version in a file of the same name with the `.dec.yaml` extension. Note that for the `dev` environment, the secrets file is not encrypted so you can just use the `secrets.dev.yaml` file directly.

### Changing MongoDB Credentials

Due to MongoDB weirdness, if you're re-deploying the sqrl-planner chart with updated MongoDB credentials, the credentials will not be updated (as they are stored in a volume that is not updated). To fix this, there are two options:

1. Delete the MongoDB persistent volume claim and re-deploy the chart. To do so, run the following command:
```bash
$ kubectl delete pvc sqrl-planner-mongodb
```
This will delete all data stored in the MongoDB database, so only do this if you don't care about the data. In any case, you should back up the data before doing this.

2. Manually update the MongoDB credentials. To do so, start by executing a shell in the MongoDB pod:
```bash
$ kubectl exec --stdin --tty sqrl-planner-mongodb-<pod-id> -- /bin/bash
```
where `<pod-id>` is the ID of the MongoDB pod, which you can find by running ```kubectl get pods```.

If you'd like to add a new user or change the password for an existing user, run the following command to connect to the MongoDB database and change credentials:
```bash
$ mongo -u <username> -p <password> --authenticationDatabase admin
# Create a new user that can read and write to a database
> db.createUser({ user: "foo", pwd: "bar", roles: [ { role: "readWrite", db: "some-db" } ] })
# Change the password for an existing user
> db.changeUserPassword(username, password)
```
where `<username>` and `<password>` are the current MongoDB credentials. Once you've changed the credentials, exit the MongoDB shell and the pod shell. Then, re-deploy the chart. Changing the root username and/or password is a bit more complicated. You can find instructions [here](https://docs.bitnami.com/aws/infrastructure/mongodb/administration/change-reset-password/).
