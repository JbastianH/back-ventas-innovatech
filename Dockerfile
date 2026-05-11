# ETAPA 1: Construcción
FROM maven:3.8.5-openjdk-17-slim AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# ETAPA 2: Ejecución
FROM --platform=linux/amd64 eclipse-temurin:17-jre-alpine
WORKDIR /app

# SEGURIDAD: Usuario no root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

COPY --from=build /app/target/*.jar app.jar

# IMPORTANTE: Este backend usa el puerto 8081
EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]