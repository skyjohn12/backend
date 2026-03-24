# SE Core Competency for QE - Backend

A Spring Boot backend application for the SE Core Competency for QE project, featuring a REST API for student management with H2 in-memory database.

## Project Structure

# SE Core Competency for QE - Backend

A Spring Boot backend application for the SE Core Competency for QE project, featuring a REST API for student management with H2 in-memory database.

## Features

- RESTful API for student management (CRUD operations)
- Health and info endpoints for monitoring
- H2 in-memory database with pre-populated sample data
- Spring Boot Actuator for health, metrics, and info
- Unit and integration tests for controllers and application context

```
backend/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── demo/
│   │   │               ├── DemoApplication.java          # Main Spring Boot application
│   │   │               ├── controller/
│   │   │               │   ├── HealthController.java     # Health & info endpoints
│   │   │               │   └── StudentController.java    # Student CRUD operations
│   │   │               ├── entity/
│   │   │               │   └── Student.java              # Student JPA entity
│   │   │               └── repository/
│   │   │                   └── StudentRepository.java    # JPA repository interface
│   │   │               └── service/
│   │   │                   └── StudentService.java       # Business logic for student operations
│   │   └── resources/
│   │       ├── application.properties                    # Application configuration
│   │       ├── schema.sql                               # Database schema
│   │       └── data.sql                                 # Initial data
│   └── test/
│       └── java/
│           └── com/example/demo/
│               ├── DemoApplicationTests.java             # Basic application tests
│               └── controller/
│                   └── HealthControllerTest.java         # Health controller tests
├── target/                                              # Maven build output
├── pom.xml                                              # Maven configuration
└── README.md                                            # This file
```
## Setting Up VS Code for Spring Boot Development

To set up Visual Studio Code for Spring Boot development:

1. **Install Java Development Kit (JDK):**

2. **Install VS Code Extensions:**
   - [Extension Pack for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack)
   - [Spring Boot Extension Pack](https://marketplace.visualstudio.com/items?itemName=Pivotal.vscode-boot-dev-pack)

3. **Configure Java Home:**
   - Set the `JAVA_HOME` environment variable to your JDK installation path.

4. **Open the Project:**
   - Open the project folder in VS Code.

5. **Build and Run:**
   - Use the built-in terminal or the Run/Debug options provided by the extensions to build and run your Spring Boot application.

6. **Useful Commands:**
   - `mvn spring-boot:run` (if using Maven)
   - `./gradlew bootRun` (if using Gradle)

Refer to the official [Spring Boot documentation](https://spring.io/projects/spring-boot) for more details.


## Getting Started

### Prerequisites

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Build the project**
   ```bash
   mvn clean compile
   ```

3. **Run tests**
   ```bash
   mvn test
   ```

4. **Start the application**
   ```

   Or run the JAR file:
   ```bash
   mvn package
   java -jar target/demo-0.0.1-SNAPSHOT.jar
   ```

5. **Access the application**
   - API Base URL: `http://localhost:8084/api`
   - H2 Console: `http://localhost:8084/h2-console`
   - Health Check: `http://localhost:8084/api/health`

### H2 Database Connection

When accessing the H2 console:
- **JDBC URL**: `jdbc:h2:mem:testdb`
- **Username**: `sa`
- **Password**: `password`

## Configuration

The application is configured via [`application.properties`](src/main/resources/application.properties):

```properties
# Server runs on port 8084
server.port=8084

# H2 in-memory database
spring.datasource.url=jdbc:h2:mem:testdb
spring.h2.console.enabled=true

# JPA settings
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Actuator endpoints
management.endpoints.web.exposure.include=health,info,metrics
```

## API Examples

### Get All Students
```bash
curl http://localhost:8084/api/students/getAllStudents
```

### Create a Student
```bash
curl -X POST http://localhost:8084/api/students \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "registrationDate": "2025-10-06"
  }'
```

### Health Check
```bash
curl http://localhost:8084/api/health
```

## Testing

The project includes:
- **Unit tests** for controllers using MockMvc
- **Integration tests** for the Spring Boot application context
- **Test coverage** for health endpoints and student operations

Run tests with:
```bash
mvn test
```

View test reports in `target/surefire-reports/`

## Development

### Adding New Features

1. **Create entities** in `src/main/java/com/example/demo/entity/`
2. **Add repositories** in `src/main/java/com/example/demo/repository/`
3. **Implement controllers** in `src/main/java/com/example/demo/controller/`
4. **Write tests** in `src/test/java/com/example/demo/`

### CORS Configuration

The API is configured to accept requests from `http://localhost:3000` (React frontend) and all origins for student endpoints.

## Build & Deployment

### Maven Build
```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package application
mvn package

# Run application
mvn spring-boot:run
```

### JAR Deployment
```bash
# Build JAR
mvn clean package

# Run JAR
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

## Troubleshooting

### Common Issues

1. **Port 8084 already in use**
   - Change port in `application.properties`: `server.port=8085`

2. **Database connection issues**
   - Verify H2 console settings match `application.properties`

3. **CORS errors**
   - Check `@CrossOrigin` annotations in controllers

