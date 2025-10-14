# Base com PHP-FPM 8.3 em Alpine
FROM php:8.3-fpm-alpine

# Variáveis
ENV APP_DIR=/var/www/azuriom \
    PHP_INI_DIR=/usr/local/etc/php

# Pacotes de sistema (nginx, supervisor, libs)
RUN apk add --no-cache \
      nginx supervisor bash curl git tzdata ca-certificates \
      libjpeg-turbo-dev libpng-dev libwebp-dev freetype-dev \
      postgresql-dev \
      icu-dev oniguruma-dev \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
      autoconf make g++ \
    # GD com JPEG/WEBP/FreeType
    && docker-php-ext-configure gd \
         --with-jpeg \
         --with-webp \
         --with-freetype \
    # Extensões PHP conforme seus logs
    && docker-php-ext-install -j"$(nproc)" \
         gd exif bcmath pdo pdo_pgsql opcache \
    # Limpa dependências de build
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Diretórios necessários e permissões
RUN mkdir -p /run/nginx /etc/nginx/conf.d \
    /var/log/supervisor /var/log/nginx \
    && chown -R www-data:www-data ${APP_DIR} \
    && chown -R root:root /var/log/supervisor /var/log/nginx /run/nginx

# App
WORKDIR ${APP_DIR}

# Copia configs
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY .docker/zz-custom.ini ${PHP_INI_DIR}/conf.d/zz-custom.ini
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Permissões do entrypoint
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

# Inicia via supervisord (Nginx + PHP-FPM)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
