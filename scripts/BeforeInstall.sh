#!/bin/bash

# --- VARIABLES DE ENTORNO (AJUSTAR SEGÚN EL AMBIENTE) ---
# Usar el ID del Grupo de Despliegue para diferenciar Stage y Prod
# CodeDeploy automáticamente pasa el nombre del grupo de despliegue a los scripts de hooks.
DEPLOYMENT_GROUP_NAME=$DEPLOYMENT_GROUP_NAME
WP_CONFIG_PATH="/var/www/html/wp-config.php"

# Directorio donde se copiarán los archivos. CodeDeploy lo creará si no existe, pero es buena práctica.
APP_DIR="/var/www/html"

# Verificar si el directorio de destino existe y es accesible
echo "Verificando el directorio de destino: $APP_DIR"
mkdir -p "$APP_DIR"
chown -R ec2-user:ec2-user "$APP_DIR" # Asegura que el usuario tenga acceso

# 1. Detener el servicio web (opcional, pero reduce errores de archivos bloqueados)
echo "Deteniendo el servicio web para la instalación..."
sudo systemctl stop httpd || true # Usamos '|| true' para que el script no falle si el servicio no está corriendo

# 2. Manejo de Credenciales (IMPORTANTE: SIMULACIÓN)
# En un entorno real, aquí es donde usarías AWS CLI para obtener secretos desde Secrets Manager.
# Ya que no usas Secrets Manager, aquí debes pegar las variables DE CADA AMBIENTE.

if [ "$DEPLOYMENT_GROUP_NAME" == "Prod-Deployment-Group" ]; then
    echo "Configurando variables de Producción..."
    DB_NAME="production_db"
    DB_USER="prod_user"
    DB_PASSWORD="TU_PASSWORD_DE_PRODUCCION" # Reemplazar
    DB_HOST="tu-endpoint-de-aurora-prod.rds.amazonaws.com" # Reemplazar
elif [ "$DEPLOYMENT_GROUP_NAME" == "Stage-Deployment-Group" ]; then
    echo "Configurando variables de Staging..."
    DB_NAME="staging_db"
    DB_USER="stage_user"
    DB_PASSWORD="TU_PASSWORD_DE_STAGING" # Reemplazar
    DB_HOST="tu-endpoint-de-aurora-stage.rds.amazonaws.com" # Reemplazar
else
    echo "ERROR: Grupo de despliegue desconocido. Saliendo..."
    exit 1
fi

# 3. Crear wp-config.php con los valores obtenidos
# Esto sobrescribiría el archivo si ya existe o lo crearía si no.
# Este método requiere que tengas un template de wp-config.php en /var/www/html después de la copia.

# Ejemplo (debes adaptarlo a tu template de wp-config.php)
if [ -f "$WP_CONFIG_PATH" ]; then
    echo "Modificando archivo wp-config.php..."
    # Usar comandos sed para reemplazar marcadores de posición en wp-config.php
    sed -i "s/define( 'DB_NAME', '.*' )/define( 'DB_NAME', '$DB_NAME' )/" "$WP_CONFIG_PATH"
    sed -i "s/define( 'DB_USER', '.*' )/define( 'DB_USER', '$DB_USER' )/" "$WP_CONFIG_PATH"
    sed -i "s/define( 'DB_PASSWORD', '.*' )/define( 'DB_PASSWORD', '$DB_PASSWORD' )/" "$WP_CONFIG_PATH"
    sed -i "s/define( 'DB_HOST', '.*' )/define( 'DB_HOST', '$DB_HOST' )/" "$WP_CONFIG_PATH"
else
    echo "Advertencia: wp-config.php aún no existe. La copia de archivos lo creará."
    # Si el código se copia después de BeforeInstall (que es lo normal), este paso se movería a AfterInstall.
fi

echo "BeforeInstall finalizado."
