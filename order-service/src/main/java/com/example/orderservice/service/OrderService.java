package com.example.orderservice.service;

import com.example.orderservice.dto.User;
import com.example.orderservice.model.Order;
import com.example.orderservice.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Optional;

@Service
public class OrderService {
    
    @Autowired
    private OrderRepository orderRepository;
    
    private final WebClient webClient;
    
    @Value("${user.service.url:http://user-service:8080}")
    private String userServiceUrl;
    
    public OrderService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.build();
    }
    
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }
    
    public Optional<Order> getOrderById(Long id) {
        return orderRepository.findById(id);
    }
    
    public List<Order> getOrdersByUserId(Long userId) {
        return orderRepository.findByUserId(userId);
    }
    
    public Order createOrder(Order order) {
        // Validate that user exists by calling user service
        User user = getUserById(order.getUserId());
        if (user == null) {
            throw new RuntimeException("User not found with id: " + order.getUserId());
        }
        return orderRepository.save(order);
    }
    
    public Order updateOrder(Long id, Order orderDetails) {
        Order order = orderRepository.findById(id).orElseThrow(() -> 
            new RuntimeException("Order not found with id: " + id));
        
        order.setProduct(orderDetails.getProduct());
        order.setQuantity(orderDetails.getQuantity());
        order.setTotalAmount(orderDetails.getTotalAmount());
        
        return orderRepository.save(order);
    }
    
    public void deleteOrder(Long id) {
        orderRepository.deleteById(id);
    }
    
    // Method to call User Service via REST
    public User getUserById(Long userId) {
        try {
            return webClient.get()
                    .uri(userServiceUrl + "/api/users/" + userId)
                    .retrieve()
                    .bodyToMono(User.class)
                    .block();
        } catch (Exception e) {
            return null;
        }
    }
    
    // Method to get order details with user information
    public OrderWithUserDetails getOrderWithUserDetails(Long orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow(() -> 
            new RuntimeException("Order not found with id: " + orderId));
        
        User user = getUserById(order.getUserId());
        
        return new OrderWithUserDetails(order, user);
    }
    
    // Inner class to return order with user details
    public static class OrderWithUserDetails {
        private Order order;
        private User user;
        
        public OrderWithUserDetails(Order order, User user) {
            this.order = order;
            this.user = user;
        }
        
        public Order getOrder() {
            return order;
        }
        
        public void setOrder(Order order) {
            this.order = order;
        }
        
        public User getUser() {
            return user;
        }
        
        public void setUser(User user) {
            this.user = user;
        }
    }
}