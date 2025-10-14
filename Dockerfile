# ---- Base PHP-FPM com Alpine ----
FROM php:8.2-fpm-alpine

# Variáveis
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APP_DIR=/var/www/azuriom

# Dependências do sistema
RUN apk add --no-cache \
    nginx supervisor bash curl git unzip \
    icu-dev oniguruma-dev postgresql-dev libzip-dev \
    libjpeg-turbo-dev libpng-dev freetype-dev \
    libpq gettext

# Extensões PHP necessárias (Laravel/Azuriom + PostgreSQL)
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) \
    gd bcmath exif intl zip pdo_pgsql opcache

# Composer (copiado da imagem oficial)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Diretórios necessários
RUN mkdir -p /run/nginx /etc/nginx/conf.d

# ---- Configurações que te enviei ----
# Nginx
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx-default.conf /etc/nginx/conf.d/default.conf
# (NÃO copie azuriom.conf para evitar conflito de porta no Railway)

# PHP-FPM (pool) e ini custom
COPY ./php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./zz-custom.ini     /usr/local/etc/php/conf.d/zz-custom.ini

# Supervisor
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Entrypoint com migrações + envsubst do ${PORT}
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Código da aplicação
WORKDIR ${APP_DIR}
# Copie seu projeto (Azuriom) para dentro da imagem
# Se estiver usando o repositório do Azuriom como base do app, mantenha:
COPY . ${APP_DIR}

# Instala dependências do PHP (produção)
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader \
 && chown -R www-data:www-data ${APP_DIR}

# Permissões essenciais (garantia extra)
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rw storage bootstrap/cache

# Não exponha portas fixas — o Railway injeta ${PORT}
# HEALTHCHECK opcional (verifica PHP-FPM via ping)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD \
  SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

# Entrypoint + comando final (supervisor controla Nginx e PHP-FPM)
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
