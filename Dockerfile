FROM maven:3.8.4-jdk-11-slim as builder
ARG JAR_FILE=target/*.jar
COPY target/spring-petclinic-3.1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
