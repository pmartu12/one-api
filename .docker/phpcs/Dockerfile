ARG DOCKER_REGISTRY=docker.io
ARG PHP_VERSION=8.1

FROM ${DOCKER_REGISTRY}/bitnami/php-fpm:${PHP_VERSION}

ARG PHPCS_VERSION=3.7.1
ARG PHPCODINGSTANDARD_VERSION=8.6.0
ARG DOCTRINE_CODING_STANDARD_VERSION=10.0.0

RUN install_packages autoconf make g++
RUN composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
RUN composer global require slevomat/coding-standard:${PHPCODINGSTANDARD_VERSION} --no-interaction --prefer-dist --no-progress --classmap-authoritative
RUN composer global require squizlabs/php_codesniffer:${PHPCS_VERSION} --no-interaction --prefer-dist --no-progress --classmap-authoritative
RUN composer global require doctrine/coding-standard:${DOCTRINE_CODING_STANDARD_VERSION} --no-interaction --prefer-dist --no-progress --classmap-authoritative
ENV PATH="/root/.composer/vendor/bin":${PATH}
RUN composer global clearcache && composer global install


WORKDIR /app
USER root
