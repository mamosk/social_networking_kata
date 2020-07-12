ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION:-20.10}
LABEL maintainer="fabio.michelini@gmail.com"

RUN apt-get update && apt-get -y install \
    bash \
    curl \
    jq \
    pandoc \
    lynx
