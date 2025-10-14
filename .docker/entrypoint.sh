#!/usr/bin/env bash
set -e

# Ajustes de permissões
chown -R www:www /var/www/html/storage /var/www/html/bootstrap/cache || true

# Garante link de storage (Laravel)
if [ ! -L /var/www/html/public/storage ] && [ -d /var/www/html/storage/app/public ]; then
  ln -s /var/www/html/storage/app/public /var/www/html/public/storage || true
fi

# Inicia php-fpm e nginx no mesmo container
php-fpm -D
nginx -g "daemon off;"
