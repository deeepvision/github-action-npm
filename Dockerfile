FROM node:18-alpine

RUN \
    apk add --no-cache bash

COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]
