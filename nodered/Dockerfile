ARG NODERED_VERSION
FROM nodered/node-red:${NODERED_VERSION:-1.1.1}
LABEL maintainer="fabio.michelini@gmail.com"

# give node-red user rights for volume directory
USER root
ENV KATA_PATH_FLOWS /kata/flows
RUN mkdir -p ${KATA_PATH_FLOWS} && \
    chown node-red ${KATA_PATH_FLOWS}

# replace default healthcheck
COPY healthcheck.js /

# kata entry point
USER node-red
ENTRYPOINT npm i \
    --unsafe-perm \
    --no-update-notifier \
    --only=prod \
    --prefix ${KATA_PATH_FLOWS} \
    --save && \
    npm start -- -v -s ${KATA_PATH_FLOWS}/settings.js
