FROM alpine:3.6

RUN apk update && apk add --no-cache dcron curl unzip bash

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.8/bin/linux/amd64/kubectl \
    && chmod u+x kubectl && mv kubectl /bin/kubectl

# Add schedule for recreate tokens
COPY ./docker/recreate-tokens/tokens.sh /usr/share/tokens.sh

RUN echo "0 * * * * /bin/bash /usr/share/tokens.sh" >> /var/spool/cron/crontabs/root
RUN chmod +x /usr/share/tokens.sh
CMD [ "su", "-c", "crond -l 6 -f" ]
