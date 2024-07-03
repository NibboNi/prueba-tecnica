<?php include 'db.php'; ?>
<!DOCTYPE html>
<html>
<head>
    <title>Almacén de Contenedores</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <h1>Almacén de Contenedores</h1>
    
    <!-- Tabla de Registros -->
    <h2>Registros de Contenedores</h2>
    <table>
        <tr>
            <th>Número de Contenedor</th>
            <th>Tamaño</th>
            <th>Fecha de Entrada</th>
            <th>Fecha de Salida</th>
            <th>Número Económico</th>
            <th>Flujo</th>
            <th>Acciones</th>
        </tr>
        <?php
        $stmt = $conn->query("SELECT * FROM Contenedores");
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "<tr>";
            echo "<td>{$row['NumeroContenedor']}</td>";
            echo "<td>{$row['Tamano']}</td>";
            echo "<td>{$row['FechaEntrada']}</td>";
            echo "<td>{$row['FechaSalida']}</td>";
            echo "<td>{$row['NumeroEconomico']}</td>";
            echo "<td>{$row['Flujo']}</td>";
            echo "<td><a href='update.php?id={$row['NumeroContenedor']}'>Editar</a> | <a href='delete.php?id={$row['NumeroContenedor']}'>Eliminar</a></td>";
            echo "</tr>";
        }
        ?>
    </table>

    <!-- Formulario de Inserción -->
    <h2>Insertar Nuevo Contenedor</h2>
    <form action="insert.php" method="post">
        <label for="NumeroContenedor">Número de Contenedor:</label>
        <input type="text" id="NumeroContenedor" name="NumeroContenedor" required><br>
        <label for="Tamano">Tamaño:</label>
        <select id="Tamano" name="Tamano" required>
            <option value="20HC">20HC</option>
            <option value="40HC">40HC</option>
        </select><br>
        <label for="FechaEntrada">Fecha de Entrada:</label>
        <input type="datetime-local" id="FechaEntrada" name="FechaEntrada" required><br>
        <label for="NumeroEconomico">Número Económico:</label>
        <input type="text" id="NumeroEconomico" name="NumeroEconomico" required><br>
        <input type="submit" value="Insertar">
    </form>
</body>
</html>
