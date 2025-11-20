#!/bin/bash

# --- VARIABLES Y RUTAS ---
DEPLOYMENT_GROUP_NAME=$DEPLOYMENT_GROUP_NAME
APP_DIR="/var/www/html"
DOWNLOAD_DIR="/tmp/wp_download" # Directorio temporal para la descarga

echo "Verificando el directorio de destino y preparando permisos: $APP_DIR"
mkdir -p "$APP_DIR"
chown -R ec2-user:ec2-user "$APP_DIR" # Asegura que CodeDeploy/ec2-user tenga acceso

# 1. Detener el servicio web
echo "Deteniendo el servicio web para la instalación..."
sudo systemctl stop httpd || true

# 2. INSTALAR EL CORE DE WORDPRESS (Nueva lógica)
echo "Iniciando la descarga e instalación del core de WordPress..."
mkdir -p $DOWNLOAD_DIR
cd $DOWNLOAD_DIR

# Descargar y descomprimir el core
echo "Descargando latest.zip..."
# Se usa 'wget' y '-q' (quiet) para que no imprima el progreso
wget -q https://wordpress.org/latest.zip
unzip -q latest.zip

# Copiar el contenido del core al destino de la aplicación.
# Esto crea la estructura de directorios wp-admin, wp-includes, etc., en /var/www/html/
echo "Copiando archivos del core de WordPress a $APP_DIR..."
# La opción 'r' copia recursivamente, y la opción 'a' (archive) preserva permisos.
cp -ra wordpress/. $APP_DIR/

# Limpiar archivos temporales
echo "Limpiando directorio de descarga temporal: $DOWNLOAD_DIR"
rm -rf $DOWNLOAD_DIR

echo "Core de WordPress instalado. La fase Install de CodeDeploy ahora sobrescribirá los archivos personalizados."
echo "BeforeInstall finalizado."
