#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/var/www/azuriom}"
PORT_DEFAULT="${PORT:-8080}"

# Volume persistente
PERSIST_DIR="${PERSIST_DIR:-/data}"
mkdir -p "$PERSIST_DIR"

echo ">> Usando volume persistente em: $PERSIST_DIR"
echo ">> Porta configurada: ${PORT_DEFAULT}"

# Limpa conf antiga opcional
[ -f /etc/nginx/conf.d/azuriom.conf ] && rm -f /etc/nginx/conf.d/azuriom.conf || true

# =====================================================================
# 🔧 Garante que o nginx.conf principal inclui conf.d/*.conf
# =====================================================================
MAIN_NGX="/etc/nginx/nginx.conf"
if ! grep -q "include /etc/nginx/conf.d/\*.conf;" "$MAIN_NGX"; then
  cat > "$MAIN_NGX" <<'NGXMAIN'
user  nginx;
worker_processes  auto;

error_log  /proc/self/fd/2 warn;
pid        /var/run/nginx.pid;

events { worker_connections 1024; }

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /proc/self/fd/1  main;

    sendfile        on;
    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
}
NGXMAIN
fi

# =====================================================================
# 🔧 Porta dinâmica (edita o arquivo de VHOST correto)
# =====================================================================
NGINX_VHOST="/etc/nginx/conf.d/default.conf"
if [ ! -f "$NGINX_VHOST" ]; then
  # cria um vhost básico se não existir
  cat > "$NGINX_VHOST" <<'DEFCONF'
server {
    listen 8080;
    listen [::]:8080;
    server_name  _;

    root   /var/www/azuriom/public;
    index  index.php index.html;

    location / { try_files $uri $uri/ /index.php?$query_string; }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_read_timeout 120s;
    }

    location ~* \.(?:css|js|jpg|jpeg|gif|png|svg|ico|webp|ttf|woff|woff2)$ {
        expires 7d;
        add_header Cache-Control "public";
        try_files $uri =404;
    }

    location ~ /\.(?!well-known).* { deny all; }

    client_max_body_size 50M;
    sendfile on;
}
DEFCONF
fi

echo ">> Injetando porta dinâmica $PORT_DEFAULT no Nginx (IPv4 e IPv6)..."
# cobre 'listen 8080;' e variações, tanto IPv4 quanto IPv6
sed -i -E "s|listen[[:space:]]+[0-9]+;|listen ${PORT_DEFAULT};|g" "$NGINX_VHOST"
sed -i -E "s|listen[[:space:]]+\[::\]:[0-9]+;|listen [::]:${PORT_DEFAULT};|g" "$NGINX_VHOST"

# =====================================================================
# Ajustes de inicialização do Azuriom (persistência)
# =====================================================================
cd "$APP_DIR"

mkdir -p \
  "$PERSIST_DIR/env" \
  "$PERSIST_DIR/storage" \
  "$PERSIST_DIR/bootstrap/cache" \
  "$PERSIST_DIR/plugins" \
  "$PERSIST_DIR/themes" \
  "$PERSIST_DIR/public/uploads"

# .env persistente
if [ ! -f "$PERSIST_DIR/env/.env" ]; then
  echo ">> Gerando .env persistente em $PERSIST_DIR/env/.env"
  if [ -f ".env" ]; then
    cp .env "$PERSIST_DIR/env/.env"
  else
    cp .env.example "$PERSIST_DIR/env/.env" 2>/dev/null || touch "$PERSIST_DIR/env/.env"
  fi
fi
rm -f .env || true
ln -s "$PERSIST_DIR/env/.env" .env
chown www-data:www-data .env || true
chmod 664 .env || true

ensure_env () {
  local KEY="$1"; local VAL="$2"
  if grep -qE "^${KEY}=" .env; then
    sed -i "s|^${KEY}=.*|${KEY}=${VAL}|g" .env
  else
    printf "%s=%s\n" "${KEY}" "${VAL}" >> .env
  fi
}
ensure_env "TRUSTED_PROXIES" "*"
ensure_env "TRUSTED_HEADERS" "X_FORWARDED_FOR,X_FORWARDED_HOST,X_FORWARDED_PORT,X_FORWARDED_PROTO,X_FORWARDED_AWS_ELB"
[ -n "${ASSET_URL:-}" ] && ensure_env "ASSET_URL" "${ASSET_URL}"

# storage
if [ -d "storage" ] && [ ! -L "storage" ]; then
  [ -z "$(ls -A "$PERSIST_DIR/storage" 2>/dev/null || true)" ] && rsync -a --delete storage/ "$PERSIST_DIR/storage/"
  rm -rf storage
fi
ln -sfn "$PERSIST_DIR/storage" storage

# bootstrap/cache
if [ -d "bootstrap/cache" ] && [ ! -L "bootstrap/cache" ]; then
  [ -z "$(ls -A "$PERSIST_DIR/bootstrap/cache" 2>/dev/null || true)" ] && rsync -a --delete bootstrap/cache/ "$PERSIST_DIR/bootstrap/cache/" || true
  rm -rf bootstrap/cache
fi
mkdir -p "$PERSIST_DIR/bootstrap/cache"
ln -sfn "$PERSIST_DIR/bootstrap/cache" bootstrap/cache

# plugins
if [ -d "plugins" ] && [ ! -L "plugins" ]; then
  [ -z "$(ls -A "$PERSIST_DIR/plugins" 2>/dev/null || true)" ] && rsync -a --delete plugins/ "$PERSIST_DIR/plugins/" || true
  rm -rf plugins
fi
ln -sfn "$PERSIST_DIR/plugins" plugins

# themes
if [ -d "resources/themes" ] && [ ! -L "resources/themes" ]; then
  [ -z "$(ls -A "$PERSIST_DIR/themes" 2>/dev/null || true)" ] && rsync -a --delete resources/themes/ "$PERSIST_DIR/themes/" || true
  rm -rf resources/themes
fi
mkdir -p resources
ln -sfn "$PERSIST_DIR/themes" resources/themes

# public/uploads
if [ -d "public/uploads" ] && [ ! -L "public/uploads" ]; then
  [ -z "$(ls -A "$PERSIST_DIR/public/uploads" 2>/dev/null || true)" ] && rsync -a --delete public/uploads/ "$PERSIST_DIR/public/uploads/" || true
  rm -rf public/uploads
fi
mkdir -p "$PERSIST_DIR/public/uploads"
ln -sfn "$PERSIST_DIR/public/uploads" public/uploads

# Permissões
chown -R www-data:www-data "$PERSIST_DIR" || true
chmod -R ug+rw "$PERSIST_DIR" || true
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R ug+rw storage bootstrap/cache || true

# Laravel helpers
su -s /bin/sh -c 'php artisan key:generate --force || true' www-data

if [ ! -e "public/storage" ]; then
  if ! su -s /bin/sh -c 'php artisan storage:link' www-data; then
    mkdir -p public/storage
    cp -R storage/app/public/* public/storage/ 2>/dev/null || true
    chown -R www-data:www-data public/storage
  fi
fi

[ ! -e "public/assets" ] && ln -sfn . public/assets && echo ">> Link compat: public/assets -> public"

su -s /bin/sh -c 'php artisan optimize:clear || true' www-data
su -s /bin/sh -c 'php artisan config:cache || true' www-data
su -s /bin/sh -c 'php artisan route:cache || true' www-data

# Migrações (aguarda DB)
RETRIES=12; SLEEP=5
for i in $(seq 1 $RETRIES); do
  if su -s /bin/sh -c 'php artisan migrate --force' www-data; then break; fi
  echo ">> Banco ainda não disponível, tentando novamente ($i/$RETRIES)..."
  sleep $SLEEP
done

echo ">> Inicialização completa. Iniciando Nginx + PHP-FPM na porta ${PORT_DEFAULT}..."
exec "$@"
