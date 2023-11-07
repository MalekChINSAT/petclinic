FROM openjdk:11-jdk
ARG JAR_FILE=target/*.jar
COPY target/spring-petclinic-3.1.0-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
