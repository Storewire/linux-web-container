FROM php:8.1-fpm-alpine
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

ARG STOREWIRE_SECRETS_TOKEN
ENV STOREWIRE_SECRETS_TOKEN=$STOREWIRE_SECRETS_TOKEN

RUN apk add --no-cache wget openssh-client git zip curl nginx

RUN mkdir -p /app
RUN mkdir -p /app/public
RUN echo '<html><head><meta name="robots" content="noindex"></head><body><h1>Storewire Linux Web Container</h1><h3>It works!</h3></body>' > '/app/public/index.php'

COPY .deployment/nginx.conf /etc/nginx/nginx.conf
COPY .deployment/php-opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY .deployment/docker-php-memlimit.ini /usr/local/etc/php/conf.d/docker-php-memlimit.ini

RUN apk add --no-cache bind-tools \
  && ssh-keyscan github.com > /etc/ssh/ssh_known_hosts \
  && dig -t a +short github.com | grep ^[0-9] | xargs -r -n1 ssh-keyscan >> /etc/ssh/ssh_known_hosts \
  && apk del bind-tools

RUN chmod +x /usr/local/bin/install-php-extensions && \
    IPE_GD_WITHOUTAVIF=1 install-php-extensions pdo_mysql exif pcntl bcmath redis soap gd opcache

RUN chown -R www-data: /app

WORKDIR /app

EXPOSE 8888
CMD sh /app/.deployment/startup.sh
