#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/azuriom"
PORT_DEFAULT="${PORT:-8080}"

# Injetar $PORT no Nginx em runtime
if command -v envsubst >/dev/null 2>&1; then
  envsubst '$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
  mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf
else
  sed -e "s|\${PORT}|${PORT_DEFAULT}|g" -i /etc/nginx/conf.d/default.conf
fi

cd "$APP_DIR"

echo ">> Ajustando permissões..."
chown -R www-data:www-data "$APP_DIR"
chmod -R ug+rwX "$APP_DIR/storage" "$APP_DIR/bootstrap/cache" 2>/dev/null || true
find storage bootstrap/cache -type d -exec chmod 775 {} \; 2>/dev/null || true

# .env: cria se não existir (Composer já rodou no build)
if [ ! -f ".env" ]; then
  echo ">> .env não existe — copiando de .env.example"
  cp -n .env.example .env || true
  chown www-data:www-data .env
  su -s /bin/sh -c 'php artisan key:generate --force || true' www-data
fi

# storage:link com fallback quando symlink não é permitido
if [ ! -e "public/storage" ]; then
  echo ">> Criando storage:link (com fallback)"
  if su -s /bin/sh -c 'php artisan storage:link' www-data; then
    echo ">> symlink criado."
  else
    echo ">> symlink negado — fallback: cópia recursiva"
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

echo ">> Iniciando serviços na porta ${PORT_DEFAULT}..."
exec "$@"
