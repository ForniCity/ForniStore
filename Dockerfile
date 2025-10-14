# ---- Estágio 1: build dos assets (Node) ----
FROM node:18-alpine AS assets
WORKDIR /app

# Copia apenas manifestos primeiro p/ cache
COPY package*.json ./
# Se não houver package-lock.json, isso não falha
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copia o restante do projeto e compila
COPY . .
# Tenta "build" (Vite). Se não existir, cai para "prod" (Laravel Mix)
RUN npm run build || npm run prod

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

# Extensões PHP necessárias (Laravel/Azuriom + PostgreSQL)
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) \
    gd bcmath exif intl zip pdo_pgsql opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Diretórios necessários
RUN mkdir -p /run/nginx /etc/nginx/conf.d

# ---- Config de runtime em .docker/ ----
COPY ./.docker/nginx.conf /etc/nginx/nginx.conf
COPY ./.docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY ./.docker/php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./.docker/zz-custom.ini     /usr/local/etc/php/conf.d/zz-custom.ini
COPY ./.docker/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf
COPY ./.docker/entrypoint.sh     /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Código da aplicação
WORKDIR ${APP_DIR}
COPY . ${APP_DIR}

# Copia os assets compilados do estágio Node
# Vite (Laravel 9+/10): public/build
# Mix (legado): public/css, public/js, public/mix-manifest.json
COPY --from=assets /app/public/build ${APP_DIR}/public/build 2>/dev/null || true
COPY --from=assets /app/public/css   ${APP_DIR}/public/css   2>/dev/null || true
COPY --from=assets /app/public/js    ${APP_DIR}/public/js    2>/dev/null || true
COPY --from=assets /app/public/mix-manifest.json ${APP_DIR}/public/mix-manifest.json 2>/dev/null || true

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
