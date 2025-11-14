#!/bin/bash
# Script para validar que el servicio web de WordPress está respondiendo

# Dirección local de la aplicación
# Usamos localhost y el puerto 80 (HTTP)
APP_URL="http://localhost:80/" 

# 1. Intentar acceder a la aplicación
echo "Validando la respuesta de la aplicación en: $APP_URL"

# Usamos 'curl' para hacer una solicitud y obtener el código de estado HTTP
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL)

# 2. Comprobar el código de estado
if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 301 ]; then
    # El código 200 (OK) o 301 (Redirección, que es común si fuerzas HTTPS) es un éxito.
    echo "Validación exitosa. Código HTTP: $HTTP_CODE. La aplicación está respondiendo."
    exit 0 # Salida exitosa
else
    # Cualquier otro código (ej. 500, 404) es un fallo.
    echo "Validación fallida. Código HTTP: $HTTP_CODE."
    echo "La aplicación no respondió correctamente al inicio."
    exit 1 # Salida con error, forzando la reversión del despliegue
fi
