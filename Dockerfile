FROM php:7.0-fpm

RUN apt-get update && apt-get install -y \
        git \
        libzip-dev \
        zip \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        nginx \
        supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install \
        pdo_mysql \
        bcmath \
        zip

RUN pecl install redis \
    && pecl install grpc \
    && pecl install protobuf \
    && docker-php-ext-enable redis grpc protobuf

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
ADD conf/php-user.ini $PHP_INI_DIR/conf.d/
ADD conf/sources.list /etc/apt/sources.list
ADD conf/supervisor/ /etc/supervisor/conf.d/

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

WORKDIR /var/www/html

CMD ["supervisord","-n"]