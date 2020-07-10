FROM openjdk:8u201-jdk-alpine
LABEL maintainer="fabio.michelini@gmail.com"

# install/update software
RUN apk add --no-cache curl tar bash tzdata

# ensure time zone
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install maven
ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
RUN mkdir -p /usr/share/maven && \
    curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# pimp maven JVM
ENV MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# package jar
RUN mkdir /kata
WORKDIR /kata
COPY pom.xml /kata/
COPY src /kata/src
RUN mvn -e -T 1C package

# kata entry point
ENV JAVA_OPTS=""
ENTRYPOINT exec java $JAVA_OPTS -jar /kata/target/kata.jar --spring.config.location=/kata/config/
