<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
class User
{
    function login($json)
    {
        include "connection.php";

        $json = json_decode($json, true);

        $sql = "SELECT * FROM users WHERE username  = :username AND password = :password";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $json['username']);
        $stmt->bindParam(":password", $json['password']);
        $stmt->execute();
        $returnvalue = $stmt->fetchAll(PDO::FETCH_ASSOC);
        unset($conn); unset($stmt);
        return json_encode($returnvalue);
    }

    function register($json)
    {
        include "connection.php";

        $json = json_decode($json, true);

        $sql = "INSERT INTO users (username, password, fullname) ";
        $sql .= "VALUES (:username, :password, :fullname)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $json['username']);
        $stmt->bindParam(":password", $json['password']);
        $stmt->bindParam(":fullname", $json['fullname']);
        $stmt->execute();
        $returnvalue = $stmt->rowCount() > 0 ? 1 : 0;
        unset($conn); unset($stmt);
        return json_encode($returnvalue);
    }
}

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $operation = $_GET['operation'];
    $json = $_GET['json'];
} else if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $operation = $_POST['operation'];
    $json = $_POST['json'];
}

$user = new User();
switch ($operation) {
    case "login":
        echo $user->login($json);
        break;
    case "register":
        echo $user->register($json);
        break;
}
