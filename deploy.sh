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
