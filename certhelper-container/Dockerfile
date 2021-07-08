FROM alpine:latest

RUN apk update && apk add openssl curl jq
RUN adduser -D vault vault -g 1000
COPY createcert.sh /ssl/createcert.sh
RUN chown vault:vault /ssl
RUN chown vault:vault /ssl/createcert.sh
RUN chmod 700 /ssl/createcert.sh
USER vault
VOLUME ["/ssl"]
ENTRYPOINT /ssl/createcert.sh
