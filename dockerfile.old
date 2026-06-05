# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests

# Stage 2: Runtime image
FROM alpine:3.18.2

RUN apk add --no-cache openjdk17-jre

WORKDIR /app

RUN addgroup -S testuser && adduser -S testuser -G testuser

COPY --from=builder /app/target/*.jar petclinic.jar

RUN chown -R testuser:testuser /app

USER testuser

EXPOSE 8080

CMD ["java", "-jar", "petclinic.jar"]
