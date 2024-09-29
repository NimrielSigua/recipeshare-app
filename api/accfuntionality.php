<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

class User
{
    function getUserInfo($userId)
    {
        include "connection.php";

        $sql = "SELECT user_id, username, fullname, profile_image FROM users WHERE user_id = :user_id";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":user_id", $userId);
        $stmt->execute();
        $returnvalue = $stmt->fetch(PDO::FETCH_ASSOC);
        unset($conn); unset($stmt);
        return json_encode($returnvalue);
    }

    function addRecipe($data)
    {
        include "connection.php";

        // Start a transaction
        $conn->beginTransaction();

        try {
            // Insert into recipestbl
            $sql = "INSERT INTO recipestbl (recipe_name, cooking_time, ingredients, user_id) VALUES (:recipe_name, :cooking_time, :ingredients, :user_id)";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':recipe_name', $data['recipe_name']);
            $stmt->bindParam(':cooking_time', $data['cooking_time']);
            $stmt->bindParam(':ingredients', $data['ingredients']);
            $stmt->bindParam(':user_id', $data['user_id']);
            $stmt->execute();

            $recipe_id = $conn->lastInsertId();

            // Insert steps into cookingstepstbl
            $sql = "INSERT INTO cookingstepstbl (recipe_id, steps) VALUES (:recipe_id, :steps)";
            $stmt = $conn->prepare($sql);

            foreach ($data['steps'] as $step) {
                $stmt->bindParam(':recipe_id', $recipe_id);
                $stmt->bindParam(':steps', $step);
                $stmt->execute();
            }

            // Commit the transaction
            $conn->commit();

            return json_encode(['success' => true, 'message' => 'Recipe added successfully']);
        } catch (Exception $e) {
            // An error occurred; rollback the transaction
            $conn->rollBack();
            return json_encode(['success' => false, 'message' => 'Failed to add recipe: ' . $e->getMessage()]);
        }
    }
}

$user = new User();

try {
    if ($_SERVER['REQUEST_METHOD'] == 'GET') {
        $operation = $_GET['operation'];
        
        switch ($operation) {
            case "getUserInfo":
                echo $user->getUserInfo($_GET['user_id']);
                break;
            default:
                echo json_encode(["error" => "Invalid operation"]);
                break;
        }
    } elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Invalid JSON: ' . json_last_error_msg());
        }
        
        $operation = $data['operation'];
        
        switch ($operation) {
            case "addRecipe":
                echo $user->addRecipe($data);
                break;
            default:
                echo json_encode(["error" => "Invalid operation"]);
                break;
        }
    } else {
        echo json_encode(["error" => "Invalid request method"]);
    }
} catch (Exception $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
