#!/bin/bash
APP_DIR="/var/www/html"
# El usuario de Apache en Amazon Linux es 'apache'
WEB_USER="apache" 
WEB_GROUP="apache" 

echo "AfterInstall iniciado: Configurando permisos de aplicación."

# 1. Asignar Propiedad (CRÍTICO: Esto evita el 403)
# Transfiere la propiedad de los archivos copiados por CodeDeploy al usuario del servidor web.
echo "Asignando propiedad de la aplicación a $WEB_USER:$WEB_GROUP..."
sudo chown -R $WEB_USER:$WEB_GROUP $APP_DIR

# 2. Configuración de Permisos
# Los directorios (755) necesitan el permiso de 'ejecución' (x) para que Apache pueda entrar y leer el contenido.
# Los archivos (644) solo necesitan permiso de lectura.
echo "Estableciendo permisos (755/644)..."
sudo find $APP_DIR -type f -exec chmod 644 {} \;
sudo find $APP_DIR -type d -exec chmod 755 {} \;

# 3. Dar Permisos de Escritura para wp-content (necesario para WordPress)
echo "Permitiendo escritura al servidor web en wp-content..."
# Esto permite que el usuario 'apache' escriba archivos (ej. imágenes subidas)
sudo chmod -R 775 $APP_DIR/wp-content

echo "AfterInstall finalizado."
