#!/bin/bash

echo "=== Spring Boot Microservices Docker Setup ==="
echo ""

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker Desktop."
        exit 1
    fi
    echo "✅ Docker is running"
}

# Function to check if Maven is installed
check_maven() {
    if ! command -v mvn &> /dev/null; then
        echo "❌ Maven is not installed. Please install Maven first."
        echo "💡 Install with: brew install maven"
        exit 1
    fi
    echo "✅ Maven is available"
}

# Function to build JAR files
build_jars() {
    echo "🔨 Building JAR files with Maven..."
    
    # Build user-service
    echo "Building user-service..."
    cd user-service
    if mvn clean package -DskipTests; then
        echo "✅ User service JAR built successfully"
    else
        echo "❌ Failed to build user-service JAR"
        cd ..
        return 1
    fi
    cd ..
    
    # Build order-service
    echo "Building order-service..."
    cd order-service
    if mvn clean package -DskipTests; then
        echo "✅ Order service JAR built successfully"
    else
        echo "❌ Failed to build order-service JAR"
        cd ..
        return 1
    fi
    cd ..
    
    return 0
}

# Function to try different base images
try_docker_build() {
    echo "🔨 Building Docker images..."
    
    # Try building with different base images if one fails
    echo "Trying to build user-service..."
    if docker build -t user-service ./user-service; then
        echo "✅ User service built successfully"
    else
        echo "❌ Failed to build user-service with current Dockerfile"
        return 1
    fi
    
    echo "Trying to build order-service..."
    if docker build -t order-service ./order-service; then
        echo "✅ Order service built successfully"
    else
        echo "❌ Failed to build order-service with current Dockerfile"
        return 1
    fi
    
    return 0
}

# Function to run with docker-compose
run_with_compose() {
    echo "🚀 Starting services with docker-compose..."
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo "✅ Services started successfully"
        echo "📡 User Service: http://localhost:8080"
        echo "📡 Order Service: http://localhost:8081"
        echo ""
        echo "To view logs: docker-compose logs -f"
        echo "To stop: docker-compose down"
        return 0
    else
        echo "❌ Failed to start with docker-compose"
        return 1
    fi
}

# Function to run manually with docker run
run_manually() {
    echo "🚀 Starting services manually with Docker..."
    
    # Create network
    docker network create microservices-network 2>/dev/null || true
    
    # Run user-service
    echo "Starting user-service..."
    docker run -d \
        --name user-service \
        --network microservices-network \
        -p 8080:8080 \
        user-service
    
    # Wait a bit for user-service to start
    sleep 5
    
    # Run order-service
    echo "Starting order-service..."
    docker run -d \
        --name order-service \
        --network microservices-network \
        -p 8081:8081 \
        -e USER_SERVICE_URL=http://user-service:8080 \
        -e SERVER_PORT=8081 \
        order-service
    
    echo "✅ Services started manually"
    echo "📡 User Service: http://localhost:8080"
    echo "📡 Order Service: http://localhost:8081"
    echo ""
    echo "To view logs: docker logs user-service"
    echo "To stop: docker stop user-service order-service && docker rm user-service order-service"
}

# Main execution
check_docker
check_maven

if build_jars; then
    if try_docker_build; then
        if run_with_compose; then
            echo "🎉 Successfully running with docker-compose!"
        else
            echo "⚠️  Docker-compose failed, trying manual approach..."
            run_manually
        fi
    else
        echo "❌ Docker build failed. Check your Docker setup and network connectivity."
        echo ""
        echo "💡 Alternative: Run locally with Java:"
        echo "   Terminal 1: cd user-service && java -jar target/user-service-0.0.1-SNAPSHOT.jar"
        echo "   Terminal 2: cd order-service && SERVER_PORT=8081 USER_SERVICE_URL=http://localhost:8080 java -jar target/order-service-0.0.1-SNAPSHOT.jar"
        exit 1
    fi
else
    echo "❌ Maven build failed. Check your Maven setup and project structure."
    exit 1
fi