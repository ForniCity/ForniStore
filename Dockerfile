# --- Estágio de assets (Node) ---
FROM node:18-alpine AS assets
WORKDIR /app

# Instala dependências JS
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copia o projeto para compilar assets (Mix)
COPY . .
# Se não existir "build", usa "prod" (Laravel Mix)
RUN npm run build || npm run prod


# --- Estágio final (PHP-FPM + Nginx + Composer) ---
FROM php:8.2-fpm-alpine

# Pacotes do sistema
RUN apk add --no-cache \
    nginx supervisor bash curl git unzip \
    icu-dev oniguruma-dev postgresql-dev libzip-dev \
    libjpeg-turbo-dev libpng-dev freetype-dev \
    libpq gettext

# Extensões PHP (GD com JPEG/FT, pgsql, etc.)
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) \
    gd bcmath exif intl zip pdo_pgsql opcache

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configs Nginx/PHP-FPM/Supervisor
RUN mkdir -p /run/nginx /etc/nginx/conf.d
COPY ./.docker/nginx.conf /etc/nginx/nginx.conf
COPY ./.docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY ./.docker/php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./.docker/zz-custom.ini     /usr/local/etc/php/conf.d/zz-custom.ini
COPY ./.docker/supervisord.conf  /etc/supervisor/conf.d/supervisord.conf

# Entrypoint
COPY ./.docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Código da aplicação
ENV APP_DIR=/var/www/azuriom
WORKDIR ${APP_DIR}
COPY . ${APP_DIR}

# >>> COPIA TUDO QUE FOI GERADO PELO MIX <<<
# Já existiam as cópias de /build, /css e /js; faltava /vendor (origem dos seus 404)
COPY --from=assets /app/public/build ${APP_DIR}/public/build 2>/dev/null || true
COPY --from=assets /app/public/css   ${APP_DIR}/public/css   2>/dev/null || true
COPY --from=assets /app/public/js    ${APP_DIR}/public/js    2>/dev/null || true
COPY --from=assets /app/public/vendor ${APP_DIR}/public/vendor 2>/dev/null || true
COPY --from=assets /app/public/mix-manifest.json ${APP_DIR}/public/mix-manifest.json 2>/dev/null || true

# Dependências PHP de produção
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader \
 && chown -R www-data:www-data ${APP_DIR}

# Permissões para caches do Laravel
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rw storage bootstrap/cache

# Processo inicial: supervisord (gerencia php-fpm e nginx)
EXPOSE 8080
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
