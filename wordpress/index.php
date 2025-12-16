<?php
// --- INICIO DE DEPURACIÓN (DEBUGGING) ---
// Estas líneas fuerzan a PHP a mostrar cualquier error fatal en el navegador.
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// --- FIN DE DEPURACIÓN (DEBUGGING) ---

// ----------------------------------------------------
// Archivo de Prueba de Conexión a la Base de Datos
// (Debe ser incluido en la carpeta 'wordpress/' del repositorio)
// ----------------------------------------------------

// Ruta del archivo de secretos generado en el hook after_install.sh
$secrets_file = '/var/www/db_config/db_secrets.txt';
$db_config = [];

// Función para parsear el archivo de secretos
function parse_secrets($file) {
    if (!file_exists($file) || !is_readable($file)) {
        return ['error' => 'No se encontró el archivo de secretos o no se puede leer.'];
    }

    $lines = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    $config = [];
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue; // Ignorar comentarios
        list($key, $value) = explode('=', $line, 2);
        // 🚨 TRIM aplicado al valor para limpiar saltos de línea y espacios
        $config[trim($key)] = trim($value); 
    }
    return $config;
}

$db_config = parse_secrets($secrets_file);
// 🚨 TRIM aplicado de nuevo por seguridad
$host = trim($db_config['DB_HOST'] ?? 'HOST_NO_ENCONTRADO');
$user = trim($db_config['DB_USER'] ?? 'USER_NO_ENCONTRADO');
$pass = trim($db_config['DB_PASS'] ?? 'PASS_NO_ENCONTRADO');
$name = trim($db_config['DB_NAME'] ?? 'NAME_NO_ENCONTRADO');

?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Prueba de Despliegue y Conexión a BD. Prueba 20-11-2025 5:05</title>
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
        <div class="image-display">
            <h2>3. Imagen de Prueba Subida</h2>
            <?php
            // La ruta relativa se calcula desde el archivo index.php
            $image_path = 'wp-content/themes/twentytwentyfive/foto_pexels.jpeg';
            $full_server_path = '/var/www/html/' . $image_path;

            if (file_exists($full_server_path)) {
                echo '<p class="status success">✅ Archivo encontrado en el servidor.</p>';
                // La etiqueta img usa la ruta relativa para que el navegador la encuentre
                echo '<img src="' . htmlspecialchars($image_path) . '" alt="Imagen de prueba">';
            } else {
                echo '<p class="status error">❌ Archivo NO encontrado en: <code>' . htmlspecialchars($full_server_path) . '</code></p>';
                // Esto podría indicar un problema en la ruta o permisos.
            }
            ?>
        </div>

        <p style="margin-top: 30px; font-size: 0.8em; color: #777;">
        <p style="margin-top: 30px; font-size: 0.8em; color: #777;">
            Para un despliegue completo de WordPress, asegúrate de que tu `wp-config.php` también lea estas variables o utiliza un método de configuración más robusto.
        </p>
    </div>
</body>
</html>
