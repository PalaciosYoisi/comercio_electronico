<?php
session_start(); // Asegura que la sesión está activa antes de destruirla

// Verificar si hay una sesión activa
if (isset($_SESSION["id_usuario"])) {
    session_unset(); // Elimina todas las variables de sesión
    session_destroy(); // Destruye la sesión
}

// Redirigir al usuario a la página de inicio de sesión
header("Location: ../login.html");
exit();
?>
