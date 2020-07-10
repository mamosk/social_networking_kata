FROM openjdk:8u201-jdk-alpine
LABEL maintainer="fabio.michelini@gmail.com"

# install/update software
RUN apk add --no-cache curl tar bash tzdata

# ensure time zone
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# java project root
ARG JAVA_ROOT=/kata
ENV JAVA_ROOT $JAVA_ROOT
ARG JAVA_CONFIG="${JAVA_ROOT}/config"
ENV JAVA_CONFIG $JAVA_CONFIG

# install maven
ARG MAVEN_VERSION=3.6.3
RUN mkdir -p /usr/share/maven && \
    curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "${JAVA_ROOT}/.m2"

# pimp maven JVM
ENV MAVEN_OPTS "-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# package jar
RUN mkdir $JAVA_ROOT
WORKDIR $JAVA_ROOT
COPY pom.xml $JAVA_ROOT
COPY src $JAVA_ROOT/src
RUN mvn -e -T 1C package

# kata entry point
ENV JAVA_OPTS ""
ENTRYPOINT exec java $JAVA_OPTS -jar "${JAVA_ROOT}/target/kata.jar" --spring.config.location="$JAVA_CONFIG/"
