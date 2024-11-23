# Stage 1: Build the application
FROM openjdk:21-jdk-slim AS build

WORKDIR /build

# Copy the pom.xml and the Maven wrapper to the working directory
COPY pom.xml mvnw ./
COPY .mvn .mvn

# Resolve the project dependencies
RUN ./mvnw dependency:resolve

# Copy the source code to the working directory
COPY src src
COPY .env.properties .env.properties
COPY .env .env

# Build the application
RUN ./mvnw package

# Stage 2: Create the runtime image
FROM openjdk:21-jdk-slim

# Create a non-privileged user that the app will run under.
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    kmfaciluser
USER kmfaciluser

# Copy the JAR file from the build stage
COPY --from=build /build/target/*-exec.jar kmfacil.jar

# Expose the port the application runs on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "kmfacil.jar"]
