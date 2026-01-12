#!/bin/bash

# Variables
IMAGE_NAME="bibhupmishra/otel-hf"
TAG="latest"

# Build the image
echo "Building Docker image ${IMAGE_NAME}:${TAG}..."
docker build -t ${IMAGE_NAME}:${TAG} .

# Push the image
echo "Pushing Docker image to Docker Hub..."
docker push ${IMAGE_NAME}:${TAG}

echo "Done!"
