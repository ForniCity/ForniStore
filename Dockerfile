# =============================================================================
# Azuriom + PHP 8.3 FPM + Nginx (Alpine) — pronto para Railway
# =============================================================================
FROM alpine:3.20

ENV APP_DIR=/var/www/azuriom \
    COMPOSER_ALLOW_SUPERUSER=1

# Sistema + PHP + Nginx + Supervisor + Composer
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
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
  addgroup -g 82 -S www-data || true; \
  adduser  -u 82 -D -S -G www-data www-data || true; \
  mkdir -p ${APP_DIR} /run/nginx /var/log/supervisor

WORKDIR ${APP_DIR}

# Copia o código do app
COPY . ${APP_DIR}

# Permissões essenciais
RUN chown -R www-data:www-data ${APP_DIR} \
 && find ${APP_DIR}/storage ${APP_DIR}/bootstrap/cache -type d -exec chmod 775 {} \; || true \
 && chmod -R ug+rwX ${APP_DIR}/storage ${APP_DIR}/bootstrap/cache ${APP_DIR}/public

# Configuração (agora em .docker/)
COPY .docker/nginx.conf       /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/zz-custom.ini    /etc/php83/conf.d/zz-custom.ini
COPY .docker/entrypoint.sh    /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080
HEALTHCHECK CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
