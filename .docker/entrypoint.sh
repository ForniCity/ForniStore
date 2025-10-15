#!/usr/bin/env bash
set -euo pipefail

# Permissões padrão mais amigáveis a grupo (combina com os chowns + chmod ug+rw)
umask 002

APP_DIR="/var/www/azuriom"
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

if [ -f "$NGINX_CONF" ] && grep -q 'listen' "$NGINX_CONF"; then
  echo ">> Injetando porta dinâmica $PORT_DEFAULT no Nginx..."
  # Troca qualquer "listen <num>;" por "listen ${PORT_DEFAULT};"
  sed -i "s|listen[[:space:]]\+[0-9]\+;|listen ${PORT_DEFAULT};|g" "$NGINX_CONF"
else
  echo ">> Criando listen ${PORT_DEFAULT} no Nginx (arquivo novo ou sem diretiva listen)"
  mkdir -p "$(dirname "$NGINX_CONF")"
  echo "server { listen ${PORT_DEFAULT}; }" >> "$NGINX_CONF"
fi

# ===============================
# Ajustes de inicialização do Azuriom
# ===============================
cd "$APP_DIR"

# Estrutura persistente
mkdir -p \
  "$PERSIST_DIR/env" \
  "$PERSIST_DIR/storage" \
  "$PERSIST_DIR/plugins" \
  "$PERSIST_DIR/themes"

# 1️⃣ .env persistente
if [ ! -f "$PERSIST_DIR/env/.env" ]; then
  echo ">> Gerando .env persistente em $PERSIST_DIR/env/.env"
  if [ -f ".env" ]; then
    cp .env "$PERSIST_DIR/env/.env"
  else
    cp .env.example "$PERSIST_DIR/env/.env" || true
  fi
fi

# Linka o .env para o volume
rm -f .env || true
ln -s "$PERSIST_DIR/env/.env" .env

# Corrige permissões antes de gerar APP_KEY
if [ -f ".env" ]; then
  chown www-data:www-data .env
  chmod 664 .env
fi

# Helpers para modificar o .env
ensure_env() {
  local KEY="$1"
  local VAL="$2"
  if grep -qE "^${KEY}=" .env; then
    sed -i "s|^${KEY}=.*|${KEY}=${VAL}|g" .env
  else
    echo "${KEY}=${VAL}" >> .env
  fi
}

ensure_env "TRUSTED_PROXIES" "*"
ensure_env "TRUSTED_HEADERS" "X_FORWARDED_FOR,X_FORWARDED_HOST,X_FORWARDED_PORT,X_FORWARDED_PROTO,X_FORWARDED_AWS_ELB"
[ -n "${ASSET_URL:-}" ] && ensure_env "ASSET_URL" "${ASSET_URL}"

# 2️⃣ Storage persistente
if [ -d "storage" ] && [ ! -L "storage" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/storage" 2>/dev/null || true)" ]; then
    echo ">> Copiando storage para volume persistente..."
    cp -a storage/. "$PERSIST_DIR/storage/"
  fi
  rm -rf storage
fi
ln -sfn "$PERSIST_DIR/storage" storage

# 3️⃣ Plugins persistentes
if [ -d "plugins" ] && [ ! -L "plugins" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/plugins" 2>/dev/null || true)" ]; then
    echo ">> Copiando plugins para volume persistente..."
    cp -a plugins/. "$PERSIST_DIR/plugins/" || true
  fi
  rm -rf plugins
fi
ln -sfn "$PERSIST_DIR/plugins" plugins

# 4️⃣ Temas persistentes
if [ -d "resources/themes" ] && [ ! -L "resources/themes" ]; then
  if [ -z "$(ls -A "$PERSIST_DIR/themes" 2>/dev/null || true)" ]; then
    echo ">> Copiando themes para volume persistente..."
    cp -a resources/themes/. "$PERSIST_DIR/themes/" || true
  fi
  rm -rf resources/themes
fi
mkdir -p resources
ln -sfn "$PERSIST_DIR/themes" resources/themes

# Permissões corretas
chown -R www-data:www-data "$PERSIST_DIR" || true
chmod -R ug+rw "$PERSIST_DIR" || true
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rw storage bootstrap/cache || true

# Gera APP_KEY (sem erro de permissão)
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

# Cria symlink do storage/public se necessário
if [ ! -e "public/storage" ]; then
  if ! su -s /bin/sh -c 'php artisan storage:link' www-data; then
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

# Compatibilidade com temas antigos (assets/)
if [ ! -e "public/assets" ]; then
  ln -sfn . public/assets
  echo ">> Link compat: public/assets -> public"
fi

# Limpa cache Laravel
su -s /bin/sh -c 'php artisan config:clear || true' www-data
su -s /bin/sh -c 'php artisan route:clear || true' www-data

# Migrações com retry
RETRIES=12
SLEEP=5
for i in $(seq 1 "$RETRIES"); do
  if su -s /bin/sh -c 'php artisan migrate --force' www-data; then
    break
  fi
  echo ">> Banco ainda não disponível, tentando novamente ($i/$RETRIES)..."
  sleep "$SLEEP"
done

echo ">> Inicialização completa. Iniciando Nginx + PHP-FPM na porta ${PORT_DEFAULT}..."
exec "$@"
