#!/bin/bash

# --- VARIABLES DE ENTORNO (AJUSTAR SEGÚN EL AMBIENTE) ---
# Usar el ID del Grupo de Despliegue para diferenciar Stage y Prod
# CodeDeploy automáticamente pasa el nombre del grupo de despliegue a los scripts de hooks.
DEPLOYMENT_GROUP_NAME=$DEPLOYMENT_GROUP_NAME
# Directorio donde se copiarán los archivos. CodeDeploy lo creará si no existe, pero es buena práctica.
APP_DIR="/var/www/html"

# Verificar si el directorio de destino existe y es accesible
echo "Verificando el directorio de destino: $APP_DIR"
mkdir -p "$APP_DIR"
chown -R ec2-user:ec2-user "$APP_DIR" # Asegura que el usuario tenga acceso

echo "BeforeInstall finalizado. solo se detuvo el servicio web"
