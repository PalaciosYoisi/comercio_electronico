<?php 
#1 paso, establecer conexion con la base de datos
$conexion = mysqli_connect("localhost","root","","comercio_electronico");
#2 paso, verificar la conexion
if(!$conexion){
    echo "error de conexion".mysqli_connect_error();
    exit();

}
#3 establecer comando sql

$sql = "select email, clave from usuarios where email='".$_POST['email']."' and clave='".$_POST['clave']."'";

#4 ejecutar el comando
$resultado = mysqli_query($conexion, $sql);
#$registro = mysqli_fetch_array($resultado);

if($resultado){
    header("HTTP/1.1 302 Moved Temporarily"); 
    header("Location: ../inicio.html");
}else {
    echo 'El correo o clave es incorrecto ';
}

?>