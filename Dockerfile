# Node base image
ARG NODE_VERSION=20.16-alpine
FROM node:${NODE_VERSION} AS foundry-download

# Foundry download
ARG FOUNDRY_URL
WORKDIR "/tmp"
RUN apk --update --no-cache add unzip && \
    wget -O foundryvtt.zip ${FOUNDRY_URL} && \
    unzip -q foundryvtt.zip -d foundry-vtt

# Foundry install
FROM node:${NODE_VERSION} AS foundry-install
ENV FOUNDRY_UID=4321 \
    FOUNDRY_HOME=/home/foundry/
RUN addgroup -S -g ${FOUNDRY_UID} foundry && \
    adduser -S -u ${FOUNDRY_UID} -G foundry foundry
WORKDIR ${FOUNDRY_HOME}
USER foundry:foundry
COPY --from=foundry-download /tmp/foundry-vtt .

VOLUME ["/userdata"]

EXPOSE 30000/TCP

ENTRYPOINT [ "node" ]
CMD ["resources/app/main.js", "--port=30000", "--headless", "--dataPath=/userdata"]