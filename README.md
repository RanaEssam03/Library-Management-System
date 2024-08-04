# Library Management System

## Table of Contents

1. [Project Overview](#project-overview)
2. [Tools and Technologies](#tools-and-technologies)
3. [Docker Compose Configuration](#docker-compose-configuration)
4. [Deployment Script](#deployment-script)
5. [Terraform Configuration for AWS EKS Cluster](#terraform-configuration-for-aws-eks-cluster)
6. [Jenkins Pipeline](jenkins-pipeline)
7. [Running the Jenkins Pipeline](running-the-jenkins-pipeline)
  
## Project Overview

This project is a full-stack web application that utilizes React for the frontend and Flask for the backend. The application is containerized using Docker, and we use `docker-compose` to manage multi-container deployments. Additionally, we provide a `deploy.sh` script to automate the deployment process.

## Tools and Technologies

### Frontend

- **React**: A JavaScript library for building user interfaces.
- **Node.js**: Used for running the React development server.

### Backend

- **Flask**: A lightweight WSGI web application framework in Python.
- **Python**: The programming language used for the backend logic.

### Containerization

- **Docker**: Used to containerize both the frontend and backend applications.
- **Docker Compose**: Used to define and run multi-container Docker applications.

## Docker Compose Configuration

The `docker-compose.yml` file defines the services required for this project:

```yaml
version: "3.8"

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    volumes:
      - ./backend:/app
    environment:
      - FLASK_ENV=development

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "5173:5173"
    volumes:
      - ./frontend:/app
    environment:
      - NODE_ENV=development
```

### How to Use Docker Compose

1. Build and Start Containers: To build and start the containers, run:

```bash
docker-compose up --build
```

2. Stop Containers: To stop the containers, run:

```bash
docker-compose down
```

3. View Logs: To view the logs of all services, run:

```bash
docker-compose logs
```

## Terraform Configuration for AWS EKS Cluster

This Terraform configuration sets up an Amazon EKS (Elastic Kubernetes Service) cluster along with the necessary VPC (Virtual Private Cloud) infrastructure, subnets, IAM roles, security groups, and other components required to run an EKS cluster on AWS.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your machine
- AWS account with sufficient permissions to create IAM roles, VPCs, EKS clusters, and related resources
- AWS CLI configured with appropriate credentials

## Overview

The configuration includes the following components:

1. **Terraform Backend Configuration**: Stores the Terraform state file in an S3 bucket with state locking using a DynamoDB table.

2. **Providers**:

   - AWS provider configured for the `us-east-1` region.
   - Kubernetes provider to manage Kubernetes resources within the created EKS cluster.

3. **VPC Configuration**:

   - A VPC with DNS support and hostnames enabled.
   - Public and private subnets in different availability zones.
   - An Internet Gateway for the public subnet.
   - NAT Gateway for outbound internet access from private subnets.
   - Route tables for managing network traffic.

4. **Security Groups**:

   - Allows inbound traffic on ports 80 (HTTP), 443 (HTTPS), and 5173.
   - Allows all outbound traffic.

5. **IAM Roles and Policies**:

   - IAM role for the EKS cluster with the `AmazonEKSClusterPolicy`.
   - IAM role for EKS Node Groups with necessary policies for worker nodes.
   - IAM role for master access with a custom policy to allow specific users to assume the role.

6. **EKS Cluster and Node Group**:

   - EKS cluster configured with the specified VPC and subnets.
   - Node group with scaling configuration for the number of worker nodes.

7. **IAM Policies and Role for Master Access**:
   - Custom IAM policy and role for managing access to the EKS cluster by trusted accounts and users.

## Configuration Details

### Terraform Backend

- **Bucket**: `teamm01`
- **Key**: `terraform.tfstate`
- **Region**: `us-east-1`
- **DynamoDB Table**: `terraform-locks`

### AWS VPC

- **VPC CIDR**: `10.0.0.0/16`
- **Public Subnet CIDR**: `10.0.1.0/24` (Availability Zone: `us-east-1a`)
- **Private Subnet CIDR**: `10.0.2.0/24` (Availability Zone: `us-east-1b`)

### EKS Cluster

- **Cluster Name**: `Team1-cluster`
- **Node Group Name**: `Team1-node-group`
- **Desired Node Count**: 1
- **Maximum Node Count**: 3
- **Minimum Node Count**: 1

### IAM User ARNs Allowed to Assume the Role

- `arn:aws:iam::637423483309:user/basma`
- `arn:aws:iam::637423483309:user/gamila`
- `arn:aws:iam::637423483309:user/farah`

### Tags

- **Environment**: `Production`
- **Team**: `Team1`

## Usage

1. Clone the repository containing this Terraform configuration.
2. Initialize Terraform:

   ```bash
   terraform init
   ```

## Deployment Script

The `deploy.sh` script automates the deployment process. It builds the Docker images, starts the containers, and cleans up any unused images.

```bash
    #!/bin/bash

    # Log in to Docker Hub
    docker login

    # Retrieve the Docker Hub username
    DOCKER_HUB_USERNAME=$(docker info 2>/dev/null | grep -Po '(?<=Username: ).*')

    # Check if the username was retrieved successfully
    if [ -z "$DOCKER_HUB_USERNAME" ]; then
    echo "Failed to retrieve Docker Hub username."
    exit 1
    fi

    echo "Using Docker Hub username: $DOCKER_HUB_USERNAME"

    # Define the services
    services=("backend" "frontend")

    # Remove existing images
    for service in "${services[@]}"; do
    image_name="$DOCKER_HUB_USERNAME/library-management-system_$service:latest"

    if docker images | grep -q "$image_name"; then
        echo "Removing existing image: $image_name"
        docker rmi -f "$image_name"
    fi
    done

    # Build images using docker-compose
    docker-compose build

    # Tag and push images for each service
    for service in "${services[@]}"; do
    # Define image name
    image_name="$DOCKER_HUB_USERNAME/library-management-system_$service:latest"

    # Tag the image
    docker tag "library-management-system_$service:latest" "$image_name"

    # Push the image to Docker Hub
    docker push "$image_name"
    done
```

### How to Use the Deployment Script

1. Make the script executable:

   ```bash
   chmod +x deploy.sh
   ```

2. Run the script:
   ```bash
   ./deploy.sh
   ```

## Jenkins Pipeline

The Jenkins pipeline automates the process of building, tagging, pushing Docker images, and deploying the Library Management System to an AWS EKS cluster.

### Pipeline Stages

1. **Clean Workspace**: Deletes the entire workspace to ensure a clean build environment.

   ```groovy
       stage('Clean Workspace') {
       steps {
           script {
               deleteDir() // Deletes the entire workspace
           }
       }
   }

   ```

2. **Clone Repository**: Clones the Library Management System source code from GitHub.

   ```groovy
       stage('Clone Repository') {
       steps {
           sh 'git config --global http.postBuffer 524288000'
           // Checkout the source code from GitHub
           sh "git clone $GIT_REPO_URL"
       }
   }
   ```

3. **Build Docker Images**: Builds Docker images for the application using `docker-compose`.

   ```groovy
       stage('Build and Push Docker Images') {
       steps {
           script {
               // Build and push Docker images
               sh 'cd Library-Management-System && docker-compose --verbose build'
           }
       }
   }
   ```

4. **Tag and Push Images** : Tags the Docker images and pushes them to Docker Hub.

   ```groovy
       stage('Tag and Push Images') {
   steps {
       script {
           sh 'docker images'
           // Log in to Docker Hub and push images
           docker.withRegistry("https://index.docker.io/v1/", DOCKER_CREDENTIALS_ID) {
               // Tag and push backend image
               sh """  docker tag library-management-system_backend:latest $DOCKER_REGISTRY/library-management-system_backend:latest
                       docker push $DOCKER_REGISTRY/library-management-system_backend:latest """

               // Tag and push frontend image
               sh """
                   docker tag library-management-system_frontend:latest ${DOCKER_REGISTRY}/library-management-system_frontend:latest
                    docker push ${DOCKER_REGISTRY}/library-management-system_frontend:latest"""
                 
      }
        }
         }
           }
   ```
5. **Terraform Init and Apply**: Initializes Terraform and applies the configuration to create and manage infrastructure.


    ```groovy
        stage('Terraform Init and Apply') {
        steps {
            script {
                // Initialize Terraform
                sh 'terraform init'
  
                // Apply the Terraform configuration
                sh 'terraform apply -auto-approve'
            }
        }
    }
    ```
6. **Deploy to Kubernetes**: Deploys the Docker images to the EKS cluster.


    ```groovy
        stage('Deploy to Kubernetes') {
        steps {
            script {
                 // Apply Kubernetes configurations
                        sh """
                            kubectl apply -f . --validate=false
                            kubectl get services
                        """
            }
        }
    }
    ```

## Running the Jenkins Pipeline

### Prerequisites

- Docker installed on your machine.
- Docker Compose installed on your machine.
- Jenkins installed and configured on your machine or server.
- Jenkins pipeline with the necessary credentials and configurations set up.

#### Steps:

1. Ensure Jenkins is up and nning and you have the Jenkinsfile configured in your repository.

2. Configure Jenkins with the necessary credentials for Docker Hub and AWS.

3. Create a new Jenkins pipeline job or use an existing one that points to your repository.

4. Trigger the pipeline manually or set up automatic triggers (e.g., on code commits).

5. Monitor the pipeline stages through the Jenkins interface to ensure that the build, push, and deployment processes complete successfully.