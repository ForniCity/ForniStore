#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/azuriom"
PORT_DEFAULT="${PORT:-8080}"

# Caminho do volume persistente:
PERSIST_DIR="${PERSIST_DIR:-/data}"   # defina PERSIST_DIR no Railway se o volume não estiver em /data

mkdir -p "$PERSIST_DIR"

# Evita duplicidade
[ -f /etc/nginx/conf.d/azuriom.conf ] && rm -f /etc/nginx/conf.d/azuriom.conf || true

# Injeta $PORT no Nginx (Railway define ${PORT})
if command -v envsubst >/dev/null 2>&1; then
  envsubst '$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
  mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf
else
  sed -e "s|\${PORT}|${PORT_DEFAULT}|g" -i /etc/nginx/conf.d/default.conf
fi

cd "$APP_DIR"

# --- Estrutura persistente ---
# Itens que queremos que sobrevivam a deploys:
# 1) .env
# 2) storage (uploads, cache, etc.)
# 3) plugins (Azuriom/plugins)
# 4) themes  (Azuriom/resources/themes)

mkdir -p \
  "$PERSIST_DIR/env" \
  "$PERSIST_DIR/storage" \
  "$PERSIST_DIR/plugins" \
  "$PERSIST_DIR/themes"

# 1) .env persistente
if [ ! -f "$PERSIST_DIR/env/.env" ]; then
  echo ">> Gerando .env persistente em $PERSIST_DIR/env/.env"
  if [ -f ".env" ]; then
    cp .env "$PERSIST_DIR/env/.env"
  else
    cp .env.example "$PERSIST_DIR/env/.env" || true
  fi
fi

# symlink .env -> persist
rm -f .env || true
ln -s "$PERSIST_DIR/env/.env" .env

# Helpers para .env
ensure_env () {
  local KEY="$1"; local VAL="$2"
  if grep -qE "^${KEY}=" .env; then
    sed -i "s|^${KEY}=.*|${KEY}=${VAL}|g" .env
  else
    echo "${KEY}=${VAL}" >> .env
  fi
}

# Proxies e asset url (opcional)
ensure_env "TRUSTED_PROXIES" "*"
ensure_env "TRUSTED_HEADERS" "X_FORWARDED_FOR,X_FORWARDED_HOST,X_FORWARDED_PORT,X_FORWARDED_PROTO,X_FORWARDED_AWS_ELB"
if [ -n "${ASSET_URL:-}" ]; then ensure_env "ASSET_URL" "${ASSET_URL}"; fi

# 2) storage persistente
if [ -d "storage" ] && [ ! -L "storage" ]; then
  # Primeiro deploy com volume vazio? copia conteúdo inicial
  if [ -z "$(ls -A "$PERSIST_DIR/storage" 2>/dev/null || true)" ]; then
    echo ">> Copiando storage para volume..."
    cp -a storage/. "$PERSIST_DIR/storage/"
  fi
  rm -rf storage
fi
ln -sfn "$PERSIST_DIR/storage" storage

# 3) plugins persistentes (pasta raiz: APP_DIR/plugins)
if [ -d "plugins" ] && [ ! -L "plugins" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/plugins" 2>/dev/null || true)" ]; then
    echo ">> Copiando plugins para volume..."
    cp -a plugins/. "$PERSIST_DIR/plugins/" || true
  fi
  rm -rf plugins
fi
ln -sfn "$PERSIST_DIR/plugins" plugins

# 4) themes persistentes (Azuriom usa resources/themes)
if [ -d "resources/themes" ] && [ ! -L "resources/themes" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/themes" 2>/dev/null || true)" ]; then
    echo ">> Copiando themes para volume..."
    cp -a resources/themes/. "$PERSIST_DIR/themes/" || true
  fi
  rm -rf resources/themes
fi
mkdir -p resources
ln -sfn "$PERSIST_DIR/themes" resources/themes

# Permissões essenciais
chown -R www-data:www-data "$PERSIST_DIR" || true
chmod -R ug+rw "$PERSIST_DIR" || true

chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rw storage bootstrap/cache || true

# APP_KEY
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

# storage:link com fallback
if [ ! -e "public/storage" ]; then
  if ! su -s /bin/sh -c 'php artisan storage:link' www-data; then
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

# Link de compatibilidade (alguns temas esperam /assets/*)
if [ ! -e "public/assets" ]; then
  ln -sfn . public/assets
  echo ">> Link de compat: public/assets -> public"
fi

# Limpa caches
su -s /bin/sh -c 'php artisan config:clear || true' www-data
su -s /bin/sh -c 'php artisan route:clear || true' www-data

# Migrações com retry (banco pode demorar a subir)
RETRIES=12; SLEEP=5
for i in $(seq 1 $RETRIES); do
  if su -s /bin/sh -c 'php artisan migrate --force' www-data; then
    break
  fi
  echo ">> Migração ainda não disponível, tentando novamente ($i/$RETRIES)..."
  sleep $SLEEP
done

echo ">> Iniciando serviços na porta ${PORT_DEFAULT}..."
exec "$@"
