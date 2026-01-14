# Application Analysis

## payment-api
- **Java Version:** 17
- **Spring Boot:** 3.3.3
- **Port:** 8080
- **JAR Name:** payment-api-1.0.0.jar
- **Dependencies:** Web, Actuator, JPA, PostgreSQL, WebFlux

### Environment Variables:
- PAYMENT_DB_URL (default: jdbc:postgresql://localhost:5433/payments)
- PAYMENT_DB_USER (default: payments)
- PAYMENT_DB_PASSWORD (default: payments)
- PAYMENT_WORKER_BASE_URL (default: http://localhost:8090)

### Health Endpoints:
- /actuator/health
- /actuator/info

## payment-worker
- **Java Version:** 17
- **Spring Boot:** 3.3.3
- **Port:** 8090
- **JAR Name:** payment-worker-1.0.0.jar
- **Dependencies:** Core, Actuator, WebFlux, Web

### Environment Variables:
- PAYMENT_WORKER_PORT (default: 8090)
- PAYMENT_API_BASE_URL (default: http://localhost:8080)
- WORKER_CPU_LOAD_MS (default: 300)

### Health Endpoints:
- /actuator/health
- /actuator/info
