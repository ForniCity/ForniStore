# Dockerfile para Nginx + PHP-FPM + Supervisor (Alpine)
FROM php:8.3-fpm-alpine

# Diretório da aplicação
ENV APP_DIR=/var/www/azuriom

# Pacotes e extensões PHP necessários
RUN set -eux; \
    apk add --no-cache \
      nginx supervisor bash curl git tzdata ca-certificates \
      libjpeg-turbo-dev libpng-dev libwebp-dev freetype-dev \
      postgresql-dev icu-dev oniguruma-dev; \
    apk add --no-cache --virtual .build-deps \
      autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c; \
    docker-php-ext-configure gd \
      --with-jpeg \
      --with-webp \
      --with-freetype; \
    docker-php-ext-install -j"$(nproc)" \
      gd exif bcmath pdo pdo_pgsql opcache intl mbstring; \
    apk del .build-deps; \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Diretórios necessários (inclui o APP_DIR) e alguns logs/sockets
RUN set -eux; \
    mkdir -p /run/nginx /etc/nginx/conf.d /var/log/nginx "${APP_DIR}"

# Define o diretório de trabalho (agora ele com certeza existe)
WORKDIR ${APP_DIR}

# Copia configurações primeiro (melhor cache)
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY .docker/zz-custom.ini /usr/local/etc/php/conf.d/zz-custom.ini
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Permissões de execução do entrypoint
RUN chmod +x /usr/local/bin/entrypoint.sh

# (Opcional) Copia o código da aplicação já com dono www-data
# Se você montar via volume no run/compose, pode remover esta linha.
COPY --chown=www-data:www-data . ${APP_DIR}

# Porta do Nginx (usar 8080 evita necessidade de root para bind)
EXPOSE 8080

# Inicia tudo pelo Supervisor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
