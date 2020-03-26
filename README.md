# Deploying a Flask API

This is the project starter repo for the fourth course in the [Udacity Full Stack Nanodegree](https://www.udacity.com/course/full-stack-web-developer-nanodegree--nd004): Server Deployment, Containerization, and Testing.

In this project you will containerize and deploy a Flask API to a Kubernetes cluster using Docker, AWS EKS, CodePipeline, and CodeBuild.

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

Completing the project involves several steps:

2. Build and test the container locally
docker build --tag jwt-api-test .
docker run  -p 80:8080 --env_file env_file jwt-api-test 
curl http://0.0.0.0/

docker ps
docker stop <Container Id>

3. Create an EKS cluster
##### Modify CloudFormation template.

There is file named ci-cd-codepipeline.cfn.yml, this the the template file you will use to create your CodePipeline pipeline. Open this file and go to the 'Parameters' section. These are parameters that will accept values when you create a stack. Fill in the 'Default' value for the following:

- EksClusterName : use the name of the EKS cluster you created above
- GitSourceRepo : use the name of your project's github repo.
- GitHubUser : use your github user name
- KubectlRoleName : use the name of the role you created for kubectl above


##### Create a stack for CodePipeline

- Go the the CloudFormation service in the aws console.
- Press the 'Create Stack' button.
- Choose the 'Upload template to S3' option and upload the template file 'ci-cd-codepipeline.cfn.yml'
- Press 'Next'. Give the stack a name, fill in your GitHub login and the Github access token generated in step 1.
- Confirm the cluster name matches your cluster, the 'kubectl IAM role' matches the role you created above, and the repository matches the name of your forked repo.
- Create the stack.


4. Store a secret using AWS Parameter Store


5. Create a CodePipeline pipeline triggered by GitHub checkins


6. Create a CodeBuild stage which will build, test, and deploy your code

