# FROM node:13.12.0-alpine
ARG NODE_VERSION
FROM node:${NODE_VERSION:-14.5.0-alpine}
LABEL maintainer="fabio.michelini@gmail.com"

WORKDIR /kata

# add node_modules to $PATH
ENV PATH /kata/node_modules/.bin:$PATH

# install dependencies
COPY package.json ./
COPY package-lock.json ./
RUN npm install

# add app
COPY . ./

# start app
CMD ["npm", "start"]
