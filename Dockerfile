# ETAPA 1: Construcción - Se inicializa el proceso de compilación del proyecto.
# Se emplea una imagen de Maven con JDK 17 sobre una distribución slim para optimizar el espacio en la fase de build.
FROM maven:3.8.5-openjdk-17-slim AS build

# Se define /app como el directorio raíz donde se gestionarán los archivos del microservicio.
WORKDIR /app

# Se transfiere el archivo pom.xml al contenedor para preparar la gestión de dependencias.
COPY pom.xml .

# Se descargan las dependencias necesarias de forma anticipada para aprovechar la caché de capas de Docker.
RUN mvn dependency:go-offline

# Se copia la carpeta src que contiene toda la lógica de negocio y controladores del backend.
COPY src ./src

# Se ejecuta el empaquetado del proyecto para generar el archivo .jar ejecutable, omitiendo los tests para mayor velocidad.
RUN mvn clean package -DskipTests

# ETAPA 2: Ejecución - Se configura el entorno final de producción.
# Se especifica la arquitectura linux/amd64 para garantizar compatibilidad con las instancias EC2 de AWS.
FROM --platform=linux/amd64 eclipse-temurin:17-jre-alpine

# Se establece el directorio de trabajo final en /app.
WORKDIR /app

# SEGURIDAD: Se crea un grupo y un usuario de sistema llamado "spring".
# Esta acción garantiza que la aplicación no se ejecute con privilegios de root, reduciendo riesgos de seguridad.
RUN addgroup -S spring && adduser -S spring -G spring

# Se asigna el contexto de ejecución al usuario "spring".
USER spring

# Se transfiere el archivo ejecutable (.jar) desde la etapa de construcción a la imagen final de ejecución.
COPY --from=build /app/target/*.jar app.jar

# IMPORTANTE: Se documenta que este microservicio específico opera sobre el puerto 8081.
EXPOSE 8081

# Se establece el comando de entrada que arranca la aplicación Java al iniciar el contenedor.
ENTRYPOINT ["java", "-jar", "app.jar"]
