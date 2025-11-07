#!/bin/bash

# Configuration
DOCKER_USERNAME="badarinathkatti"  # Replace with your Docker Hub username
TAG_VERSION="latest"
PLATFORM="linux/amd64"

echo "Building and pushing Spring Boot microservices to Docker registry for linux/amd64..."

# Build the JAR files first
echo "Building JAR files..."
cd user-service && mvn clean package -DskipTests && cd ..
cd order-service && mvn clean package -DskipTests && cd ..

# Build and tag individual services for linux/amd64
echo "Building individual services for $PLATFORM..."
docker build --platform $PLATFORM -t $DOCKER_USERNAME/user-service:$TAG_VERSION ./user-service
docker tag $DOCKER_USERNAME/user-service:$TAG_VERSION $DOCKER_USERNAME/user-service:latest

docker build --platform $PLATFORM -t $DOCKER_USERNAME/order-service:$TAG_VERSION ./order-service
docker tag $DOCKER_USERNAME/order-service:$TAG_VERSION $DOCKER_USERNAME/order-service:latest

# Build and tag combined service for linux/amd64
echo "Building combined service for $PLATFORM..."
docker build --platform $PLATFORM -f Dockerfile.combined -t $DOCKER_USERNAME/spring-microservices:$TAG_VERSION .
docker tag $DOCKER_USERNAME/spring-microservices:$TAG_VERSION $DOCKER_USERNAME/spring-microservices:latest

# Build and tag proxy service for linux/amd64
echo "Building proxy service for $PLATFORM..."
docker build --platform $PLATFORM -f Dockerfile.proxy -t $DOCKER_USERNAME/spring-microservices-proxy:$TAG_VERSION .
docker tag $DOCKER_USERNAME/spring-microservices-proxy:$TAG_VERSION $DOCKER_USERNAME/spring-microservices-proxy:latest

# Push to registry
echo "Pushing images to Docker Hub..."
docker push $DOCKER_USERNAME/user-service:$TAG_VERSION
docker push $DOCKER_USERNAME/user-service:latest
docker push $DOCKER_USERNAME/order-service:$TAG_VERSION
docker push $DOCKER_USERNAME/order-service:latest
docker push $DOCKER_USERNAME/spring-microservices:$TAG_VERSION
docker push $DOCKER_USERNAME/spring-microservices:latest
docker push $DOCKER_USERNAME/spring-microservices-proxy:$TAG_VERSION
docker push $DOCKER_USERNAME/spring-microservices-proxy:latest

echo "Successfully pushed all images for $PLATFORM!"
echo "Individual services:"
echo "  User Service: $DOCKER_USERNAME/user-service:latest"
echo "  Order Service: $DOCKER_USERNAME/order-service:latest"
echo "Combined service:"
echo "  Microservices: $DOCKER_USERNAME/spring-microservices:latest"
echo "Proxy service (RECOMMENDED):"
echo "  Microservices with Proxy: $DOCKER_USERNAME/spring-microservices-proxy:latest"