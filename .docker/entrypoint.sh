#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/azuriom"

cd "${APP_DIR}"

echo ">> Ajustando permissões..."
chown -R www-data:www-data "${APP_DIR}"
chmod -R ug+rwX "${APP_DIR}/storage" "${APP_DIR}/bootstrap/cache" "${APP_DIR}/public" || true

# ----------------------------------------------------------------------
# Garante .env.example e .env
# ----------------------------------------------------------------------
if [ ! -f ".env.example" ]; then
  echo ">> .env.example não encontrado — criando um padrão..."
  cat > .env.example <<'EOF'
APP_NAME=Azuriom
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_TIMEZONE=UTC
APP_URL=http://localhost

APP_LOCALE=en
LOG_CHANNEL=stack
LOG_LEVEL=debug

AZURIOM_GAME=mc-offline

DB_CONNECTION=pgsql
DB_HOST=postgres.railway.internal
DB_PORT=5432
DB_DATABASE=railway
DB_USERNAME=postgres
DB_PASSWORD=

SESSION_DRIVER=file
QUEUE_CONNECTION=sync
CACHE_DRIVER=file
FILESYSTEM_DISK=local
EOF
  chown www-data:www-data .env.example
fi

if [ ! -f ".env" ]; then
  echo ">> .env não existe — copiando de .env.example"
  cp .env.example .env
  chown www-data:www-data .env
fi

# ----------------------------------------------------------------------
# Composer (instala vendor se estiver ausente)
# ----------------------------------------------------------------------
if [ ! -d "vendor" ]; then
  echo ">> vendor/ ausente. Executando Composer..."
  if [ -f "composer.lock" ]; then
    composer install --no-dev --prefer-dist --no-progress --no-interaction
  else
    echo ">> Sem composer.lock — rodando 'composer update' (produção)."
    composer update --no-dev --prefer-dist --no-progress --no-interaction
  fi
fi

# ----------------------------------------------------------------------
# Tarefas do Laravel/Azuriom executadas como www-data
# ----------------------------------------------------------------------
echo ">> Preparando app (artisan)..."
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

# storage:link com fallback
if [ ! -L "public/storage" ]; then
  rm -rf public/storage
  if su -s /bin/sh -c 'php artisan storage:link' www-data; then
    echo ">> storage:link criado com sucesso."
  else
    echo ">> Falhou criar symlink — executando fallback (cópia)."
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

# Pastas críticas sempre graváveis
find storage bootstrap/cache -type d -exec chmod 775 {} \; || true

echo ">> Subindo serviços..."
exec "$@"
