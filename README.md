### Introduction

In this project we containerize and deploy a Flask API to a Kubernetes cluster using Docker, AWS EKS, CodePipeline, and CodeBuild.


### Flask API
The Flask app that will be used for this project consists of a simple API with three endpoints:

- `GET '/'`: This is a simple health check, which returns the response 'Healthy'. 
- `POST '/auth'`: This takes a email and password as json arguments and returns a JWT based on a custom secret.
- `GET '/contents'`: This requires a valid JWT, and returns the un-encrpyted contents of that token. 

The app relies on a secret set as the environment variable `JWT_SECRET` to produce a JWT. 

The built-in Flask server is adequate for local development. 

We are using production-ready [Gunicorn](https://gunicorn.org/) server when deploying the app.

## Initial setup

### Dependencies

- Docker Engine
    - Installation instructions for all OSes can be found [here](https://docs.docker.com/install/).
    - For Mac users, if you have no previous Docker Toolbox installation, you can install Docker Desktop for Mac. If you already have a Docker Toolbox installation, please read [this](https://docs.docker.com/docker-for-mac/docker-toolbox/) before installing.
 - AWS Account
     - You can create an AWS account by signing up [here](https://aws.amazon.com/#).
     
### Deployment setup


#### A) Build and test the container locally
docker build --tag jwt-api-test .
docker run  -p 80:8080 --env_file env_file jwt-api-test 
curl http://0.0.0.0/

docker ps
docker stop <Container Id>

#### B) Deploy to an AWS EKS cluster using - a managed service that makes it easy for you to run Kubernetes on AWS

###### 1. Create an EKS cluster and setup role

Using the command line - eksctl to setup a cluster
```
$ eksctl create cluster --name xxx
```

Setup a policy, role via CLI. This can also be done via the amazon dashboard

a) Create account_id variable and setup an eks policy.
```
$ export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
$ export TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"arn:aws:iam::${ACCOUNT_ID}:root\" }, \"Action\": \"sts:AssumeRole\" } ] }"
```

b) Create a role, attach the policy and download the current config
```
$ aws iam create-role --role-name ROLENAME --assume-role-policy-document "$TRUST" --output text --query 'Role.Arn'
$ echo '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": [ "eks:Describe*", "ssm:GetParameters" ], "Resource": "*" } ] }' > /tmp/iam-role-policy 
$ aws iam put-role-policy --role-name ROLENAME --policy-name eks-describe --policy-document file:///tmp/iam-role-policy

```
c) Grant role access to the cluster by running the below, adding the snippet to the file and patch config
```
$ kubectl get -n kube-system configmap/aws-auth -o yaml > /tmp/aws-auth-patch.yml

'''
rolearn: arn:aws:iam::<ACCOUNT_ID>:role/role name
    username: build
    groups:
      - system:masters
'''

$  kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth-patch.yml)"
```

###### 2. Create the pipeline

a) Create a token on github for codepipeline

Make sure you generate a token with full control of private repositories

b) Add params to the environment (env, parameter_store in buildspec.yml)

These will be stored in AWS Parameter Store 

```
Put the secret in AWS store
$ aws ssm put-parameter --name JWT_SECRET --value "YourJWTSecret" --type SecureString
```
c) Modify the cloudformation 

```
'''
EksClusterName : use the name of the EKS cluster you created above
GitSourceRepo : use the name of your project's github repo.
GitHubUser : use your github user name
KubectlRoleName : use the name of the role you created for kubectl above
'''

```

d) Create the stack
- Go the the CloudFormation service in the aws console.
- Press the 'Create Stack' button.
- Choose the 'Upload template to S3' option and upload the template file 'ci-cd-codepipeline.cfn.yml'
- Press 'Next'. Give the stack a name, fill in your GitHub login and the Github access token generated in step 1.
- Confirm the cluster name matches your cluster, the 'kubectl IAM role' matches the role you created above, and the repository matches the name of your forked repo.
- Create the stack.


6. Get external ip and test your services
$ kubectl get services simple-jwt-api -o wide

##### Tools
[Kubernetes docs and installation](https://kubernetes.io/) 
[eksctl docs and tutorials](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)


###### Credits go to:

[Udacity Full Stack Nanodegree](https://www.udacity.com) - Full stack developer nanodegree for the guidance during the coursework and links to useful materials.

[Kelsey Hightower](https://www.youtube.com/watch?v=HlAXp0-M6SY) - For an informative intro to kubernetes 