#!/usr/bin/env bash
set -e

APP_DIR="/var/www/azuriom"

# Permissões mínimas para Laravel/Azuriom
chown -R www-data:www-data "$APP_DIR/storage" "$APP_DIR/bootstrap/cache" || true

# Symlink public/storage -> storage/app/public
if [ ! -L "$APP_DIR/public/storage" ] && [ -d "$APP_DIR/storage/app/public" ]; then
  ln -s "$APP_DIR/storage/app/public" "$APP_DIR/public/storage" || true
fi

# Teste de sintaxe do Nginx (falha cedo se houver erro)
nginx -t || { echo "[entrypoint] nginx.conf inválido"; exit 1; }

# Inicia PHP-FPM em background
php-fpm -D

# Loop do scheduler do Laravel (a cada 60s), em background
(
  echo "[scheduler] loop iniciado"
  while true; do
    php "$APP_DIR/artisan" schedule:run --no-interaction || true
    sleep 60
  done
) &

# Nginx no foreground mantém o container vivo
nginx -g "daemon off;"
