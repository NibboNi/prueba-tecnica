<?php
include 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $NumeroContenedor = $_POST['NumeroContenedor'];
    $FechaSalida = $_POST['FechaSalida'];

    $stmt = $conn->prepare("CALL RegistrarSalida(:NumeroContenedor, :FechaSalida)");
    $stmt->bindParam(':NumeroContenedor', $NumeroContenedor);
    $stmt->bindParam(':FechaSalida', $FechaSalida);

    if ($stmt->execute()) {
        header("Location: index.php");
        exit();
    } else {
        echo "Error al actualizar el registro.";
    }
} else {
    $id = $_GET['id'];
    $stmt = $conn->prepare("SELECT * FROM Contenedores WHERE NumeroContenedor = :NumeroContenedor");
    $stmt->bindParam(':NumeroContenedor', $id);
    $stmt->execute();
    $registro = $stmt->fetch(PDO::FETCH_ASSOC);
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Editar Registro</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <h1>Editar Registro</h1>
    <form action="update.php" method="post">
        <input type="hidden" name="NumeroContenedor" value="<?php echo $registro['NumeroContenedor']; ?>">
        <label for="FechaSalida">Fecha de Salida:</label>
        <input type="datetime-local" id="FechaSalida" name="FechaSalida" required><br>
        <input type="submit" value="Actualizar">
    </form>
</body>
</html>
