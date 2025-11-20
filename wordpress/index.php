<?php
// Nuevo index.php: Prueba mínima de lectura de secretos y conexión a MySQL

// --- Configuración de Depuración ---
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// ---

$secrets_file = '/tmp/db_secrets.txt';
$db_config = [];
$port = 3306; // Puerto de MySQL por defecto

// 1. Función para parsear el archivo de secretos
function parse_secrets_simple($file) {
    if (!file_exists($file) || !is_readable($file)) {
        // Devuelve un array vacío o un error si el archivo no existe/es ilegible
        return ['error' => 'Archivo de secretos no encontrado o ilegible: ' . $file];
    }

    $lines = file($file, FILE_IGNORE_EMPTY_LINES | FILE_SKIP_EMPTY_LINES);
    $config = [];
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue; 
        list($key, $value) = explode('=', $line, 2);
        $config[trim($key)] = trim($value); 
    }
    return $config;
}

$db_config = parse_secrets_simple($secrets_file);

// 2. Asignar variables, usando valores seguros si falla la lectura
if (isset($db_config['error'])) {
    $status_title = "❌ ERROR EN LA LECTURA DE SECRETOS";
    $status_message = $db_config['error'];
    $is_connected = false;
    
    // Asignar placeholders para el reporte
    $host = 'N/A';
    $user = 'N/A';
    $name = 'N/A';

} else {
    // Credenciales cargadas exitosamente
    $host = trim($db_config['DB_HOST']);
    $user = trim($db_config['DB_USER']);
    $pass = trim($db_config['DB_PASS']);
    $name = trim($db_config['DB_NAME']);
    $is_connected = false;

    // 3. Intentar la Conexión a MySQL
    try {
        // 🚨 Conexión explícita incluyendo el puerto 3306
        $mysqli = new mysqli($host, $user, $pass, $name, $port);

        if ($mysqli->connect_errno) {
            $status_title = "❌ CONEXIÓN A BD FALLIDA";
            $status_message = "Error de MySQL: " . htmlspecialchars($mysqli->connect_error) . 
                              "<br><strong>Causa probable:</strong> Credenciales incorrectas o problema de Security Groups/Red.";
        } else {
            $status_title = "✅ CONEXIÓN A BD EXITOSA";
            $status_message = "Conexión establecida a la base de datos <code>" . htmlspecialchars($name) . "</code> en el host <code>" . htmlspecialchars($host) . "</code>. Versión: " . $mysqli->server_info;
            $mysqli->close();
            $is_connected = true;
        }
    } catch (Throwable $e) {
        // Capturar cualquier excepción de bajo nivel, como la del socket (aunque ya debería estar corregida)
        $status_title = "❌ ERROR FATAL DE CONEXIÓN";
        $status_message = "Excepción de PHP: " . htmlspecialchars($e->getMessage());
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Prueba de Despliegue y Conexión a BD - Mínimo</title>
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
        <h1>Estado de la Conexión de Despliegue CI/CD</h1>
        
        <h2>1. Configuración y Estado de la BD</h2>
        <table>
            <tr><th>Variable</th><th>Valor</th></tr>
            <tr><td>DB_HOST</td><td><?php echo htmlspecialchars($host); ?></td></tr>
            <tr><td>DB_USER</td><td><?php echo htmlspecialchars($user); ?></td></tr>
            <tr><td>DB_NAME</td><td><?php echo htmlspecialchars($name); ?></td></tr>
            <tr><td>Ubicación Secreta</td><td><?php echo htmlspecialchars($secrets_file); ?></td></tr>
        </table>
        
        <div class="status <?php echo $is_connected ? 'success' : 'error'; ?>">
            <h3><?php echo $status_title; ?></h3>
            <p><?php echo $status_message; ?></p>
        </div>

        <p style="margin-top: 30px; font-size: 0.8em; color: #777;">
            Si el estado muestra **"ERROR EN LA LECTURA DE SECRETOS"**, revise los permisos del archivo `/tmp/db_secrets.txt`.
            Si el estado muestra **"CONEXIÓN A BD FALLIDA"**, revise los Security Groups de la EC2/RDS.
        </p>
    </div>
</body>
</html>
