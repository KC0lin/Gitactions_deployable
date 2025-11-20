#!/bin/bash
# Script para validar que el servicio web de WordPress está respondiendo
# Usando la nueva configuración de Application Load Balancer (ALB).

# Si esta variable no está definida por CodeDeploy, se usará localhost como fallback.
# Idealmente, CodeDeploy debería definir la IP Privada del ALB o el DNS.
# Para el caso de un ALB con verificación local, usamos localhost.
APP_URL="http://localhost:80/"

# Nota: Si se quiere probar la ruta pública (ALB), esta variable debe ser inyectada
# en CodeDeploy o en GitHub Actions.

echo "Validando la respuesta de la aplicación en: $APP_URL"

# Usamos 'curl' para hacer una solicitud y obtener el código de estado HTTP
# Intentamos la conexión hasta 5 veces, esperando 5 segundos entre cada intento.
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --retry 5 --retry-delay 5 $APP_URL)

# 2. Comprobar el código de estado
if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 301 ]; then
    # El código 200 (OK) o 301 (Redirección, común si fuerzas HTTPS) es un éxito.
    echo "Validación exitosa. Código HTTP: $HTTP_CODE. La aplicación está respondiendo."
    exit 0 # Salida exitosa
else
    # Cualquier otro código (ej. 500, 404) es un fallo.
    echo "Validación fallida. Código HTTP: $HTTP_CODE."
    echo "La aplicación no respondió correctamente al inicio."
    exit 1 # Salida con error, forzando la reversión del despliegue
fi
