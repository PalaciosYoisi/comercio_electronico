<?php
session_start();

// Conexión a la base de datos
$conexion = new mysqli("localhost", "root", "", "comercio_electronico");

if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

// Verificar que la acción fue seleccionada
if (empty($_POST['accion'])) {
    echo "<script>alert('Error: No se seleccionó ninguna acción.');</script>";
    exit();
}

$accion = $_POST['accion'];
$resultado = "";
$tabla = "";
$mensaje_alerta = "";

switch ($accion) {
    case "actualizar_stock":
        $id_producto = $_POST['p_id_producto'] ?? null;
        $cantidad = $_POST['p_cantidad'] ?? null;
        
        if (!$id_producto || !$cantidad) {
            $mensaje_alerta = "Error: Datos incompletos para actualizar stock.";
        } else {
            $stmt = $conexion->prepare("CALL actualizar_stock(?, ?)");
            $stmt->bind_param("ii", $id_producto, $cantidad);
            if ($stmt->execute()) {
                $mensaje_alerta = "Stock actualizado correctamente.";
            } else {
                $mensaje_alerta = "Error al actualizar stock: " . $stmt->error;
            }
            $stmt->close();
        }
        break;

    case "aplicar_cupon":
        $id_detalle = $_POST['p_id_detalle'] ?? null;
        $id_orden = $_POST['p_id_orden'] ?? null;
        $id_cliente = $_POST['p_id_cliente'] ?? null;
        $id_producto = $_POST['p_id_producto'] ?? null;
        $cantidad = $_POST['p_cantidad'] ?? null;
        $descuento_cupon = $_POST['p_descuento_cupon'] ?? 0;
        $fecha_venta = $_POST['p_fecha_venta'] ?? null;

        if ($fecha_venta) {
            $fecha_venta = date("Y-m-d", strtotime($fecha_venta));
        }

        if (!$id_orden || !$id_cliente || !$id_producto || !$cantidad || !$fecha_venta) {
            $mensaje_alerta = "Error: Datos faltantes para aplicar cupón.";
        } else {
            $stmt = $conexion->prepare("CALL aplicar_cupon(?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("iiiidss", $id_detalle, $id_orden, $id_cliente, $id_producto, $cantidad, $descuento_cupon, $fecha_venta);
            if ($stmt->execute()) {
                $mensaje_alerta = "Cupón aplicado correctamente.";
            } else {
                $mensaje_alerta = "Error al aplicar cupón: " . $stmt->error;
            }
            $stmt->close();
        }
        break;

    case "productos_categorias":
        $id_producto = $_POST['p_id_producto'] ?? null;
        
        if (!$id_producto) {
            $mensaje_alerta = "Error: Falta el ID del producto.";
        } else {
            $stmt = $conexion->prepare("CALL productos_categorias(?)");
            $stmt->bind_param("i", $id_producto);
            
            if ($stmt->execute()) {
                $result = $stmt->get_result();
                if ($result->num_rows > 0) {
                    $tabla .= "<table border='1'><tr>";
                    $columns = $result->fetch_fields();
                    foreach ($columns as $column) {
                        $tabla .= "<th>" . htmlspecialchars($column->name) . "</th>";
                    }
                    $tabla .= "</tr>";

                    while ($row = $result->fetch_assoc()) {
                        $tabla .= "<tr>";
                        foreach ($row as $value) {
                            $tabla .= "<td>" . htmlspecialchars($value) . "</td>";
                        }
                        $tabla .= "</tr>";
                    }
                    $tabla .= "</table>";
                } else {
                    $mensaje_alerta = "No se encontraron resultados.";
                }
            } else {
                $mensaje_alerta = "Error al filtrar productos: " . $stmt->error;
            }
            $stmt->close();
        }
        break;

    case "reporte_ventas":
        $fecha_inicio = $_POST['fecha_inicio'] ?? null;
        $fecha_fin = $_POST['fecha_fin'] ?? null;

        if ($fecha_inicio) {
            $fecha_inicio = date("Y-m-d", strtotime($fecha_inicio));
        }
        if ($fecha_fin) {
            $fecha_fin = date("Y-m-d", strtotime($fecha_fin));
        }
        
        if (!$fecha_inicio || !$fecha_fin) {
            $mensaje_alerta = "Error: Fechas incompletas para el reporte de ventas.";
        } else {
            $stmt = $conexion->prepare("CALL reporte_ventas(?, ?)");
            $stmt->bind_param("ss", $fecha_inicio, $fecha_fin);
            
            if ($stmt->execute()) {
                $result = $stmt->get_result();
                if ($result->num_rows > 0) {
                    $tabla .= "<table border='1'><tr>";
                    $columns = $result->fetch_fields();
                    foreach ($columns as $column) {
                        $tabla .= "<th>" . htmlspecialchars($column->name) . "</th>";
                    }
                    $tabla .= "</tr>";

                    while ($row = $result->fetch_assoc()) {
                        $tabla .= "<tr>";
                        foreach ($row as $value) {
                            $tabla .= "<td>" . htmlspecialchars($value) . "</td>";
                        }
                        $tabla .= "</tr>";
                    }
                    $tabla .= "</table>";
                } else {
                    $mensaje_alerta = "No se encontraron resultados.";
                }
            } else {
                $mensaje_alerta = "Error al generar el reporte: " . $stmt->error;
            }
            $stmt->close();
        }
        break;

    default:
        $mensaje_alerta = "Error: Procedimiento no reconocido.";
        break;

    
        case "AplicarImpuesto":
            $monto = $_POST['p_monto'] ?? null;
            $id_impuesto = $_POST['p_id_impuesto'] ?? null;
            
            if (!$id_impuesto) {
                $mensaje_alerta = "Error: Falta el ID del impuesto.";
            } else {
                $stmt = $conexion->prepare("SELECT AplicarImpuesto(?, ?)");
                $stmt->bind_param("ii", $monto, $id_impuesto);
                
                if ($stmt->execute()) {
                    $result = $stmt->get_result();
                    if ($result->num_rows > 0) {
                        $tabla .= "<table border='1'><tr>";
                        $columns = $result->fetch_fields();
                        foreach ($columns as $column) {
                            $tabla .= "<th>" . htmlspecialchars($column->name) . "</th>";
                        }
                        $tabla .= "</tr>";
    
                        while ($row = $result->fetch_assoc()) {
                            $tabla .= "<tr>";
                            foreach ($row as $value) {
                                $tabla .= "<td>" . htmlspecialchars($value) . "</td>";
                            }
                            $tabla .= "</tr>";
                        }
                        $tabla .= "</table>";
                    } else {
                        $mensaje_alerta = "No se encontraron resultados.";
                    }
                } else {
                    $mensaje_alerta = "Error al filtrar productos: " . $stmt->error;
                }
                $stmt->close();
            }
            break;

        case "CalcularTotalOrden":

            $id_detalle = $_POST['p_id_detalle'] ?? null;
            
            if (!$id_detalle) {
                $mensaje_alerta = "Error: Falta el ID del detalle de venta.";
            } else {
                $stmt = $conexion->prepare("SELECT CalcularTotalOrden(?)");
                $stmt->bind_param("i", $id_detalle);
                
                if ($stmt->execute()) {
                    $result = $stmt->get_result();
                    if ($result->num_rows > 0) {
                        $tabla .= "<table border='1'><tr>";
                        $columns = $result->fetch_fields();
                        foreach ($columns as $column) {
                            $tabla .= "<th>" . htmlspecialchars($column->name) . "</th>";
                        }
                        $tabla .= "</tr>";
    
                        while ($row = $result->fetch_assoc()) {
                            $tabla .= "<tr>";
                            foreach ($row as $value) {
                                $tabla .= "<td>" . htmlspecialchars($value) . "</td>";
                            }
                            $tabla .= "</tr>";
                        }
                        $tabla .= "</table>";
                    } else {
                        $mensaje_alerta = "No se encontraron resultados.";
                    }
                } else {
                    $mensaje_alerta = "Error al filtrar productos: " . $stmt->error;
                }
                $stmt->close();
            }
            break;

            case "ObtenerNombreUsuario":
            $id_usuario = $_POST['id_usuario'] ?? null;
            
            if (!$id_usuario) {
                $mensaje_alerta = "Error: Falta el ID del usuario.";
            } else {
                $stmt = $conexion->prepare("SELECT ObtenerNombreUsuario(?)");
                $stmt->bind_param("i", $id_usuario);
                
                if ($stmt->execute()) {
                    $result = $stmt->get_result();
                    if ($result->num_rows > 0) {
                        $tabla .= "<table border='1'><tr>";
                        $columns = $result->fetch_fields();
                        foreach ($columns as $column) {
                            $tabla .= "<th>" . htmlspecialchars($column->name) . "</th>";
                        }
                        $tabla .= "</tr>";
    
                        while ($row = $result->fetch_assoc()) {
                            $tabla .= "<tr>";
                            foreach ($row as $value) {
                                $tabla .= "<td>" . htmlspecialchars($value) . "</td>";
                            }
                            $tabla .= "</tr>";
                        }
                        $tabla .= "</table>";
                    } else {
                        $mensaje_alerta = "No se encontraron resultados.";
                    }
                } else {
                    $mensaje_alerta = "Error al filtrar productos: " . $stmt->error;
                }
                $stmt->close();
            }
                break;        
}

$conexion->close();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resultado de la Operación</title>
    <link rel="stylesheet" href="../style/style.css"> <!-- Enlace a tu CSS mejorado -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const mensaje = "<?php echo htmlspecialchars($mensaje_alerta); ?>";
            if (mensaje) {
                alert(mensaje);
            }
        });
    </script>
</head>
<body>
    <div class="container">
        <h2>Resultado de la Operación</h2>

        <div class="table-container">
            <?php 
                if (!empty($tabla)) { 
                    echo $tabla; 
                } else {
                    echo "<p>No hay datos disponibles.</p>";
                }
            ?>
        </div>

        <br>
        <a href="../inicio.html" class="btn-primary">Volver</a>
    </div>
</body>
</html>