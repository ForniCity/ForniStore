# === Stage 1: Composer (instala dependências do Azuriom) ===
FROM composer:2 AS vendor
WORKDIR /app
# copie apenas os manifestos para aproveitar cache
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-progress --no-interaction

# === Stage 2: App (PHP-FPM + Nginx) ===
FROM php:8.3-fpm-alpine

# Pacotes e extensões
RUN apk add --no-cache git curl zip unzip libzip-dev postgresql-dev openssl nginx \
 && docker-php-ext-install pdo pdo_pgsql bcmath zip

# Diretório da aplicação (mesmo dos seus logs)
WORKDIR /var/www/azuriom

# Código do Azuriom
COPY --chown=www-data:www-data . /var/www/azuriom/

# Copia vendor do stage do Composer
COPY --from=vendor /app/vendor /var/www/azuriom/vendor

# Nginx + entrypoint (paths ajustados para /var/www/azuriom)
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Porta pública do Railway
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sh","-lc","php-fpm -D && nginx -g 'daemon off;'"]
