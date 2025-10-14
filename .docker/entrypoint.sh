#!/usr/bin/env bash
set -e

APP_DIR="/var/www/azuriom"

# Permissões básicas
chown -R www-data:www-data "$APP_DIR/storage" "$APP_DIR/bootstrap/cache" || true

# Symlink do storage
if [ ! -L "$APP_DIR/public/storage" ] && [ -d "$APP_DIR/storage/app/public" ]; then
  ln -s "$APP_DIR/storage/app/public" "$APP_DIR/public/storage" || true
fi

# Inicia o PHP-FPM em background
php-fpm -D

# ⚙️ Scheduler do Laravel a cada 60s, em background
(
  echo "[scheduler] loop iniciado"
  while true; do
    php "$APP_DIR/artisan" schedule:run --no-interaction || true
    sleep 60
  done
) &

# Inicia o Nginx no foreground (mantém o container vivo)
nginx -g "daemon off;"
