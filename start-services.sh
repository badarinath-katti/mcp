#!/bin/bash

# Wait for user service to be ready
echo "Starting services..."

# Start supervisord in background
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# Wait for user service to be ready
echo "Waiting for user service to start..."
while ! curl -f http://localhost:8080/api/users/health > /dev/null 2>&1; do
    sleep 2
    echo "Still waiting for user service..."
done

echo "User service is ready!"

# Wait for order service to be ready
echo "Waiting for order service to start..."
while ! curl -f http://localhost:8081/api/orders/health > /dev/null 2>&1; do
    sleep 2
    echo "Still waiting for order service..."
done

echo "Order service is ready!"
echo "Both services are running successfully!"

# Keep the container running
wait