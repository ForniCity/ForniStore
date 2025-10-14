FROM composer:2 AS composer_stage

FROM php:8.3-fpm-alpine

# Diretório da aplicação
ENV APP_DIR=/var/www/azuriom

# Copiamos o binário do Composer do stage
COPY --from=composer_stage /usr/bin/composer /usr/bin/composer

# Pacotes e extensões PHP
RUN set -eux; \
    apk add --no-cache \
      nginx supervisor bash curl git tzdata ca-certificates \
      libjpeg-turbo-dev libpng-dev libwebp-dev freetype-dev \
      postgresql-dev icu-dev oniguruma-dev; \
    apk add --no-cache --virtual .build-deps \
      autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c; \
    docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype; \
    docker-php-ext-install -j"$(nproc)" gd exif bcmath pdo pdo_pgsql opcache intl mbstring; \
    apk del .build-deps; \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Diretórios de runtime e da app
RUN set -eux; \
    mkdir -p /run/nginx /etc/nginx/conf.d /var/log/nginx "${APP_DIR}"

# Configurações
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY .docker/zz-custom.ini /usr/local/etc/php/conf.d/zz-custom.ini
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Permissões
RUN set -eux; \
    mkdir -p /var/log/supervisor /var/log/nginx "${APP_DIR}"; \
    chown -R www-data:www-data "${APP_DIR}"; \
    chown -R root:root /var/log/supervisor /var/log/nginx /run/nginx

# Código da aplicação (se você usa volume em runtime, isso será sobrescrito — tudo bem)
WORKDIR ${APP_DIR}
COPY --chown=www-data:www-data . ${APP_DIR}

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
