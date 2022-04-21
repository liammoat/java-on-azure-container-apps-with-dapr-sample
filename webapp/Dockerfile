FROM maven:3.8.5-jdk-11 as builder

COPY src /usr/src/app/src
COPY pom.xml /usr/src/app

RUN mvn -f /usr/src/app/pom.xml clean package

FROM openjdk:11-jre-slim

WORKDIR /app
COPY --from=builder /usr/src/app/target/webapp-0.0.1-SNAPSHOT.jar /app

EXPOSE 8080

CMD ["java", "-jar", "webapp-0.0.1-SNAPSHOT.jar"]