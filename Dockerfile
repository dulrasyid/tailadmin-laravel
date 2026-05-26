FROM composer:latest AS composer

FROM ubuntu:22.04

RUN echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php8.1 \
    php8.1-cli \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-mysql \
    php8.1-gd \
    php8.1-zip \
    unzip \
    curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer


WORKDIR /var/www/tailadmin

COPY . .

RUN npm install && npm run production

RUN composer install --optimize-autoloader --no-dev

RUN cp .env.example .env && php artisan key:generate

RUN mkdir -p storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8090
CMD ["/entrypoint.sh"]
