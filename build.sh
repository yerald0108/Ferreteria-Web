#!/usr/bin/env bash
set -euo pipefail

# Configurar entorno (ajustar según necesidades)
export DJANGO_SETTINGS_MODULE="djangocrud.settings"

# Verificar que requirements.txt existe
if [ ! -f "requirements.txt" ]; then
    echo "Error: requirements.txt not found!" >&2
    exit 1
fi

# Instalar dependencias
echo "Installing dependencies..."
pip install -r requirements.txt

# Verificar configuración de Django
echo "Checking Django configuration..."
python manage.py check

# Aplicar migraciones
echo "Applying database migrations..."
python manage.py migrate

# Recolectar archivos estáticos
echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Build completed successfully!"
