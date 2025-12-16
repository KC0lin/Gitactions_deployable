#!/bin/bash
APP_DIR="/var/www/html"
# El usuario de Apache en Amazon Linux es 'apache'
WEB_USER="apache" 
WEB_GROUP="apache" 
TEMP_SECRETS_FILE="$APP_DIR/.db_credentials" 
# 🚨 UBICACIÓN FINAL SEGURA: Directorio dedicado fuera de la webroot
FINAL_SECRETS_DIR="/var/www/db_config"
FINAL_SECRETS_FILE="$FINAL_SECRETS_DIR/db_secrets.txt" 

echo "AfterInstall iniciado: Configurando permisos y credenciales."

# --- DEBUGGING: Listar contenido de la carpeta de despliegue para verificar el archivo ---
echo "--- DEBUG: Contenido de $APP_DIR antes de la configuración ---"
ls -la $APP_DIR
echo "---------------------------------------------------------"

# 0. CONFIGURACIÓN DE LA UBICACIÓN FINAL (CRÍTICO para SELinux/AppArmor)
echo "Creando directorio seguro para credenciales: $FINAL_SECRETS_DIR"
sudo mkdir -p "$FINAL_SECRETS_DIR"
sudo chown $WEB_USER:$WEB_GROUP "$FINAL_SECRETS_DIR"
sudo chmod 700 "$FINAL_SECRETS_DIR" # Solo el propietario (apache) puede entrar


# 1. Cargar las credenciales inyectadas por el CI/CD
echo "Cargando credenciales inyectadas desde el CI/CD..."
# Verifica la existencia y si es legible por el usuario que ejecuta el script (root/ec2-user)
if [ -f "$TEMP_SECRETS_FILE" ]; then
    
    # 1a. Mover y asegurar el archivo de secretos
    echo "Asegurando y moviendo credenciales a $FINAL_SECRETS_FILE..."
    # Mover el archivo fuera de la webroot y a la ubicación final
    sudo mv "$TEMP_SECRETS_FILE" "$FINAL_SECRETS_FILE"
    
    # Establecer la propiedad al usuario web (apache)
    sudo chown $WEB_USER:$WEB_GROUP "$FINAL_SECRETS_FILE"
    
    # 🚨 CORRECCIÓN FINAL: Cambiar a 644 para forzar la lectura por PHP (Others R)
    sudo chmod 644 "$FINAL_SECRETS_FILE"

    # 1b. Cargar las variables para usarlas con sed
    # Usamos 'source' para cargar las variables del archivo ya movido.
    # El script after_install.sh se ejecuta como 'root', así que la lectura funciona.
    source "$FINAL_SECRETS_FILE"

    # 2. Configuración de wp-config.php (SI EXISTE)
    # Se asume que el archivo a modificar se llama wp-config.php y se encuentra en /var/www/html/wordpress/
    WP_CONFIG_PATH="$APP_DIR/wp-config.php" 
    
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
    echo "ERROR: Archivo de credenciales inyectado (.db_credentials) no encontrado en $TEMP_SECRETS_FILE."
    # Aquí podríamos fallar el despliegue si queremos forzar que las credenciales existan.
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

cd /var/www/html/temp_images/
sudo mv foto_pexels.jpeg /var/www/html/wp-content/themes/twentytwentyfive/

echo "AfterInstall finalizado."
