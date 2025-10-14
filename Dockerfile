# ---- Estágio 1: build dos assets (Node) ----
FROM node:18-alpine AS assets
WORKDIR /app

# Cache de dependências
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copia projeto e compila (Vite/Mix)
COPY . .
RUN npm run build || npm run prod || npm run production || true

# ---- Estágio 2: app PHP-FPM + Nginx ----
FROM php:8.2-fpm-alpine

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APP_DIR=/var/www/azuriom

# Dependências do sistema
RUN apk add --no-cache \
    nginx supervisor bash curl git unzip \
    icu-dev oniguruma-dev postgresql-dev libzip-dev \
    libjpeg-turbo-dev libpng-dev freetype-dev \
    libpq gettext

# Extensões PHP
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) \
    gd bcmath exif intl zip pdo_pgsql opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Diretórios necessários
RUN mkdir -p /run/nginx /etc/nginx/conf.d

# ---- Configs runtime (em .docker/) ----
COPY ./.docker/nginx.conf           /etc/nginx/nginx.conf
COPY ./.docker/nginx-default.conf   /etc/nginx/conf.d/default.conf
COPY ./.docker/php-fpm-www.conf     /usr/local/etc/php-fpm.d/www.conf
COPY ./.docker/zz-custom.ini        /usr/local/etc/php/conf.d/zz-custom.ini
COPY ./.docker/supervisord.conf     /etc/supervisor/conf.d/supervisord.conf
COPY ./.docker/entrypoint.sh        /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Código da aplicação
WORKDIR ${APP_DIR}
COPY . ${APP_DIR}

# Copia assets compilados do estágio Node (forma segura)
COPY --from=assets /app/public /tmp/assets-public
RUN set -eux; \
    mkdir -p ${APP_DIR}/public; \
    if [ -d /tmp/assets-public/build ];  then cp -R /tmp/assets-public/build  ${APP_DIR}/public/;  fi; \
    if [ -d /tmp/assets-public/css ];    then cp -R /tmp/assets-public/css    ${APP_DIR}/public/;  fi; \
    if [ -d /tmp/assets-public/js ];     then cp -R /tmp/assets-public/js     ${APP_DIR}/public/;  fi; \
    if [ -d /tmp/assets-public/vendor ]; then cp -R /tmp/assets-public/vendor ${APP_DIR}/public/;  fi; \
    if [ -d /tmp/assets-public/themes ]; then cp -R /tmp/assets-public/themes ${APP_DIR}/public/;  fi; \
    if [ -f /tmp/assets-public/mix-manifest.json ]; then cp /tmp/assets-public/mix-manifest.json ${APP_DIR}/public/; fi

# Dependências PHP (produção)
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader \
 && chown -R www-data:www-data ${APP_DIR}

# Permissões essenciais
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rw storage bootstrap/cache

# Healthcheck opcional
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD \
  SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
