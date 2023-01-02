FROM php:8.1-fpm
MAINTAINER victor apostol <apostol.victor@gmail.com>
ENV LAST_UPDATED 2022-11-31-b
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y wget openssh-server curl apt-transport-https lsb-release ca-certificates sudo gnupg2
RUN apt-get upgrade -y && apt-get install -y iputils-ping nodejs npm libpng-dev git unzip libicu-dev libzip-dev zip
RUN pecl install redis-5.3.4 && docker-php-ext-enable redis
RUN docker-php-ext-install mysqli pdo_mysql  && docker-php-ext-enable mysqli pdo_mysql
RUN docker-php-ext-install intl && docker-php-ext-enable intl
RUN docker-php-ext-install zip
RUN apt-get install -y \
    libzip-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libfreetype6-dev

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd

RUN docker-php-ext-configure pcntl --enable-pcntl
RUN docker-php-ext-install pcntl && docker-php-ext-enable pcntl
RUN docker-php-ext-install soap

RUN pecl install xdebug-3.1.1
RUN docker-php-ext-enable xdebug
ADD php.ini /usr/local/etc/php/conf.d/

RUN apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /run/php

RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"
ENV COMPOSER_VERSION 2.1.12

# Install Composer
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} && rm -rf /tmp/composer-setup.php


EXPOSE 9000 23517
