<?php
    // $servername = "localhost";
    // $dbusername = "root";
    // $dbpassword = "";
    // $dbname = "recipeappdb";

    $servername = "sql12.freesqldatabase.com";
    $dbusername = "sql12735218";
    $dbpassword = "brr4UjlYLA";
    $dbname = "sql12735218";
    $port = 3306;

    try {
        $conn = new PDO("mysql:host=$servername;dbname=$dbname", $dbusername, $dbpassword);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    }catch(PDOException $e) {
        echo "Connection failed: " . $e->getMessage();
        die;  
    }
?>