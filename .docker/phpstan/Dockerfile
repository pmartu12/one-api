ARG DOCKER_REGISTRY=docker.io
ARG PHP_VERSION=8.1

FROM ${DOCKER_REGISTRY}/bitnami/php-fpm:${PHP_VERSION}

ARG PHPSTAN_VERSION=1.8.2
ARG PHPSTAN_SYMFONY_VERSION=1.2.11
ARG DOCTRINE_CODING_STANDARD_VERSION=10.0.0
ARG SAFE_RULE_VERSION=1.2.0
ARG STRICT_RULE_VERSION=1.0.0
ARG SAFE_VERSION=2.2.3

RUN install_packages autoconf make g++ unzip
RUN composer global config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
RUN composer global require "phpstan/phpstan:${PHPSTAN_VERSION}" --no-interaction --prefer-dist --no-progress --classmap-authoritative
RUN composer global require "doctrine/coding-standard:${DOCTRINE_CODING_STANDARD_VERSION}" --no-interaction --prefer-dist --no-progress --classmap-authoritative
RUN composer global require "phpstan/phpstan-symfony:${PHPSTAN_SYMFONY_VERSION}" --no-interaction --prefer-dist --no-progress --classmap-authoritative
RUN composer global require "thecodingmachine/safe:${SAFE_VERSION}" --no-interaction --prefer-dist --no-progress --classmap-authoritative
RUN composer global require "thecodingmachine/phpstan-safe-rule:${SAFE_RULE_VERSION}" --no-interaction --prefer-dist --no-progress --classmap-authoritative
RUN composer global require "thecodingmachine/phpstan-strict-rules:${STRICT_RULE_VERSION}" --no-interaction --prefer-dist --no-progress --classmap-authoritative
ENV PATH="/root/.composer/vendor/bin":${PATH}

WORKDIR /app
USER root

