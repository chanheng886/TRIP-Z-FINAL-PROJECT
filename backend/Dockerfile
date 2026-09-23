# ------------------------------------

# Stage 1: Build the Application

# ------------------------------------

FROM eclipse-temurin:21-jdk-alpine AS builder

  

WORKDIR /build

  

# Copy Maven wrapper and POM first for layer caching

COPY .mvn/ .mvn/

COPY mvnw pom.xml ./
RUN chmod +x mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline -B

  

# Copy source code and build

COPY src ./src

RUN ./mvnw clean package -DskipTests

  

# Standardize JAR name

RUN cp target/*.jar app.jar

  

# ------------------------------------

# Stage 2: Minimal Runtime Environment

# ------------------------------------

FROM eclipse-temurin:21-jre-alpine

  

WORKDIR /app

  

RUN addgroup -S spring && adduser -S spring -G spring

USER spring:spring

  

COPY --from=builder /build/app.jar app.jar

  

EXPOSE 8080

  

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-jar", "app.jar"]