FROM php:8.3-fpm-alpine

# Diretório da aplicação
ENV APP_DIR=/var/www/azuriom

# Pacotes e extensões
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
# Criamos o APP_DIR aqui e TAMBÉM no passo que faz o chown, para não depender de ordem/camadas.
RUN set -eux; \
    mkdir -p /run/nginx /etc/nginx/conf.d /var/log/nginx "${APP_DIR}"

# Copia configs
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY .docker/zz-custom.ini /usr/local/etc/php/conf.d/zz-custom.ini
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Permissão do entrypoint
RUN chmod +x /usr/local/bin/entrypoint.sh

# Este é o ponto onde sua build falhava — agora garantimos o diretório ANTES do chown
RUN set -eux; \
    mkdir -p /run/nginx /etc/nginx/conf.d /var/log/supervisor /var/log/nginx "${APP_DIR}"; \
    chown -R www-data:www-data "${APP_DIR}"; \
    chown -R root:root /var/log/supervisor /var/log/nginx /run/nginx

# Define workdir (agora certamente existe)
WORKDIR ${APP_DIR}

# (Opcional) copie o código já com dono www-data
# Remova se for montar volume em runtime.
COPY --chown=www-data:www-data . ${APP_DIR}

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
