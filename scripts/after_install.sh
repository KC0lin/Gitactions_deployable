#!/bin/bash
APP_DIR="/var/www/html"
# El usuario de Apache en Amazon Linux es 'apache'
WEB_USER="apache" 
WEB_GROUP="apache" 
TEMP_SECRETS_FILE="$APP_DIR/.db_credentials" # El archivo inyectado por GitHub Actions
FINAL_SECRETS_FILE="/tmp/db_secrets.txt"     # El archivo que lee index.php/wp-config

echo "AfterInstall iniciado: Configurando permisos y credenciales."

# 1. Cargar las credenciales inyectadas por el CI/CD
echo "Cargando credenciales inyectadas desde el CI/CD..."
if [ -f "$TEMP_SECRETS_FILE" ]; then
    # El archivo .db_credentials contiene las variables de ambiente del DB.
    # Usamos 'source' para cargarlas en el entorno de este script.
    source "$TEMP_SECRETS_FILE"
    
    # Aseguramos el archivo final para index.php y wp-config.php
    # Lo movemos a /tmp (fuera de la webroot) y le damos permisos de lectura al usuario web
    echo "Asegurando y moviendo credenciales a $FINAL_SECRETS_FILE..."
    sudo mv "$TEMP_SECRETS_FILE" "$FINAL_SECRETS_FILE"
    sudo chown apache:apache "$FINAL_SECRETS_FILE"
    sudo chmod 600 "$FINAL_SECRETS_FILE"
    
    # 2. Configuración de wp-config.php (SI EXISTE)
    # Aquí puedes usar 'sed' para actualizar wp-config.php con las variables cargadas
    # Se asume que el archivo a modificar se llama wp-config.php y se encuentra en /var/www/html/wordpress/
    WP_CONFIG_PATH="$APP_DIR/wordpress/wp-config.php" 
    
    # NOTA: Debes asegurarte de que tu wp-config.php tenga estas líneas con placeholders.
    if [ -f "$WP_CONFIG_PATH" ]; then
        echo "Modificando archivo wp-config.php..."
        sed -i "s/define( 'DB_NAME', '.*' )/define( 'DB_NAME', '$DB_NAME' )/" "$WP_CONFIG_PATH"
        sed -i "s/define( 'DB_USER', '.*' )/define( 'DB_USER', '$DB_USER' )/" "$WP_CONFIG_PATH"
        sed -i "s/define( 'DB_PASSWORD', '.*' )/define( 'DB_PASSWORD', '$DB_PASS' )/" "$WP_CONFIG_PATH"
        sed -i "s/define( 'DB_HOST', '.*' )/define( 'DB_HOST', '$DB_HOST' )/" "$WP_CONFIG_PATH"
        echo "wp-config.php actualizado."
    else
        echo "Advertencia: wp-config.php no encontrado en $WP_CONFIG_PATH. No se actualizó."
    fi
else
    echo "ERROR: Archivo de credenciales inyectado (.db_credentials) no encontrado."
    # Si este archivo falta, la conexión fallará.
fi

# 3. Asignar Propiedad (CRÍTICO: Esto evita el 403)
echo "Asignando propiedad de la aplicación a $WEB_USER:$WEB_GROUP..."
sudo chown -R $WEB_USER:$WEB_GROUP $APP_DIR

# 4. Configuración de Permisos
echo "Estableciendo permisos (755/644)..."
sudo find $APP_DIR -type f -exec chmod 644 {} \;
sudo find $APP_DIR -type d -exec chmod 755 {} \;

# 5. Dar Permisos de Escritura para wp-content (necesario para WordPress)
echo "Permitiendo escritura al servidor web en wp-content..."
sudo chmod -R 775 $APP_DIR/wp-content

echo "AfterInstall finalizado."
