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

    function register($data, $file)
    {
        include "connection.php";
        
        $username = $data['username'];
        $password = $data['password'];
        $fullname = $data['fullname'];
        $profile_image = '';
    
        // Handle file upload
        if (isset($file['profile_image'])) {
            $target_dir = "../assets/images/";
            $file_name = basename($file["profile_image"]["name"]);
            $target_file = $target_dir . $file_name;
            $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

            // Check if image file is a actual image or fake image
            $check = getimagesize($file["profile_image"]["tmp_name"]);
            if($check === false) {
                return json_encode(['success' => false, 'message' => "File is not an image."]);
            }

            // Check file size
            if ($file["profile_image"]["size"] > 500000) {
                return json_encode(['success' => false, 'message' => "Sorry, your file is too large."]);
            }

            // Allow certain file formats
            if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
            && $imageFileType != "gif" ) {
                return json_encode(['success' => false, 'message' => "Sorry, only JPG, JPEG, PNG & GIF files are allowed."]);
            }

            // Generate a unique filename
            $new_file_name = uniqid() . '.' . $imageFileType;
            $target_file = $target_dir . $new_file_name;

            if (move_uploaded_file($file["profile_image"]["tmp_name"], $target_file)) {
                $profile_image = "images/" . $new_file_name;
            } else {
                return json_encode(['success' => false, 'message' => "Sorry, there was an error uploading your file."]);
            }
        }
    
        $sql = "INSERT INTO users (username, password, fullname, profile_image) ";
        $sql .= "VALUES (:username, :password, :fullname, :profile_image)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $username);
        $stmt->bindParam(":password", $password);
        $stmt->bindParam(":fullname", $fullname);
        $stmt->bindParam(":profile_image", $profile_image);
        
        if ($stmt->execute()) {
            return json_encode(['success' => true, 'message' => 'Registration successful']);
        } else {
            return json_encode(['success' => false, 'message' => 'Registration failed']);
        }
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
