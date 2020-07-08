FROM nodered/node-red:1.1.1
LABEL maintainer="fabio.michelini@gmail.com"
USER root
ENV KATA_PATH_FLOWS=/kata/flows
#COPY healthcheck.js /
RUN mkdir -p ${KATA_PATH_FLOWS} && \
    chown node-red ${KATA_PATH_FLOWS}
USER node-red
ENTRYPOINT npm i \
    --unsafe-perm \
    --no-update-notifier \
    --only=prod \
    --prefix ${KATA_PATH_FLOWS} \
    --save && \
    npm start -- -v -s ${KATA_PATH_FLOWS}/settings.js
