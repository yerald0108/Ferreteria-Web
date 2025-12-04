#!/usr/bin/env bash
set -euo pipefail

# Configurar entorno
export DJANGO_SETTINGS_MODULE="djangocrud.settings"

# Variables del superusuario (con valores por defecto)
export DJANGO_SUPERUSER_USERNAME="${DJANGO_SUPERUSER_USERNAME:-admin}"
export DJANGO_SUPERUSER_EMAIL="${DJANGO_SUPERUSER_EMAIL:-admin@example.com}"
export DJANGO_SUPERUSER_PASSWORD="${DJANGO_SUPERUSER_PASSWORD:-admin123}"

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

# Crear superusuario si no existe
echo "Creating superuser..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')
    print('✅ Superusuario creado: $DJANGO_SUPERUSER_USERNAME')
else:
    print('ℹ️  Superusuario ya existe: $DJANGO_SUPERUSER_USERNAME')
"

# Poblar base de datos con datos de ejemplo
echo "🚀 Populating database with sample data..."
if [ -f "populate_db.py" ]; then
    echo "📦 Ejecutando populate_db.py..."
    python manage.py shell < populate_db.py
    echo "✅ Base de datos poblada exitosamente!"
else
    echo "❌ Error: populate_db.py no encontrado" >&2
    exit 1
fi

# Recolectar archivos estáticos
echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "🎉 ¡Build completado!"
echo ""
echo "📋 Credenciales de superusuario:"
echo "   Usuario: $DJANGO_SUPERUSER_USERNAME"
echo "   Email: $DJANGO_SUPERUSER_EMAIL"
echo "   Contraseña: $DJANGO_SUPERUSER_PASSWORD"
