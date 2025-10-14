FROM composer:2 AS composer_stage

FROM php:8.3-fpm-alpine

ENV APP_DIR=/var/www/azuriom

# Composer no runtime
COPY --from=composer_stage /usr/bin/composer /usr/bin/composer

# Pacotes e extensões PHP
RUN set -eux; \
    apk add --no-cache \
      nginx supervisor bash curl git tzdata ca-certificates \
      libjpeg-turbo-dev libpng-dev libwebp-dev freetype-dev \
      postgresql-dev icu-dev oniguruma-dev libzip-dev; \
    apk add --no-cache --virtual .build-deps \
      autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c; \
    docker-php-ext-configure gd --with-jpeg --with-webp --with-freetype; \
    docker-php-ext-install -j"$(nproc)" gd exif bcmath pdo pdo_pgsql opcache intl mbstring zip; \
    apk del .build-deps; \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Diretórios
RUN set -eux; \
    mkdir -p /run/nginx /etc/nginx/conf.d /var/log/nginx "${APP_DIR}"

# Configs
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

WORKDIR ${APP_DIR}
# Nota: se você monta volume em ${APP_DIR}, este COPY será sobrescrito no runtime (tudo bem).
COPY --chown=www-data:www-data . ${APP_DIR}

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
