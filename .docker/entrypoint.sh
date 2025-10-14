#!/usr/bin/env bash
set -e

# Garante diretórios e permissões de runtime/log
mkdir -p /run/nginx /var/log/nginx /var/log/supervisor
chown -R root:root /run/nginx /var/log/nginx /var/log/supervisor

# App pertence ao www-data para o PHP-FPM
chown -R www-data:www-data /var/www/azuriom || true

exec "$@"
