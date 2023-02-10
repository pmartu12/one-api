ARG DOCKER_REGISTRY=docker.io
ARG PHP_VERSION=8.2.2

FROM ${DOCKER_REGISTRY}/php:${PHP_VERSION}-fpm-alpine AS php_base

ARG APCU_VERSION=5.1.22
ENV APP_ENV=prod APP_DEBUG=0 SERVER_ENV=prod

USER root

WORKDIR /app

RUN apk add --no-cache \
		autoconf \
        fcgi \
		git \
		g++ \
        icu-dev \
		make \
        libpq-dev \
        icu-dev \
        icu-data-full \
	;

RUN set -eux; \
	pecl install \
		apcu-${APCU_VERSION} \
        redis \
        igbinary \
	; \
	pecl clear-cache; \
    docker-php-ext-configure intl \
    ; \
    docker-php-ext-install \
        bcmath \
        intl \
        pdo \
        pdo_pgsql \
        pgsql \
    ;

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

FROM php_base AS php_prod
ARG GITHUB_TOKEN

WORKDIR /app

RUN addgroup -g 3000 -S php && adduser -u 1000 -S php -G php

# This layer is only re-built when dependences files are updated
COPY  composer.json composer.lock symfony.lock ./
RUN set -eux; \
  composer config --global --auth github-oauth.github.com $GITHUB_TOKEN \
  && composer install --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress --no-ansi \
  && composer clear-cache --no-ansi \
  && rm -f /root/.composer/auth.json

# copy only specifically what we need
COPY .env ./
COPY bin bin/
COPY config config/
COPY migrations migrations/
COPY public public/
COPY src src/
COPY template[s] templates/
COPY .build .build/

RUN  cp .build/*.ini $PHP_INI_DIR/conf.d/ \
  && mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
  && rm -f $PHP_INI_DIR/php-fpm.d/* \
  && cp .build/php-fpm.conf $PHP_INI_DIR/php-fpm.conf \
  && cp .build/www.conf /usr/local/etc/php-fpm.d/www.conf \
  && mkdir -p var/cache var/log \
  && composer dump-autoload --optimize --classmap-authoritative --no-dev \
  && composer dump-env prod \
  && composer run-script --no-dev --no-ansi post-install-cmd \
  && chmod +x bin/console \
  && bin/console cache:clear --no-warmup && bin/console cache:warmup \
  && composer clear-cache --no-ansi \
  && chown -R php:php /app/var \
  && sync

USER php
CMD ["php-fpm", "-F", "--pid", "/tmp/php-fpm.pid", "-y", "/usr/local/etc/php-fpm.conf"]

FROM php_base AS php_dev

ENV APP_ENV=dev APP_DEBUG=1 SERVER_ENV=dev GOOGLE_APPLICATION_CREDENTIALS="/tmp/application_default_credentials.json"
ARG INFECTION_VERSION=0.26.16

ARG HOST_UID
ARG HOST_GID

USER root

WORKDIR /app

COPY . .

RUN apk add --no-cache \
		bash \
		zsh \
		make \
        libpq-dev \
        linux-headers \
	;

RUN	pecl install \
		pcov \
        xdebug-3.2.0 \
	;

RUN cp .build/*.ini $PHP_INI_DIR/conf.d/ \
    && rm -rf "$PHP_INI_DIR/conf.d/php_custom.ini" \
    && rm -rf "$PHP_INI_DIR/conf.d/php_opcache.ini" \
    && echo "zend.assertions = 1" >> $PHP_INI_DIR/conf.d/php_opcache.ini \
    && echo "assert.exception = 1" >> $PHP_INI_DIR/conf.d/php_opcache.ini \
    && echo "extension=pcov.so" >> $PHP_INI_DIR/conf.d/pcov.ini ;

RUN wget https://github.com/infection/infection/releases/download/${INFECTION_VERSION}/infection.phar \
    && chmod +x infection.phar \
    && mv infection.phar /usr/local/bin/infection

ENV XDEBUG_CONF_FILE=$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
COPY --chown=php:php .docker/php/xdebug.ini $XDEBUG_CONF_FILE
COPY .docker/php/xdebug-starter.sh /usr/local/bin/xdebug-starter

RUN curl -1sLfvk 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | distro=alpine version=3.17.1 bash \
    && apk add symfony-cli

RUN addgroup -g $HOST_GID -S php  &&  \
    adduser -s /bin/bash -u $HOST_UID -S php -G php

USER php
