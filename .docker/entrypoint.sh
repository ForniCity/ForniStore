#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/azuriom"
PORT_DEFAULT="${PORT:-8080}"

# Evita conflito de server duplicado
if [ -f /etc/nginx/conf.d/azuriom.conf ]; then
  echo ">> Removendo /etc/nginx/conf.d/azuriom.conf para evitar conflito de porta"
  rm -f /etc/nginx/conf.d/azuriom.conf
fi

# Injeta $PORT no Nginx
if command -v envsubst >/dev/null 2>&1; then
  envsubst '$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
  mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf
else
  sed -e "s|\${PORT}|${PORT_DEFAULT}|g" -i /etc/nginx/conf.d/default.conf
fi

cd "$APP_DIR"

# Gera .env se não existir
if [ ! -f ".env" ]; then
  echo ">> Gerando .env"
  cp .env.example .env || true
fi

# Permissão correta do .env para gerar APP_KEY
chown www-data:www-data .env || true
chmod 664 .env || true

# Garante APP_KEY
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

# Permissões essenciais
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rw storage bootstrap/cache || true

# Storage link (com fallback se symlink negar)
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

# Limpa caches
su -s /bin/sh -c 'php artisan config:clear || true' www-data
su -s /bin/sh -c 'php artisan route:clear || true' www-data

# Migrações com retry (PostgreSQL Railway)
RETRIES=12
SLEEP=5
echo ">> Rodando migrações (até ${RETRIES} tentativas)..."
for i in $(seq 1 $RETRIES); do
  if su -s /bin/sh -c 'php artisan migrate --force' www-data; then
    echo ">> Migrações aplicadas."
    break
  else
    echo ">> Migração falhou (tentativa ${i}/${RETRIES}). Aguardando ${SLEEP}s..."
    sleep $SLEEP
  fi
done

echo ">> Iniciando serviços na porta ${PORT_DEFAULT}..."
exec "$@"
