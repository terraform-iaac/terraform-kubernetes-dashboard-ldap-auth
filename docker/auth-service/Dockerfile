FROM httpd:alpine

RUN apk update && apk add --no-cache ca-certificates openssl

ADD ./docker/auth-service/httpd.conf /usr/local/apache2/conf/httpd.conf
ADD ./docker/auth-service/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf