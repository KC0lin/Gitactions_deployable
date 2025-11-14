<?php
// Muestra información clave del servidor para verificar el entorno.
echo "<h1>✅ Despliegue Exitoso (CodeDeploy)</h1>";
echo "<h2>Conexión PHP/Apache Funcionando</h2>";
echo "<p>Ruta del archivo: " . __FILE__ . "</p>";
echo "<p>Usuario del Servidor Web (debería ser 'apache'): " . get_current_user() . "</p>";
echo "<p>Versión de PHP: " . phpversion() . "</p>";

// El resto de la aplicación (WordPress) podría ejecutarse aquí.
// require __DIR__ . '/wp-blog-header.php'; 
?>
