FROM php:7.4-fpm-alpine3.12

LABEL maintainer="matt@domesticcat.com.au"

ENV COMPOSER_NO_INTERACTION=1

RUN set -ex \
    && apk add --update --no-cache \
    freetype \
    libpng \
    libjpeg-turbo \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libxml2-dev \
    autoconf \
    g++ \
    imagemagick \
    imagemagick-dev \
    libtool \
    make \
    pcre-dev \
    mariadb-client \
    libintl \
    icu \
    icu-dev \
    bash \
    jq \
    git \
    findutils \
    gzip \
    php7-zip \
    libzip-dev \
    && docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    && docker-php-ext-install bcmath iconv gd soap intl zip mysqli pdo_mysql \
    && pecl install imagick redis \
    && docker-php-ext-enable imagick redis \
    && rm -rf /tmp/pear \
    && apk del freetype-dev libpng-dev libjpeg-turbo-dev autoconf g++ libtool make pcre-dev

RUN apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

COPY ./php.ini /usr/local/etc/php/

COPY --from=composer:2.0 /usr/bin/composer /usr/bin/composer

COPY scripts/ /scripts/
RUN chown -R www-data:www-data /scripts \
    && chmod -R +x /scripts

WORKDIR /var/www/html
RUN chown -R www-data:www-data .
USER www-data

# Install Craft CMS and save original dependencies in file
RUN composer create-project craftcms/craft . \
    && cp composer.json composer.base

VOLUME [ "/var/www/html" ]

ENTRYPOINT [ "/scripts/run.sh" ]

CMD [ "docker-php-entrypoint", "php-fpm"]
