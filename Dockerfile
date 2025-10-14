# =========================================
# Azuriom - PHP 8.3 FPM (Alpine) + Nginx
# Railway-ready (porta via $PORT)
# =========================================

FROM php:8.3-fpm-alpine

# ----- Variáveis úteis -----
ENV APP_DIR=/var/www/azuriom \
    PORT=8080 \
    TZ=UTC

# ----- SO + libs + PHP extensions (inclui ext-zip e pgsql) -----
RUN apk add --no-cache \
        nginx supervisor bash curl git tzdata ca-certificates \
        libjpeg-turbo-dev libpng-dev libwebp-dev freetype-dev \
        postgresql-dev icu-dev oniguruma-dev \
        libzip-dev zlib-dev \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS g++ gcc make pkgconf re2c \
    && docker-php-ext-configure gd \
        --with-jpeg \
        --with-webp \
        --with-freetype \
    && docker-php-ext-install -j"$(nproc)" \
        gd exif bcmath intl pdo pdo_pgsql zip opcache \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# ----- Composer (multi-stage "light") -----
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ----- Diretórios do sistema + permissões -----
RUN mkdir -p /run/nginx /etc/nginx/conf.d \
              /var/log/supervisor /var/log/nginx \
              ${APP_DIR} \
    && chown -R www-data:www-data ${APP_DIR} \
    && chown -R root:root /var/log/supervisor /var/log/nginx /run/nginx

# ----- Código da aplicação -----
WORKDIR ${APP_DIR}

# Copie seu código (incluindo composer.json) para dentro da imagem
# OBS: se você usar .dockerignore, garanta que vendor/ esteja ignorado
COPY . ${APP_DIR}

# ----- Arquivos de configuração (coloque-os na sua pasta .docker/) -----
# nginx.conf, default.conf, supervisor, php.ini custom e entrypoint
COPY .docker/nginx.conf                     /etc/nginx/nginx.conf
COPY .docker/nginx-default.conf             /etc/nginx/conf.d/default.conf
COPY .docker/supervisord.conf               /etc/supervisord.conf
COPY .docker/zz-custom.ini                  /usr/local/etc/php/conf.d/zz-custom.ini
COPY .docker/entrypoint.sh                  /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ----- Garante que o .env.example exista (fallback para instalação) -----
# Se o repositório já tiver o arquivo, este bloco não sobrescreve.
RUN if [ ! -f ".env.example" ]; then \
      printf "%s\n" \
"APP_NAME=Azuriom" \
"APP_ENV=production" \
"APP_KEY=" \
"APP_DEBUG=false" \
"APP_TIMEZONE=UTC" \
"APP_URL=http://localhost" \
"" \
"APP_LOCALE=pt_BR" \
"" \
"APP_MAINTENANCE_DRIVER=file" \
"" \
"AZURIOM_GAME=mc-offline" \
"BCRYPT_ROUNDS=12" \
"" \
"LOG_CHANNEL=stack" \
"LOG_STACK=daily" \
"LOG_DEPRECATIONS_CHANNEL=null" \
"LOG_LEVEL=warning" \
"" \
"DB_CONNECTION=pgsql" \
"DB_HOST=\${PGHOST:-postgres.railway.internal}" \
"DB_PORT=\${PGPORT:-5432}" \
"DB_DATABASE=\${PGDATABASE:-railway}" \
"DB_USERNAME=\${PGUSER:-postgres}" \
"DB_PASSWORD=\${PGPASSWORD:-}" \
"" \
"SESSION_DRIVER=file" \
"SESSION_LIFETIME=120" \
"SESSION_ENCRYPT=false" \
"SESSION_PATH=/" \
"SESSION_DOMAIN=null" \
"" \
"BROADCAST_CONNECTION=log" \
"FILESYSTEM_DISK=public" \
"QUEUE_CONNECTION=sync" \
"" \
"CACHE_DRIVER=file" \
"CACHE_PREFIX=" \
"" \
"MAIL_MAILER=smtp" \
"MAIL_SCHEME=null" \
"MAIL_HOST=" \
"MAIL_PORT=587" \
"MAIL_USERNAME=" \
"MAIL_PASSWORD=" \
"MAIL_FROM_ADDRESS=\"no-reply@exemplo.com\"" \
"MAIL_FROM_NAME=\"\${APP_NAME}\"" \
> .env.example ; \
    fi

# ----- Permissões para storage/cache (Laravel) -----
RUN mkdir -p ${APP_DIR}/storage ${APP_DIR}/bootstrap/cache \
    && chown -R www-data:www-data ${APP_DIR}/storage ${APP_DIR}/bootstrap/cache

# ----- Expose (Railway usa $PORT automaticamente) -----
EXPOSE 8080

# ----- Start -----
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
