<?php
include 'db.php';

if (isset($_GET['id'])) {
    $id = $_GET['id'];

    // Primero, eliminar del inventario si existe
    $stmt = $conn->prepare("DELETE FROM Inventario WHERE NumeroContenedor = :NumeroContenedor");
    $stmt->bindParam(':NumeroContenedor', $id);
    $stmt->execute();

    // Luego, eliminar de la tabla de contenedores
    $stmt = $conn->prepare("DELETE FROM Contenedores WHERE NumeroContenedor = :NumeroContenedor");
    $stmt->bindParam(':NumeroContenedor', $id);

    if ($stmt->execute()) {
        header("Location: index.php");
        exit();
    } else {
        echo "Error al eliminar el registro.";
    }
}
?>
