FROM httpd:alpine

RUN apk update && apk add --no-cache ca-certificates openssl

ADD httpd.conf /usr/local/apache2/conf/httpd.conf
ADD httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf
