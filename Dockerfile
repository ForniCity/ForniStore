# === Stage 1: Composer (precisa do CÓDIGO INTEIRO) ===
FROM composer:2 AS vendor
WORKDIR /app
# Copie TODO o projeto, não apenas composer.json/lock
COPY . /app
# Instala as deps com autoloader otimizado
RUN composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader

# === Stage 2: App (PHP-FPM + Nginx) ===
FROM php:8.3-fpm-alpine

# Pacotes e extensões
RUN apk add --no-cache git curl zip unzip libzip-dev postgresql-dev openssl nginx \
 && docker-php-ext-install pdo pdo_pgsql bcmath zip

# Diretório da aplicação
WORKDIR /var/www/azuriom

# Copie o código da app e depois o vendor gerado no estágio anterior
COPY --chown=www-data:www-data . /var/www/azuriom/
COPY --from=vendor /app/vendor /var/www/azuriom/vendor

# Nginx + entrypoint
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Porta pública do Railway
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sh","-lc","php-fpm -D && nginx -g 'daemon off;'"]
