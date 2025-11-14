#!/bin/bash
APP_DIR="/var/www/html"
# NOTA: Debes confirmar el usuario real de tu servidor web. 
# Para Amazon Linux/RHEL es generalmente 'apache'. Para Debian/Ubuntu es 'www-data'.
WEB_USER="apache" 
WEB_GROUP="apache" 

echo "AfterInstall iniciado: Configurando permisos de aplicación."

# 1. Asignar Propiedad (Ownership)
# CodeDeploy copia los archivos como el usuario 'root'. Debemos transferir la propiedad al usuario del servidor web.
echo "Asignando propiedad de la aplicación a $WEB_USER:$WEB_GROUP..."
sudo chown -R $WEB_USER:$WEB_GROUP $APP_DIR

# 2. Configuración de Permisos Estándar (Recomendado por WordPress)
# Archivos con 644 (lectura/escritura para el dueño, solo lectura para otros)
echo "Estableciendo permisos estándar (755/644)..."
sudo find $APP_DIR -type f -exec chmod 644 {} \;
# Directorios con 755
sudo find $APP_DIR -type d -exec chmod 755 {} \;

# 3. Dar Permisos de Escritura para WordPress
# wp-content necesita permisos de escritura (775) para gestionar subidas, plugins, temas y caché.
echo "Permitiendo escritura al servidor web en wp-content..."
sudo chmod -R 775 $APP_DIR/wp-content

# Esto asegura que el servidor web pueda subir archivos y configurar WordPress.
echo "AfterInstall finalizado."
