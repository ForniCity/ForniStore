#!/usr/bin/env bash
set -euo pipefail

cd "${APP_DIR:-/var/www/azuriom}"

# Timezone dinâmico (fallback em zz-custom.ini é UTC)
if [ -n "${TZ:-}" ]; then
  echo "date.timezone=${TZ}" > /usr/local/etc/php/conf.d/99-timezone.ini || true
fi

mkdir -p /run/nginx

# Instala dependências PHP/Laravel/Azuriom no volume vazio
if [ ! -f "vendor/autoload.php" ]; then
  echo ">> vendor/ ausente. Executando Composer..."

  if [ -f "composer.lock" ]; then
    echo ">> Encontrado composer.lock — rodando 'composer install' (produção)."
    composer install --no-dev --prefer-dist --no-progress --no-interaction
  else
    echo ">> Sem composer.lock — rodando 'composer update' (produção)."
    composer update --no-dev --prefer-dist --no-progress --no-interaction
  fi
fi

# Comandos Laravel/Azuriom seguros
if [ -f ".env" ]; then
  php artisan key:generate --force || true
  php artisan storage:link || true
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true
  # php artisan migrate --force || true  # habilite se quiser migrar automaticamente
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
