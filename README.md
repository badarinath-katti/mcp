# Spring Boot Microservices Demo

This project demonstrates two Spring Boot microservices communicating with each other via WebClient, containerized with Docker and deployable in multiple configurations.

## Architecture

- **User Service** (Port 8080): Manages user data with CRUD operations
- **Order Service** (Port 8081): Manages orders and communicates with User Service via WebClient

## Services Overview

### User Service
- Exposes REST endpoints for user management
- Uses H2 in-memory database
- Provides health check endpoint
- JPA/Hibernate for data persistence

### Order Service
- Manages order data
- Validates user existence by calling User Service via WebClient
- Provides order details with user information
- Uses WebClient for non-blocking HTTP communication

## Running the Application

### Prerequisites
- Docker and Docker Compose installed
- Java 17+ (for local development)
- Maven 3.6+ (for local development)

### Quick Start (Automated Script)

Use the automated script that handles all setup:
```bash
./run-docker.sh
```

This script will:
- Check Docker availability
- Build Maven artifacts
- Build Docker images
- Start services with docker-compose

### Docker Compose Options

1. **Standard Setup** (Recommended):
```bash
docker-compose up --build
```

2. **Render.com Deployment**:
```bash
docker-compose -f docker-compose.render.yml up --build
```

3. **Combined Service** (Single Container):
```bash
docker build -f Dockerfile.combined -t combined-service .
docker run -p 8080:8080 -p 8081:8081 combined-service
```

4. **With Nginx Proxy**:
```bash
docker build -f Dockerfile.proxy -t proxy-service .
docker run -p 80:80 proxy-service
```

### Local Development

1. Build both services first:
```bash
# User Service
cd user-service && mvn clean package -DskipTests && cd ..
# Order Service  
cd order-service && mvn clean package -DskipTests && cd ..
```

2. Start User Service:
```bash
cd user-service
mvn spring-boot:run
```

3. Start Order Service (in another terminal):
```bash
cd order-service
USER_SERVICE_URL=http://localhost:8080 SERVER_PORT=8081 mvn spring-boot:run
```

## API Endpoints

### User Service (http://localhost:8080)

- `GET /api/users/health` - Health check endpoint
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user

**User Model:**
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com"
}
```

### Order Service (http://localhost:8081)

- `GET /api/orders/health` - Health check endpoint
- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `GET /api/orders/user/{userId}` - Get orders by user ID
- `GET /api/orders/{id}/with-user` - Get order with user details (WebClient call)
- `POST /api/orders` - Create new order (validates user via WebClient)
- `PUT /api/orders/{id}` - Update order
- `DELETE /api/orders/{id}` - Delete order

**Order Model:**
```json
{
  "id": 1,
  "userId": 1,
  "product": "Laptop",
  "quantity": 1,
  "totalAmount": 999.99
}
```

## Testing the Services

### Automated Testing
Run the demo script that tests all endpoints:
```bash
./demo.sh
```

### Manual Testing

1. **Health Checks:**
```bash
curl http://localhost:8080/api/users/health
curl http://localhost:8081/api/orders/health
```

2. **Create a user:**
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

3. **Create an order** (Order Service validates user via WebClient):
```bash
curl -X POST http://localhost:8081/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "product": "Laptop", "quantity": 1, "totalAmount": 999.99}'
```

4. **Get order with user details** (demonstrates WebClient communication):
```bash
curl http://localhost:8081/api/orders/1/with-user
```

## Deployment Options

### 1. Standard Docker Compose
Services run independently with docker-compose networking.

### 2. Combined Service
Both services run in a single container using supervisord.

### 3. Nginx Proxy
Services run behind an Nginx reverse proxy for load balancing.

### 4. Cloud Deployment (Render.com)
Optimized configuration for Render.com platform deployment.

## Docker Network

Services communicate via Docker networking:
- **Development**: `http://localhost:8080` and `http://localhost:8081`
- **Docker Compose**: `http://user-service:8080` and `http://order-service:8081`
- **Combined/Proxy**: Internal communication via localhost

## Key Features

- **WebClient Integration**: Non-blocking HTTP communication between services
- **Multiple Deployment Strategies**: Docker Compose, combined container, proxy setup
- **Health Monitoring**: Built-in health check endpoints
- **Database**: H2 in-memory database with JPA/Hibernate
- **Error Handling**: Proper error responses and logging
- **Cloud Ready**: Render.com deployment configuration included

## Scripts Available

- `./run-docker.sh` - Automated Docker setup and deployment
- `./demo.sh` - API testing and demonstration
- `./start-services.sh` - Alternative startup script
- `./push-to-registry.sh` - Container registry deployment

## Troubleshooting

### Remove duplicate order-service folder:
```bash
rm -rf user-service/order-service/
```

### Clean and rebuild:
```bash
mvn clean package -DskipTests
docker-compose down && docker-compose up --build
```

### Check logs:
```bash
docker-compose logs -f user-service
docker-compose logs -f order-service
```

## Stopping the Services

```bash
docker-compose down
```

For combined service:
```bash
docker stop <container-id>
```