#!/usr/bin/env bash
set -e

# Ajusta permissões do diretório do app
chown -R www-data:www-data /var/www/azuriom || true

# Garante diretórios de runtime do nginx
mkdir -p /run/nginx /var/log/nginx

exec "$@"
