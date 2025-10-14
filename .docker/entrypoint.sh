#!/usr/bin/env bash
set -e

chown -R www-data:www-data /var/www/azuriom/storage /var/www/azuriom/bootstrap/cache || true

if [ ! -L /var/www/azuriom/public/storage ] && [ -d /var/www/azuriom/storage/app/public ]; then
  ln -s /var/www/azuriom/storage/app/public /var/www/azuriom/public/storage || true
fi

exec "$@"
