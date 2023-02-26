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

## Sqrl Planner Backend

The `sqrl-planner` chart deploys all backend services needed to support the backend of the Sqrl Planner application.
It deploys the following resources:

- A MongoDB deployment that provides a shared MongoDB instancee accessible by the microservices in the cluster
- A `sqrl-server` deployment that runs the Sqrl Planner backend server
- A `gator-app` deployment that runs the Gator data aggregation application

### Configuration and Secrets

Multiple configuration and secrets files are made available for configuring the backend services depending on the
deployment environment. The `values.yaml` file provides default values shared betweeen all environments. Each
environment has its own `values.<environment>.yaml` file that overrides the default values.

Similarly, each environment has its own `secrets.<environment>.yaml` file that contains the secrets for the
environment. These secrets are encrypted using the `helm secrets` plugin to ensure that they are safeley stored in
the repository.

Note that the `secrets.dev.yaml` file is not encrypted as it is an **example** file that is only used for local
development.

### Deploying

From the root directory of the repository, run the following command to deploy the backend services to a specific
environment:
```bash

$ helm install sqrl-planner ./sqrl-planner -f environments/values.<env>.yaml -f environments/secrets.<env>.yaml

```
where `<env>` is the environment to deploy to (one of `dev`, `staging`, or `prod`).
