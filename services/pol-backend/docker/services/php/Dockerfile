FROM php:7.4-fpm-alpine

# common dependencies
RUN apk add autoconf g++ gcc make

# installing php extenstions
RUN docker-php-ext-install pdo pdo_mysql

# composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer config --global repo.packagist composer https://packagist.org

WORKDIR /app

CMD ["php-fpm"]
