# Scaffolding for terraform deployment in AWS

This repository includes some utils to speed up the deployment of a Terraform stack in AWS.
It supports:

* Deployments in different environments.
* Managing of docker images, including building and pushing to an ECR repo

# Components

* `Makefile`: file with some frequent utils to help you with Docker build/push and Terraform deployments. More about
  this in the section [Makefile commands](#makefile-utils).
* `.env`: the variables in this .env will be available in Makefile. For instance, if you need to use an AWS profile by
  default you can define it here `AWS_PROFILE=...`. More info about what variables can
  in [Makefile commands](#makefile-utils).
* `deployments`: contains the terraform code to deploy a stack. Typically:

```
deployments/
└── <stack>
    ├── main.tf
    ├── output.tf
    ├── variable.tf
    └── versions.tf
```

* `environments`: in this folder, you place the configuration for a given app and a given environment. This
  configuration is typically a backend.conf file, which must contain the bucket and dynamo db references to be used to
  store the state and the lock.

```
environments/
└── <env>
    └── <stack>
        ├── backend.conf: S3 bucket/Dynamodb table backend configuration
        └── terraform.tfvars: variables
```

For security reasons, you don't commit this values to your repository.

* `modules`: contains custom modules that you can use in your deployments. If you use the `Makefile` to deploy your
  stacks, you can access to this modules from your deployment code as "./modules/my-module".
* `docker`: place here folders with the repo name. Inside, follow the structure:

```
docker/
└── <image-name>:
    ├── Dockerfile
    ├── requirements.txt: contains python dependencies
    ├── src: contains the actual code to run in the lambda
    │   └── index.py
    └── test_events: contains test events in case that you want to debug/test locally your function.
        └── example.json

```

## Quickstart

In this example we:

1. Set up an environment
2. Create and deploy a `setup` stack with ECR repositories
3. Build and push a docker image for lambda
4. Create and deploy an `app` stack with ECR repositories

### Set up an environment
 1. Create a .env file, even if it's not needed. The `Makefile` needs it.

```bash
mv template.env .env
```

### Create and deploy a `setup` stack with ECR repositories

 2. Create the files `backend.conf` and `terraform.tfvars` for the right app and environment.
In `environments/sandbox/app` you have templates for those.

An example for `sandbox/app`: 
```bash 
cp environments/sandbox/app/template.backend.conf environments/sandbox/setup/backend.conf
cp environments/sandbox/app/template.terraform.tfvars environments/sandbox/setup/terraform.tfvars
```
Add the missing values in the files. 

```bash
make tf/init TARGET=setup ENV=sandbox 
```

```bash
make tf/apply TARGET=setup ENV=sandbox 
```

### Build and push a docker image for lambda

```bash
make docker/build TARGET=setup && make docker/push TARGET=setup
```

### Create and deploy an `app` stack with ECR repositories

```bash
make tf/init TARGET=app ENV=sandbox 
```

```bash
make tf/apply TARGET=app ENV=sandbox 
```


## Makefile utils

You can configure in `.env` the `AWS_PROFILE` that you want to use by default.

### AWS

Utils to login in AWS

*
    * cmd: `aws/login`
    * descr: login in AWS using SSO

### ECR

Utils to login and create repositories in AWS ECR

*
    * cmd: `aws/ecr/login`
    * descr: login in ECR
    * input:
        * AWS_ACCOUNT_ID [opt]: : AWS Account ID for the ECR repo. If not provided, looks for the default according to
          the profile configured.
        * AWS_REGION [opt]: AWS region for the ECR repo. If not provided, looks for the default according to the profile
          configured.
*
    * cmd: `aws/ecr/create`
    * descr: create a private repository from the command line
    * input:
        * TARGET: name of the repository, it is recommended that is matches with folder name used to store your
          Dockerfile.
    * eg: `make aws/ecr/create TARGET=lambda-placeholder`

### Docker

Helper commands to build and push a docker image to a ECR repository

*
    * cmd: `docker/build`
    * descr: Build the container
    * input:
        * TARGET: container name. It must match the name of the folder where the Dockerfile is stored.
    * Eg: `make docker/build TARGET=lambda-placeholder`
*
    * cmd: `docker/build/nocache`
    * descr: similar to `docker/build` but adding the arg `--no-cache`
    * input:
        * TARGET: container name. It must match the name of the folder where the Dockerfile is stored.
*
    * cmd: `docker/clean`
    * descr: Remove dangling images
*
    * cmd: `docker/push`
    * descr: Tag and push the docker image previously built
        * TARGET: name of the docker image/docker folder/ECR repo
    * eg: `make docker/push TARGET=lambda-placeholder`
*
    * cmd: `docker/push/rebuild`
    * descr: combines sequentially `docker/build`+`docker/push`
    * input:
        * TARGET: name of the docker image/docker folder/ECR repo

### Lambda

Utils to deploy locally lambda containerized functions and send events to them.
If you use this helpers make sure that there exists an env file to be used with the lambda's container.
By default, `lambda.env` is used (in linux: `touch lambda.env`).

*
    * cmd: `lambda/test/run/local`
    * descr: Runs locally a lambda function using the locally builded image.
    * input:
        * TARGET: docker image name.
        * TAG[opt]: docker image tag. If not provided uses the default one, `latest`.
        * LAMBDA_ENV[opt]: .env for the lambda environemnt in case. If not given, defaults to `lambda.env`
*
    * cmd: `lambda/test/run/ecr`
    * descr: Runs locally a lambda function using the image pulling from ECR.
    * input:
        * TARGET: docker image name.
        * TAG[opt]: docker image tag. If not provided uses the default one, `latest`.
        * LAMBDA_ENV[opt]: .env for the lambda environemnt in case. If not given, defaults to `lambda.env`
*
    * cmd: `lambda/test/event`
    * descr:
    * input:
        * TARGET: docker image name.
        * EVENT_FILE[opt]: name of the event file, eg: for `test_event.json`.
        * DOCKER_DIR[opt]: docker folder. If not provided uses the default one, `docker`.
        * LAMBDA_ENV[opt]: .env for the lambda environemnt in case. If not given, defaults to `lambda.env`
    * eg: `make lambda/test/event TARGET=lambda-placeholder EVENT_FILE=test_event.json`

### Terraform

Helper to deploy using terraform

*
    * cmd: `tf/init`
    * descr: Terraform init for a given stack and env
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`
*
    * cmd: `tf/apply`
    * descr: Terraform apply for a given stack and env
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`
*
    * cmd: `tf/apply/module`
    * descr: Terraform apply for a given stack's module and env
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`
*
    * cmd: `tf/apply/y`
    * descr: Terraform apply for a given stack and env with auto approve
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`
*
    * cmd: `tf/destroy`
    * descr: Terraform destroy for a given stack and env
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`
*
    * cmd: `tf/destroy/module`
    * descr: Terraform destroy for a given stack's module and env
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`
*
    * cmd: `tf/destroy/y`
    * descr: Terraform apply for a given stack and env with auto approve
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`
*
    * cmd: `tf/plan`
    * descr: Terraform plan for a given stack and env
    * input:
        * TARGET [opt]: name of the target stack, if none given, defaults to `app`
        * ENV [opt]: target environment, if none given, defaults to `sandbox`

## TODO:

 [] Add pre-commit