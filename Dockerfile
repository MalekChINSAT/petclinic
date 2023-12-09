FROM openjdk:17-jdk
ARG JAR_FILE=target/*.jar
COPY target/spring-petclinic-3.1.0-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
