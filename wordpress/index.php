<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Prueba de Despliegue y Conexión a BD</title>
    <style>
        body { font-family: sans-serif; background-color: #f0f4f8; color: #333; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 50px auto; background-color: #ffffff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); }
        h1 { color: #1a73e8; border-bottom: 2px solid #e0e0e0; padding-bottom: 10px; margin-top: 0; }
        .status { padding: 15px; border-radius: 8px; margin: 15px 0; font-weight: bold; }
        .success { background-color: #e6ffed; border: 1px solid #00a854; color: #00a854; }
        .error { background-color: #fff0f0; border: 1px solid #e53935; color: #e53935; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background-color: #f5f5f5; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Estado del Despliegue CI/CD</h1>
        
        <h2>1. Configuración de Base de Datos (Leída desde CodeDeploy)</h2>
        <table>
            <tr><th>Variable</th><th>Valor</th></tr>
            <tr><td>DB_HOST</td><td><?php echo htmlspecialchars($host); ?></td></tr>
            <tr><td>DB_USER</td><td><?php echo htmlspecialchars($user); ?></td></tr>
            <tr><td>DB_NAME</td><td><?php echo htmlspecialchars($name); ?></td></tr>
            <tr><td>Ubicación Secreta</td><td><?php echo htmlspecialchars($secrets_file); ?></td></tr>
        </table>

        <h2>2. Prueba de Conexión a MySQL</h2>

        <?php
        if (isset($db_config['error'])) {
            echo '<div class="status error">❌ ERROR: No se pudieron cargar las credenciales.</div>';
            echo '<p>' . htmlspecialchars($db_config['error']) . '</p>';
        } else {
            // Intentar la conexión
            // Utilizamos los valores trim() para la conexión
            $mysqli = new mysqli($host, $user, $pass, $name);

            if ($mysqli->connect_errno) {
                echo '<div class="status error">❌ CONEXIÓN FALLIDA</div>';
                echo '<p>Error de MySQL: ' . $mysqli->connect_error . '</p>';
                echo '<p><strong>Posible causa:</strong> Credenciales incorrectas, el host de BD es inaccesible desde esta instancia, o los Security Groups están bloqueando el tráfico.</p>';
            } else {
                echo '<div class="status success">✅ CONEXIÓN EXITOSA</div>';
                echo '<p>Conexión establecida a la base de datos <code>' . htmlspecialchars($name) . '</code> en el host <code>' . htmlspecialchars($host) . '</code>.</p>';
                echo '<p>Versión de MySQL: ' . $mysqli->server_info . '</p>';
                $mysqli->close();
            }
        }
        ?>
        <p style="margin-top: 30px; font-size: 0.8em; color: #777;">
            Para un despliegue completo de WordPress, asegúrate de que tu `wp-config.php` también lea estas variables o utiliza un método de configuración más robusto.
        </p>
    </div>
</body>
</html>
