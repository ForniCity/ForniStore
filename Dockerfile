# === Stage 1: Composer (precisa do CÓDIGO INTEIRO) ===
FROM composer:2 AS vendor
WORKDIR /app

# Copie TODO o projeto para que scripts do composer enxerguem os arquivos da app
COPY . /app

# Instala as dependências sem dev e com autoloader otimizado
RUN composer install --no-dev --prefer-dist --no-progress --no-interaction --optimize-autoloader

# === Stage 2: App (PHP-FPM + Nginx) ===
FROM php:8.3-fpm-alpine

# Pacotes base + Nginx e extensões PHP usadas pelo Azuriom
RUN apk add --no-cache \
      git curl zip unzip openssl nginx libzip-dev postgresql-dev \
 && docker-php-ext-install pdo pdo_pgsql bcmath zip

# Diretório da aplicação
WORKDIR /var/www/azuriom

# Código do Azuriom
COPY --chown=www-data:www-data . /var/www/azuriom/

# Dependências PHP (vendor) geradas no estágio do Composer
COPY --from=vendor /app/vendor /var/www/azuriom/vendor

# Configurações do Nginx (global + vhost)
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/azuriom.conf /etc/nginx/conf.d/azuriom.conf

# Entrypoint com scheduler embutido
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Porta pública (Railway injeta $PORT; 8080 é fallback local)
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sh","-lc","php-fpm -D && nginx -g 'daemon off;'"]
