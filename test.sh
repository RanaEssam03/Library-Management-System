#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define namespace if needed (remove or adjust if not using namespaces)
NAMESPACE="default"

echo "Starting Kubernetes resource cleanup..."

# Delete specific services and deployments
kubectl delete services frontend-service --namespace=$NAMESPACE --ignore-not-found
kubectl delete deployments flask-app-deployment --namespace=$NAMESPACE --ignore-not-found
kubectl delete deployments frontend-deployment --namespace=$NAMESPACE --ignore-not-found

echo "Resource cleanup completed."

# Change to the directory containing deployment configurations
DEPLOYMENT_DIR="deployment_configurations"

if [ -d "$DEPLOYMENT_DIR" ]; then
  echo "Navigating to directory: $DEPLOYMENT_DIR"
  cd "$DEPLOYMENT_DIR"

  echo "Validating Kubernetes configurations..."
  kubectl apply --dry-run=client -f . --namespace=$NAMESPACE

  echo "Applying Kubernetes configurations..."
  kubectl apply -f . --namespace=$NAMESPACE

  echo "Deployment applied successfully."
else
  echo "Directory $DEPLOYMENT_DIR does not exist. Exiting."
  exit 1
fi
