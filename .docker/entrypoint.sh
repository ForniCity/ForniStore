#!/usr/bin/env bash
set -euo pipefail

# Ajuste de timezone (opcional)
if [ -n "${TZ:-}" ]; then
  echo "$TZ" > /etc/timezone || true
fi

mkdir -p /run/nginx

# Coloque aqui comandos de preparação se precisar:
# php artisan migrate --force || true

exec /usr/bin/supervisord -c /etc/supervisord.conf
