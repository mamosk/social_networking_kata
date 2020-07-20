ARG NODERED_VERSION
FROM nodered/node-red:${NODERED_VERSION:-1.1.2}
LABEL maintainer="fabio.michelini@gmail.com"

# give node-red user rights for volume directory
USER root
ENV KATA_PATH_FLOWS /kata/flows
RUN mkdir -p ${KATA_PATH_FLOWS} && \
    chown node-red ${KATA_PATH_FLOWS}
USER node-red

# install flows dependencies
ARG KATA_PATH_FLOWS_HOST
# COPY "${KATA_PATH_FLOWS_HOST}/package.json" "${KATA_PATH_FLOWS_HOST}/package-lock.json" "${KATA_PATH_FLOWS}"/
# COPY "${KATA_PATH_FLOWS_HOST}"/ "${KATA_PATH_FLOWS}"/
COPY "${KATA_PATH_FLOWS_HOST}"/package*.json "${KATA_PATH_FLOWS}"/
RUN npm i \
    --unsafe-perm \
    --no-update-notifier \
    --only=prod \
    --prefix ${KATA_PATH_FLOWS} \
    --save

# replace default healthcheck
COPY healthcheck.js /

# kata entry point
# ENTRYPOINT npm i \
#     --unsafe-perm \
#     --no-update-notifier \
#     --only=prod \
#     --prefix ${KATA_PATH_FLOWS} \
#     --save && \
#     npm start -- -v -s ${KATA_PATH_FLOWS}/settings.js
ENTRYPOINT npm start -- -v -s ${KATA_PATH_FLOWS}/settings.js
