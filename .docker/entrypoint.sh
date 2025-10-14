#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/azuriom"
PORT_DEFAULT="${PORT:-8080}"

# Evita conflito de server duplicado
[ -f /etc/nginx/conf.d/azuriom.conf ] && rm -f /etc/nginx/conf.d/azuriom.conf || true

# Injeta $PORT no Nginx
if command -v envsubst >/dev/null 2>&1; then
  envsubst '$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
  mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf
else
  sed -e "s|\${PORT}|${PORT_DEFAULT}|g" -i /etc/nginx/conf.d/default.conf
fi

cd "$APP_DIR"

# .env
if [ ! -f ".env" ]; then
  echo ">> Gerando .env"
  cp .env.example .env || true
fi

# Ajusta dono/perm do .env
chown www-data:www-data .env || true
chmod 664 .env || true

# Helpers para .env
ensure_env () {
  KEY="$1"; VAL="$2"
  if grep -qE "^${KEY}=" .env; then
    sed -i "s|^${KEY}=.*|${KEY}=${VAL}|g" .env
  else
    echo "${KEY}=${VAL}" >> .env
  fi
}

# Confia no proxy e (opcional) fixa ASSET_URL
ensure_env "TRUSTED_PROXIES" "*"
ensure_env "TRUSTED_HEADERS" "X_FORWARDED_FOR,X_FORWARDED_HOST,X_FORWARDED_PORT,X_FORWARDED_PROTO,X_FORWARDED_AWS_ELB"
if [ -n "${ASSET_URL:-}" ]; then ensure_env "ASSET_URL" "${ASSET_URL}"; fi

# APP_KEY
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

# Permissões essenciais
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rw storage bootstrap/cache || true

# storage:link com fallback
if [ ! -e "public/storage" ]; then
  if ! su -s /bin/sh -c 'php artisan storage:link' www-data; then
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

# 🔧 COMPAT: alguns temas esperam /assets/* (ex: /assets/vendor/…)
#         Cria um symlink public/assets -> public
if [ ! -e "public/assets" ]; then
  ln -sfn . public/assets
  echo ">> Link de compat criado: public/assets -> public"
fi

# Limpa caches
su -s /bin/sh -c 'php artisan config:clear || true' www-data
su -s /bin/sh -c 'php artisan route:clear || true' www-data

# Migrações com retry
RETRIES=12; SLEEP=5
for i in $(seq 1 $RETRIES); do
  if su -s /bin/sh -c 'php artisan migrate --force' www-data; then
    break
  fi
  sleep $SLEEP
done

echo ">> Iniciando serviços na porta ${PORT_DEFAULT}..."
exec "$@"
