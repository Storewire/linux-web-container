#!/bin/sh
echo "Starting PHP FPM in daemon mode"
php-fpm -D
# while ! nc -w 1 -z 127.0.0.1 9000; do sleep 0.1; done;
echo "Testing NGINX"
nginx -t
cat /etc/nginx/nginx.conf
echo "Starting NGINX"
nginx
