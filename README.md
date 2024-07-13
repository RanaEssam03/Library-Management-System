# Library Management System

## Table of Contents
1. [Project Overview](#project-overview)
3. [Tools and Technologies](#tools-and-technologies)
4. [Docker Compose Configuration](#docker-compose-configuration)
5. [Deployment Script](#deployment-script)
6. [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Running the Application Locally](#running-the-application-locally)
    - [Accessing the Application](#accessing-the-application)

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
version: '3.8'

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

## Getting Started

### Prerequisites
-  Docker installed on your machine.
- Docker Compose installed on your machine.

### Running the Application Locally

1. Clone the Repository:
    
    ```bash
    git clone https://github.com/RanaEssam03/Library-Management-System.git
    cd Library-Management-System
    ```

2. Deploy the Application:

    ```bash
    ./deploy.sh
    ```
3. Runt the application in docker
    
    ```bash
    docker-compose up 
    ```
3. Access the Application:

    - Frontend: [http://localhost:5173](http://localhost:5173)
    - Backend: [http://localhost:5000](http://localhost:5000)

