# Library Management System

## Table of Contents

1. [Project Overview](#project-overview)
2. [Tools and Technologies](#tools-and-technologies)
3. [Docker Compose Configuration](#docker-compose-configuration)
4. [Deployment Script](#deployment-script)
5. [Terraform Configuration for AWS EKS Cluster](#terraform-configuration-for-aws-eks-cluster)
6. [Jenkins Pipeline](#jenkins-pipeline)
7. [Running the Jenkins Pipeline](#running-the-jenkins-pipeline)
8. [Monitoring with Grafana and Prometheus](monitoring-with-grafana-and-prometheus)
9. [Kubernetes Access Control](#kubernetes-access-control)
10. [Notes](#note)
11. [Conclusion](#conclusion)

  
## Project Overview

The Library Management System is a full-stack web application designed to streamline the management of library operations. This project integrates modern web technologies and cloud infrastructure to provide an efficient, scalable solution for managing library resources. It features a React frontend and a Flask backend, both containerized using Docker, with deployment and orchestration managed through AWS EKS.

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

## Deployment Script

The `deploy.sh` script automates the deployment process by building Docker images, starting the containers, and cleaning up any unused images. I created this script to streamline the build and push process, allowing me to test everything thoroughly before integrating it into the CI/CD pipeline.

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

## Terraform Configuration for AWS EKS Cluster

This Terraform configuration provisions an Amazon EKS (Elastic Kubernetes Service) cluster along with the necessary VPC (Virtual Private Cloud) infrastructure, subnets, IAM roles, security groups, and other components essential for running an EKS cluster on AWS. It was created to expedite the process of setting up the infrastructure and streamline deployment.

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
- **Key**: `state/terraform.tfstate`
- **Region**: `us-east-1`


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


### Tags

- **Environment**: `Production`
- **Team**: `Team1`

## Usage

1. Clone the repository containing this Terraform configuration.

2. Initialize Terraform after move to its file:

   ```bash
   cd terraform
   terraform init
   ```
3. Plan changes

    ```bash
    terraform plan
    ```
4. Apply changes

    ```bash
    terraform apply
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
        // Increase Git HTTP post buffer size to 500 MB to handle large pushes and prevent errors
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

5. **Deploy to Kubernetes**: Deploy the Docker images to the EKS cluster, ensuring all existing deployments and services are deleted beforehand.


    ```groovy
        stage('Deploy to Kubernetes') {
        steps {
            script {
                 // Apply Kubernetes configurations after deleting all services and deployment 
                        sh """
                         kubectl delete deployments --all --all-namespaces
                            kubectl delete services --all --all-namespaces
                        cd Library-Management-System/deployment_configurations && kubectl apply -f . --validate=false
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

## Monitoring with Grafana and Prometheus

Monitoring is crucial for maintaining the health and performance of the Library Management System. Grafana and Prometheus are used to collect, visualize, and analyze metrics from your application and infrastructure.


## Kubernetes Access Control
Effective management of Kubernetes access control involves defining and applying roles and permissions to ensure appropriate access to cluster resources. Follow these steps to configure and manage access control:

1. Update Access Control Files: Edit the files in the `Auth` folder to define roles, role bindings, and policies. These configurations control who can access various Kubernetes resources and what actions they are permitted to perform.

2. Apply Configurations: Deploy the updated access control configurations to your Kubernetes cluster using `kubectl`. This step ensures that the roles and permissions defined in your files are enforced in the cluster.


## Note: 
 - Before running the pipeline, make sure to update the base URL in the frontend with the Node IP address. This ensures the React app can access the backend using the NodePort and Node IP, preventing CORS issues. ☠️☠️☠️

 ## Conclusion

 The Library Management System (LMS) provides a comprehensive solution for managing library operations through a modern and scalable web application. By leveraging React for the frontend and Flask for the backend, this project ensures a robust user experience and efficient handling of backend operations. Containerization with Docker and orchestration with AWS EKS further enhance the scalability and maintainability of the system.

The Docker Compose configuration simplifies the local development and testing process by defining a unified environment for both the frontend and backend services. The Terraform setup ensures a reliable and repeatable deployment of the EKS cluster, managing essential infrastructure components with precision.

The Jenkins pipeline automates the CI/CD process, from building Docker images to deploying them on the Kubernetes cluster, ensuring a seamless and consistent deployment workflow. Additionally, monitoring with Grafana and Prometheus provides valuable insights into the system’s performance and health, enabling proactive management and troubleshooting.

By following this guide, you have a complete framework to deploy, monitor, and maintain a robust Library Management System. Regular updates and monitoring are crucial for adapting to evolving requirements and maintaining optimal performance.

