#!/usr/bin/env bash
set -euo pipefail

# Ajuste de timezone do sistema (opcional)
if [ -n "${TZ:-}" ]; then
  echo "$TZ" > /etc/timezone || true
fi

# Garante que diretórios de runtime existem
mkdir -p /run/nginx

# Dica: se precisar rodar migrações, seeds, etc., faça aqui:
# php artisan migrate --force || true

# Sobe o Supervisor em primeiro plano (logs no STDOUT/ERR)
exec /usr/bin/supervisord -c /etc/supervisord.conf
