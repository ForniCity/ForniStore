#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/var/www/azuriom}"
PORT_DEFAULT="${PORT:-8080}"

# Caminho do volume persistente (configurável via Railway)
PERSIST_DIR="${PERSIST_DIR:-/data}"
mkdir -p "$PERSIST_DIR"

echo ">> Usando volume persistente em: $PERSIST_DIR"
echo ">> Porta configurada: ${PORT_DEFAULT}"

# Remove conf antiga, se existir
[ -f /etc/nginx/conf.d/azuriom.conf ] && rm -f /etc/nginx/conf.d/azuriom.conf || true

# ===============================
# 🔧 Corrige porta dinâmica no Nginx
# ===============================
NGINX_CONF="/etc/nginx/conf.d/default.conf"
if [ -f "$NGINX_CONF" ]; then
  echo ">> Injetando porta dinâmica $PORT_DEFAULT no Nginx..."
  # cobre 'listen 8080;' e variações com espaços
  sed -i -E "s|listen[[:space:]]+[0-9]+;|listen ${PORT_DEFAULT};|g" "$NGINX_CONF"
else
  echo "server { listen ${PORT_DEFAULT}; }" > "$NGINX_CONF"
fi

# ===============================
# Ajustes de inicialização do Azuriom
# ===============================
cd "$APP_DIR"

# Estrutura persistente
mkdir -p \
  "$PERSIST_DIR/env" \
  "$PERSIST_DIR/storage" \
  "$PERSIST_DIR/bootstrap/cache" \
  "$PERSIST_DIR/plugins" \
  "$PERSIST_DIR/themes" \
  "$PERSIST_DIR/public/uploads"

# 1️⃣ .env persistente
if [ ! -f "$PERSIST_DIR/env/.env" ]; then
  echo ">> Gerando .env persistente em $PERSIST_DIR/env/.env"
  if [ -f ".env" ]; then
    cp .env "$PERSIST_DIR/env/.env"
  else
    cp .env.example "$PERSIST_DIR/env/.env" 2>/dev/null || touch "$PERSIST_DIR/env/.env"
  fi
fi

# Linka o .env para o volume
rm -f .env || true
ln -s "$PERSIST_DIR/env/.env" .env

# Permissões do .env
if [ -f ".env" ]; then
  chown www-data:www-data .env || true
  chmod 664 .env || true
fi

# Helpers para modificar o .env
ensure_env () {
  local KEY="$1"; local VAL="$2"
  if grep -qE "^${KEY}=" .env; then
    sed -i "s|^${KEY}=.*|${KEY}=${VAL}|g" .env
  else
    printf "%s=%s\n" "${KEY}" "${VAL}" >> .env
  fi
}

# Headers/proxy p/ Railway
ensure_env "TRUSTED_PROXIES" "*"
ensure_env "TRUSTED_HEADERS" "X_FORWARDED_FOR,X_FORWARDED_HOST,X_FORWARDED_PORT,X_FORWARDED_PROTO,X_FORWARDED_AWS_ELB"
# Opcionalmente define ASSET_URL se vier de env
if [ -n "${ASSET_URL:-}" ]; then ensure_env "ASSET_URL" "${ASSET_URL}"; fi

# 2️⃣ Storage persistente (idempotente)
if [ -d "storage" ] && [ ! -L "storage" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/storage" 2>/dev/null || true)" ]; then
    echo ">> Copiando storage para volume persistente..."
    rsync -a --delete storage/ "$PERSIST_DIR/storage/"
  fi
  rm -rf storage
fi
ln -sfn "$PERSIST_DIR/storage" storage

# 2.1 bootstrap/cache persistente (melhora cold start)
if [ -d "bootstrap/cache" ] && [ ! -L "bootstrap/cache" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/bootstrap/cache" 2>/dev/null || true)" ]; then
    rsync -a --delete bootstrap/cache/ "$PERSIST_DIR/bootstrap/cache/" || true
  fi
  rm -rf bootstrap/cache
fi
mkdir -p "$PERSIST_DIR/bootstrap/cache"
ln -sfn "$PERSIST_DIR/bootstrap/cache" bootstrap/cache

# 3️⃣ Plugins persistentes
if [ -d "plugins" ] && [ ! -L "plugins" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/plugins" 2>/dev/null || true)" ]; then
    echo ">> Copiando plugins para volume persistente..."
    rsync -a --delete plugins/ "$PERSIST_DIR/plugins/" || true
  fi
  rm -rf plugins
fi
ln -sfn "$PERSIST_DIR/plugins" plugins

# 4️⃣ Temas persistentes (Azuriom utiliza resources/themes)
if [ -d "resources/themes" ] && [ ! -L "resources/themes" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/themes" 2>/dev/null || true)" ]; then
    echo ">> Copiando themes para volume persistente..."
    rsync -a --delete resources/themes/ "$PERSIST_DIR/themes/" || true
  fi
  rm -rf resources/themes
fi
mkdir -p resources
ln -sfn "$PERSIST_DIR/themes" resources/themes

# 5️⃣ Uploads públicos (alguns temas/plugins usam public/uploads)
if [ -d "public/uploads" ] && [ ! -L "public/uploads" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/public/uploads" 2>/dev/null || true)" ]; then
    rsync -a --delete public/uploads/ "$PERSIST_DIR/public/uploads/" || true
  fi
  rm -rf public/uploads
fi
mkdir -p "$PERSIST_DIR/public/uploads"
ln -sfn "$PERSIST_DIR/public/uploads" public/uploads

# Permissões corretas
chown -R www-data:www-data "$PERSIST_DIR" || true
chmod -R ug+rw "$PERSIST_DIR" || true
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rw storage bootstrap/cache || true

# Gera APP_KEY (sem erro de permissão)
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

# Symlink do storage/public se necessário
if [ ! -e "public/storage" ]; then
  if ! su -s /bin/sh -c 'php artisan storage:link' www-data; then
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

# Compatibilidade com temas antigos (assets/ -> public)
if [ ! -e "public/assets" ]; then
  ln -sfn . public/assets
  echo ">> Link compat: public/assets -> public"
fi

# Limpa e recompõe caches Laravel (seguro)
su -s /bin/sh -c 'php artisan optimize:clear || true' www-data
su -s /bin/sh -c 'php artisan config:cache || true' www-data
su -s /bin/sh -c 'php artisan route:cache || true' www-data

# Migrações com retry (aguarda DB subir)
RETRIES=12; SLEEP=5
for i in $(seq 1 $RETRIES); do
  if su -s /bin/sh -c 'php artisan migrate --force' www-data; then
    break
  fi
  echo ">> Banco ainda não disponível, tentando novamente ($i/$RETRIES)..."
  sleep $SLEEP
done

echo ">> Inicialização completa. Iniciando Nginx + PHP-FPM na porta ${PORT_DEFAULT}..."
exec "$@"
