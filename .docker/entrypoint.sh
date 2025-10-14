#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/var/www/azuriom}"
DATA_DIR="${DATA_DIR:-/data}"
PORT_DEFAULT="${PORT:-8080}"

echo ">> ENTRYPOINT | APP_DIR=${APP_DIR} DATA_DIR=${DATA_DIR} PORT=${PORT_DEFAULT}"

# ——— Nginx: injeta porta no default.conf
if command -v envsubst >/dev/null 2>&1; then
  envsubst '$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
  mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf
else
  sed -i "s|\${PORT}|${PORT_DEFAULT}|g" /etc/nginx/conf.d/default.conf
fi

cd "$APP_DIR"

# ——— garante o diretório de dados
mkdir -p "${DATA_DIR}"
chown -R www-data:www-data "${DATA_DIR}"

# ——— persistência do .env
if [ -f "${DATA_DIR}/.env" ]; then
  echo ">> Reusando ${DATA_DIR}/.env"
  ln -sfn "${DATA_DIR}/.env" "${APP_DIR}/.env"
else
  echo ">> Criando .env novo em ${DATA_DIR}/.env"
  if [ -f "${APP_DIR}/.env" ]; then
    mv "${APP_DIR}/.env" "${DATA_DIR}/.env"
  else
    cp "${APP_DIR}/.env.example" "${DATA_DIR}/.env"
  fi
  ln -sfn "${DATA_DIR}/.env" "${APP_DIR}/.env"
fi
chown -h www-data:www-data "${APP_DIR}/.env" || true
chmod 664 "${DATA_DIR}/.env" || true

# ——— persistência do storage
if [ ! -d "${DATA_DIR}/storage" ]; then
  echo ">> Movendo storage/ para ${DATA_DIR}/storage"
  mkdir -p "${DATA_DIR}"
  mv "${APP_DIR}/storage" "${DATA_DIR}/storage"
fi
rm -rf "${APP_DIR}/storage"
ln -sfn "${DATA_DIR}/storage" "${APP_DIR}/storage"
chown -R www-data:www-data "${DATA_DIR}/storage" || true
chmod -R ug+rw "${DATA_DIR}/storage" || true

# ——— App key (idempotente)
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

# ——— Permissões essenciais
chown -R www-data:www-data bootstrap/cache || true
chmod -R ug+rw bootstrap/cache || true

# ——— storage:link com fallback
if [ ! -e "public/storage" ]; then
  if ! su -s /bin/sh -c 'php artisan storage:link' www-data; then
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

# ——— limpa caches
su -s /bin/sh -c 'php artisan config:clear || true' www-data
su -s /bin/sh -c 'php artisan route:clear || true' www-data
su -s /bin/sh -c 'php artisan view:clear || true' www-data

# ——— migrações com retry (banco pode demorar a subir)
RETRIES=12; SLEEP=5
for i in $(seq 1 $RETRIES); do
  if su -s /bin/sh -c 'php artisan migrate --force' www-data; then
    break
  fi
  echo ">> migrate tentativa $i/${RETRIES} — aguardando DB..."
  sleep $SLEEP
done

echo ">> Pronto. Subindo serviços…"
exec "$@"
