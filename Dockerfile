# Base PHP-FPM com Alpine
FROM php:8.3-fpm-alpine

# Variáveis
ENV APP_DIR="/var/www/azuriom"

# Pacotes de sistema e extensões necessárias
RUN set -eux; \
    apk add --no-cache \
      nginx curl git bash supervisor \
      icu-dev oniguruma-dev libzip-dev \
      libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev \
      postgresql17-dev \
      $PHPIZE_DEPS; \
    docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype; \
    docker-php-ext-install -j$(nproc) \
      gd intl zip exif opcache bcmath pdo; \
    docker-php-ext-install -j$(nproc) pdo_pgsql; \
    # Usuário www-data já existe; criar diretórios exigidos por nginx/php
    mkdir -p /run/nginx /etc/nginx/conf.d "$APP_DIR"; \
    # Composer
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Diretório de trabalho
WORKDIR $APP_DIR

# Copia apenas o composer primeiro (cache de dependências)
COPY composer.json composer.lock ./
RUN set -eux; \
    composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader

# Copia o restante do projeto
COPY . .

# Copia configs do Nginx e o entrypoint
COPY .docker/azuriom.conf /etc/nginx/conf.d/azuriom.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Permissões e preparação
RUN set -eux; \
    chmod +x /usr/local/bin/entrypoint.sh; \
    chown -R www-data:www-data $APP_DIR; \
    # otimizadores do laravel (se .env já existir no build; se não, tudo bem pular)
    true

# Exponha a porta HTTP do Nginx
EXPOSE 80

# Entrypoint orquestra php-fpm + nginx
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
