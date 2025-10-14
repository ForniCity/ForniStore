# =============================================================================
# Azuriom + PHP 8.3 FPM + Nginx (Alpine) — pronto para Railway
# =============================================================================
FROM alpine:3.20

ENV APP_DIR=/var/www/azuriom \
    PHP_INI_DIR=/usr/local/etc/php \
    COMPOSER_ALLOW_SUPERUSER=1

# -----------------------------------------------------------------------------
# Dependências do sistema (+ nginx, supervisor, composer e extensões PHP)
# -----------------------------------------------------------------------------
RUN set -eux; \
  apk add --no-cache \
    php83 php83-fpm php83-cli php83-opcache \
    php83-bcmath php83-exif php83-gd php83-intl \
    php83-mbstring php83-pdo php83-pdo_pgsql php83-pgsql \
    php83-zip php83-sockets php83-ctype php83-curl php83-dom \
    php83-fileinfo php83-phar php83-session php83-tokenizer php83-xml \
    php83-simplexml php83-xmlwriter php83-xmlreader php83-iconv \
    php83-pecl-redis php83-sodium \
    nginx supervisor curl unzip git bash tzdata ca-certificates \
    icu-data-full icu-libs libpng libjpeg-turbo freetype shadow; \
  \
  # composer
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
  \
  # usuário/grupo www-data (uid/gid 82 no Alpine)
  addgroup -g 82 -S www-data || true; \
  adduser  -u 82 -D -S -G www-data www-data || true; \
  \
  mkdir -p ${APP_DIR} /run/nginx /var/log/supervisor

# -----------------------------------------------------------------------------
# App
# -----------------------------------------------------------------------------
WORKDIR ${APP_DIR}
COPY . ${APP_DIR}

# Permissões — IMPORTANTÍSSIMO para o symlink e cache do Laravel
RUN chown -R www-data:www-data ${APP_DIR} \
 && find ${APP_DIR}/storage ${APP_DIR}/bootstrap/cache -type d -exec chmod 775 {} \; || true \
 && chmod -R ug+rwX ${APP_DIR}/storage ${APP_DIR}/bootstrap/cache ${APP_DIR}/public

# -----------------------------------------------------------------------------
# Nginx, PHP e Supervisor
# -----------------------------------------------------------------------------
COPY ./deploy/nginx.conf            /etc/nginx/nginx.conf
COPY ./deploy/supervisord.conf      /etc/supervisord.conf
COPY ./deploy/zz-custom.ini         /etc/php83/conf.d/zz-custom.ini
COPY ./deploy/entrypoint.sh         /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080
HEALTHCHECK CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
