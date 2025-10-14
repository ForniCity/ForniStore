# ============================
# Etapa 1 — Compila os assets (Node)
# ============================
FROM node:18-alpine AS assets
WORKDIR /app

# Instala dependências do Node
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copia o projeto inteiro para compilar os assets
COPY . .

# Compila os assets (Laravel Mix)
RUN npm run build || npm run prod


# ============================
# Etapa 2 — Container final (PHP + Nginx)
# ============================
FROM php:8.2-fpm-alpine

# Instala pacotes de sistema necessários
RUN apk add --no-cache \
    nginx supervisor bash curl git unzip \
    icu-dev oniguruma-dev postgresql-dev libzip-dev \
    libjpeg-turbo-dev libpng-dev freetype-dev \
    libpq gettext

# Extensões PHP obrigatórias
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) \
    gd bcmath exif intl zip pdo_pgsql opcache

# Instala o Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ============================
# Configurações Nginx / PHP / Supervisor
# ============================
RUN mkdir -p /run/nginx /etc/nginx/conf.d

COPY ./.docker/nginx.conf /etc/nginx/nginx.conf
COPY ./.docker/nginx-default.conf /etc/nginx/conf.d/default.conf
COPY ./.docker/php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./.docker/zz-custom.ini /usr/local/etc/php/conf.d/zz-custom.ini
COPY ./.docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./.docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# ============================
# Código da aplicação
# ============================
ENV APP_DIR=/var/www/azuriom
WORKDIR ${APP_DIR}

# Copia o código da aplicação Laravel/Azuriom
COPY . ${APP_DIR}

# Copia tudo da pasta public gerado pelo Node
COPY --from=assets /app/public/ ${APP_DIR}/public/

# Instala dependências PHP (somente produção)
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Ajusta permissões corretas
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data ${APP_DIR} \
 && chmod -R ug+rw storage bootstrap/cache

# ============================
# Inicialização
# ============================
EXPOSE 8080
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
