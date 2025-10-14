# ============================
# Etapa 1 — Build de assets
# ============================
FROM node:18-alpine AS assets
WORKDIR /app

COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

COPY . .
# use o script que você tiver no package.json (build ou prod)
RUN npm run build || npm run prod

# ============================
# Etapa 2 — Runtime (PHP + Nginx)
# ============================
FROM php:8.2-fpm-alpine

# Pacotes de sistema
RUN apk add --no-cache \
    nginx supervisor bash curl git unzip \
    icu-dev oniguruma-dev postgresql-dev libzip-dev \
    libjpeg-turbo-dev libpng-dev freetype-dev \
    libpq gettext tzdata

# Extensões PHP
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) gd bcmath exif intl zip pdo_pgsql opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Pastas e configs
RUN mkdir -p /run/nginx /etc/nginx/conf.d

# Configs customizadas
COPY ./.docker/nginx.conf                /etc/nginx/nginx.conf
COPY ./.docker/nginx-default.conf        /etc/nginx/conf.d/default.conf
COPY ./.docker/php-fpm-www.conf          /usr/local/etc/php-fpm.d/www.conf
COPY ./.docker/zz-custom.ini             /usr/local/etc/php/conf.d/zz-custom.ini
COPY ./.docker/supervisord.conf          /etc/supervisor/conf.d/supervisord.conf
COPY ./.docker/entrypoint.sh             /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Diretório da aplicação
ENV APP_DIR=/var/www/azuriom
ENV DATA_DIR=/data
WORKDIR ${APP_DIR}

# Código do app
COPY . ${APP_DIR}
# Assets gerados
COPY --from=assets /app/public/ ${APP_DIR}/public/

# Dependências PHP (produção)
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Permissões
RUN mkdir -p storage bootstrap/cache ${DATA_DIR} \
 && chown -R www-data:www-data ${APP_DIR} ${DATA_DIR} \
 && chmod -R ug+rw storage bootstrap/cache

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/conf.d/supervisord.conf"]
