<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

class User
{
    function login($data)
    {
        include "connection.php";

        $sql = "SELECT * FROM users WHERE username = :username AND password = :password";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $data['username']);
        $stmt->bindParam(":password", $data['password']);
        $stmt->execute();
        $returnvalue = $stmt->fetchAll(PDO::FETCH_ASSOC);
        unset($conn); unset($stmt);
        return json_encode($returnvalue);
    }

    function register($data, $files)
    {
        include "connection.php";
        
        $username = $data['username'];
        $password = $data['password'];
        $fullname = $data['fullname'];
        $profile_image = '';
    
        if (isset($files['profile_image'])) {
            $target_dir = "../assets/images/";
            if (!file_exists($target_dir)) {
                mkdir($target_dir, 0777, true);
            }
            $target_file = $target_dir . basename($files["profile_image"]["name"]);
            $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
            $newFileName = uniqid() . '.' . $imageFileType;
            $target_file = $target_dir . $newFileName;
    
            if (move_uploaded_file($files["profile_image"]["tmp_name"], $target_file)) {
                $profile_image = "images/" . $newFileName;
            }
        }
    
        $sql = "INSERT INTO users (username, password, fullname, profile_image) ";
        $sql .= "VALUES (:username, :password, :fullname, :profile_image)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $username);
        $stmt->bindParam(":password", $password);
        $stmt->bindParam(":fullname", $fullname);
        $stmt->bindParam(":profile_image", $profile_image);
        $stmt->execute();
        $returnvalue = $stmt->rowCount() > 0 ? 1 : 0;
        unset($conn); unset($stmt);
        return json_encode($returnvalue);
    }
}

$user = new User();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $operation = $_POST['operation'];
    
    switch ($operation) {
        case "login":
            echo $user->login($_POST);
            break;
        case "register":
            echo $user->register($_POST, $_FILES);
            break;
        default:
            echo json_encode(["error" => "Invalid operation"]);
            break;
    }
} else if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $operation = $_GET['operation'];
    
    switch ($operation) {
        case "login":
            echo $user->login($_GET);
            break;
        default:
            echo json_encode(["error" => "Invalid operation"]);
            break;
    }
} else {
    echo json_encode(["error" => "Invalid request method"]);
}
