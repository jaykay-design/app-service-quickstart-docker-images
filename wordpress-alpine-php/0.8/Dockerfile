#
# Dockerfile for WordPress
#
FROM jaykaydesign/nginx-fpm:php7.3.17-redis
LABEL MAINTAINER John Caprez <jay@jaykay-design.com>
# ========
# ENV vars
# ========
# ssh
ENV SSH_PASSWD "root:Docker!"
ENV SSH_PORT 2222
#nginx
ENV NGINX_LOG_DIR "/home/LogFiles/nginx"
#php
ENV PHP_HOME "/usr/local/etc/php"
ENV PHP_CONF_DIR $PHP_HOME
ENV PHP_CONF_FILE $PHP_CONF_DIR"/php.ini"
# wordpress
ENV WORDPRESS_HOME "/home/site/wwwroot"
#
ENV DOCKER_BUILD_HOME "/dockerbuild"
# ====================
# ====================
# supervisor
COPY supervisord.conf /etc/
# php
COPY uploads.ini /usr/local/etc/php/conf.d/
# nginx
COPY nginx_conf/. /etc/nginx/conf.d/
# php WP extensions
RUN apk add --update freetype-dev libpng-dev libjpeg-turbo-dev libxml2-dev autoconf g++ imagemagick-dev libtool make \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del autoconf g++ libtool make \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

#
COPY local_bin/. /usr/local/bin/
RUN chmod -R +x /usr/local/bin
EXPOSE $SSH_PORT 80
ENTRYPOINT ["entrypoint.sh"]
