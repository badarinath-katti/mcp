# Spring Boot Microservices Demo

This project demonstrates two Spring Boot applications communicating with each other via REST controllers, containerized with Docker and running in the same network.

## Architecture

- **User Service** (Port 8080): Manages user data with CRUD operations
- **Order Service** (Port 8081): Manages orders and communicates with User Service via REST API

## Services Overview

### User Service
- Exposes REST endpoints for user management
- Uses H2 in-memory database
- Provides user data to Order Service

### Order Service
- Manages order data
- Validates user existence by calling User Service REST API
- Provides order details with user information

## Running the Application

### Prerequisites
- Docker and Docker Compose installed
- Java 17+ (for local development)
- Maven 3.6+ (for local development)

### Docker Compose (Recommended)

1. Build and run both services:
```bash
docker-compose up --build
```

2. The services will be available at:
   - User Service: http://localhost:8080
   - Order Service: http://localhost:8081

### Local Development

1. Start User Service:
```bash
cd user-service
mvn spring-boot:run
```

2. Start Order Service (in another terminal):
```bash
cd order-service
USER_SERVICE_URL=http://localhost:8080 SERVER_PORT=8081 mvn spring-boot:run
```

## API Endpoints

### User Service (http://localhost:8080)

- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user

### Order Service (http://localhost:8081)

- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `GET /api/orders/user/{userId}` - Get orders by user ID
- `GET /api/orders/{id}/details` - Get order with user details (demonstrates inter-service communication)
- `POST /api/orders` - Create new order (validates user exists via User Service)
- `PUT /api/orders/{id}` - Update order
- `DELETE /api/orders/{id}` - Delete order

## Testing Inter-Service Communication

1. Create a user:
```bash
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

2. Create an order (Order Service will validate user exists):
```bash
curl -X POST http://localhost:8081/api/orders \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "product": "Laptop", "quantity": 1, "totalAmount": 999.99}'
```

3. Get order with user details (demonstrates REST communication):
```bash
curl http://localhost:8081/api/orders/1/details
```

## Docker Network

Both services run in a custom Docker network called `microservices-network`, allowing them to communicate using service names as hostnames:

- User Service is accessible at `http://user-service:8080` from within the network
- Order Service is accessible at `http://order-service:8081` from within the network

## Health Checks

The User Service includes Spring Boot Actuator for health monitoring:
- Health endpoint: http://localhost:8080/actuator/health

## Stopping the Services

```bash
docker-compose down
```