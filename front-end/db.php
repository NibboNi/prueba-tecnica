<?php
$servername = "localhost";
$username = "root";
$password = "root";
$dbname = "AlmacenContenedores";
$port = 3307;

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname;port=$port", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $conn->exec("SET NAMES 'utf8mb4'");
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
