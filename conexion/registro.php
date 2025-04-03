<?php
// Configuración de la base de datos
$servidor = "localhost";
$usuario = "root";
$password = "";
$base_datos = "comercio_electronico";

$conn = new mysqli($servidor, $usuario, $password, $base_datos);

if ($conn->connect_error) {
    die("Error de conexión: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {

    $nombre = trim($_POST["p_nombre_usuario"]);
    $correo = trim($_POST["p_email"]);
    $clave = trim($_POST["p_clave"]);

    if (empty($nombre) || empty($correo) || empty($clave)) {
        die("Error: Todos los campos son obligatorios.");
    }

    // Encriptar la contraseña
    $password_hash = password_hash($clave, PASSWORD_DEFAULT);

    $sql = "CALL agregar_usuario(?, ?, ?)";
    
    if ($stmt = $conn->prepare($sql)) {

        $stmt->bind_param("sss", $nombre, $correo, $password_hash);
        
        if ($stmt->execute()) {
            header("Location: ../index.html");
            exit();
        } else {
            echo "Error al registrar usuario.";
        }
        $stmt->close();
    } else {
        echo "Error en la preparación de la consulta.";
    }

    $conn->close();
}
?>
