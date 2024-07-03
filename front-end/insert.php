<?php
include 'db.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $NumeroContenedor = $_POST['NumeroContenedor'];
    $Tamano = $_POST['Tamano'];
    $FechaEntrada = $_POST['FechaEntrada'];
    $NumeroEconomico = $_POST['NumeroEconomico'];

    $stmt = $conn->prepare("CALL RegistrarEntrada(:NumeroContenedor, :Tamano, :FechaEntrada, :NumeroEconomico)");
    $stmt->bindParam(':NumeroContenedor', $NumeroContenedor);
    $stmt->bindParam(':Tamano', $Tamano);
    $stmt->bindParam(':FechaEntrada', $FechaEntrada);
    $stmt->bindParam(':NumeroEconomico', $NumeroEconomico);

    if ($stmt->execute()) {
        header("Location: index.php");
        exit();
    } else {
        echo "Error al insertar el registro.";
    }
}
?>
