FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app
COPY pom.xml .
COPY .mvn/  .mvn/
COPY mvnw   .
RUN chmod +x mvnw \
    && ./mvnw dependency:go-offline -B -q


COPY src ./src


RUN ./mvnw package -DskipTests -B -q



# Stage 2 — runtime


FROM eclipse-temurin:17-jre-alpine

RUN addgroup -S appgroup \
    && adduser  -S appuser -G appgroup

WORKDIR /app


COPY --from=builder /app/target/*.jar app.jar
RUN chown appuser:appgroup app.jar

RUN apk add --no-cache curl

# OCI image labels — enforced by most enterprise registries.
# Enables vulnerability tracking, provenance, and audit trails.
LABEL org.opencontainers.image.title="spring-petclinic"                                     \
      org.opencontainers.image.description="Spring PetClinic — CleanStart SE Assignment"    \
      org.opencontainers.image.version="1.0.0"                                              \
      org.opencontainers.image.authors="Mihir Kulkarni"                                     \
      org.opencontainers.image.source="https://github.com/dhanush07/spring-petclinic-CleanStart"

HEALTHCHECK --interval=30s \
            --timeout=10s  \
            --start-period=60s \
            --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

USER appuser

EXPOSE 8080

ENTRYPOINT ["java",                                    \
            "-XX:+UseContainerSupport",                \
            "-XX:MaxRAMPercentage=75.0",               \
            "-Djava.security.egd=file:/dev/./urandom", \
            "-jar", "app.jar"]