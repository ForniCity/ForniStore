#!/usr/bin/env bash
set -euo pipefail

cd "${APP_DIR:-/var/www/azuriom}"

# Timezone do PHP: cria um ini no runtime se TZ estiver setado; caso contrário, fica UTC (já no zz-custom.ini)
if [ -n "${TZ:-}" ]; then
  echo "date.timezone=${TZ}" > /usr/local/etc/php/conf.d/99-timezone.ini || true
fi

mkdir -p /run/nginx

# Se o volume montado "escondeu" a pasta vendor, instalamos as dependências
if [ ! -d "vendor" ] || [ ! -f "vendor/autoload.php" ]; then
  echo ">> vendor/ ausente. Executando 'composer install'..."
  # flags para produção
  composer install --no-dev --prefer-dist --no-progress --no-interaction
fi

# Tarefas Laravel/Azuriom seguras (não falham o container se ainda não há DB)
if [ -f ".env" ]; then
  php artisan key:generate --force || true
  php artisan storage:link || true
  php artisan config:cache || true
  php artisan route:cache || true
  php artisan view:cache || true
  # Migrations opcionais — descomente se quiser forçar
  # php artisan migrate --force || true
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
