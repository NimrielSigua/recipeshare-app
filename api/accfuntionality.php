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

    function addRecipe($data, $file)
    {
        include "connection.php";

        // Start a transaction
        $conn->beginTransaction();

        try {
            // Handle file upload
            $target_dir = "../assets/images/";
            $original_filename = basename($file["recipe_image"]["name"]);
            $imageFileType = strtolower(pathinfo($original_filename, PATHINFO_EXTENSION));

            // Generate a unique filename
            $unique_filename = uniqid() . '_' . $original_filename;
            $target_file = $target_dir . $unique_filename;

            // Check if image file is a actual image or fake image
            $check = getimagesize($file["recipe_image"]["tmp_name"]);
            if($check === false) {
                throw new Exception("File is not an image.");
            }

            // Check file size
            if ($file["recipe_image"]["size"] > 500000) {
                throw new Exception("Sorry, your file is too large.");
            }

            // Allow certain file formats
            if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg"
            && $imageFileType != "gif" ) {
                throw new Exception("Sorry, only JPG, JPEG, PNG & GIF files are allowed.");
            }

            if (!move_uploaded_file($file["recipe_image"]["tmp_name"], $target_file)) {
                throw new Exception("Sorry, there was an error uploading your file.");
            }

            // Convert mealtype array to comma-separated string
            $mealtype = implode(',', json_decode($data['mealtype']));

            // Insert into recipestbl
            $sql = "INSERT INTO recipestbl (recipe_name, cooking_time, ingredients, user_id, mealtype, description, recipe_image) 
                    VALUES (:recipe_name, :cooking_time, :ingredients, :user_id, :mealtype, :description, :recipe_image)";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':recipe_name', $data['recipe_name']);
            $stmt->bindParam(':cooking_time', $data['cooking_time']);
            $stmt->bindParam(':ingredients', $data['ingredients']);
            $stmt->bindParam(':user_id', $data['user_id']);
            $stmt->bindParam(':mealtype', $mealtype);
            $stmt->bindParam(':description', $data['description']);
            $stmt->bindParam(':recipe_image', $unique_filename);
            $stmt->execute();

            $recipe_id = $conn->lastInsertId();

            // Insert steps into cookingstepstbl
            $sql = "INSERT INTO cookingstepstbl (recipe_id, steps) VALUES (:recipe_id, :steps)";
            $stmt = $conn->prepare($sql);

            foreach (json_decode($data['steps']) as $step) {
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

    function getUserRecipes($userId)
    {
        include "connection.php";

        $sql = "SELECT r.user_id, r.recipe_id, r.recipe_name, r.description, r.recipe_image, r.cooking_time, r.ingredients, r.mealtype, 
                GROUP_CONCAT(cs.steps ORDER BY cs.cookingsteps_id SEPARATOR '||') as steps
                FROM recipestbl r
                LEFT JOIN cookingstepstbl cs ON r.recipe_id = cs.recipe_id
                WHERE r.user_id = :user_id
                GROUP BY r.user_id, r.recipe_id, r.recipe_name, r.description, r.recipe_image, r.cooking_time, r.ingredients, r.mealtype";
        
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":user_id", $userId);
        $stmt->execute();
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        unset($conn); unset($stmt);
        return json_encode($recipes);
    }

    function getAllRecipes()
    {
        include "connection.php";

        $sql = "SELECT r.user_id, r.recipe_id, r.recipe_name, r.description, r.recipe_image, r.cooking_time, r.ingredients, r.mealtype, 
                u.username, u.fullname, u.profile_image,
                GROUP_CONCAT(cs.steps ORDER BY cs.cookingsteps_id SEPARATOR '||') as steps
                FROM recipestbl r
                LEFT JOIN cookingstepstbl cs ON r.recipe_id = cs.recipe_id
                JOIN users u ON r.user_id = u.user_id
                GROUP BY r.user_id, r.recipe_id, r.recipe_name, r.description, r.recipe_image, r.cooking_time, r.ingredients, r.mealtype, u.username, u.fullname, u.profile_image
                ORDER BY r.recipe_id DESC";
        
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        unset($conn); unset($stmt);
        return json_encode($recipes);
    }

    function followUnfollowUser($followerId, $followedId)
    {
        include "connection.php";

        try {
            // Prevent following own account
            if ($followerId == $followedId) {
                return json_encode(['success' => false, 'message' => "You cannot follow your own account"]);
            }

            // Check if already following
            $checkSql = "SELECT * FROM followers WHERE follower_id = :follower_id AND followed_id = :followed_id";
            $checkStmt = $conn->prepare($checkSql);
            $checkStmt->bindParam(':follower_id', $followerId);
            $checkStmt->bindParam(':followed_id', $followedId);
            $checkStmt->execute();

            if ($checkStmt->rowCount() > 0) {
                // Unfollow
                $sql = "DELETE FROM followers WHERE follower_id = :follower_id AND followed_id = :followed_id";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':follower_id', $followerId);
                $stmt->bindParam(':followed_id', $followedId);
                $stmt->execute();
                $action = 'unfollowed';
            } else {
                // Follow
                $sql = "INSERT INTO followers (follower_id, followed_id) VALUES (:follower_id, :followed_id)";
                $stmt = $conn->prepare($sql);
                $stmt->bindParam(':follower_id', $followerId);
                $stmt->bindParam(':followed_id', $followedId);
                $stmt->execute();
                $action = 'followed';
            }

            // Get updated follower count
            $countSql = "SELECT COUNT(*) as follower_count FROM followers WHERE followed_id = :followed_id";
            $countStmt = $conn->prepare($countSql);
            $countStmt->bindParam(':followed_id', $followedId);
            $countStmt->execute();
            $followerCount = $countStmt->fetch(PDO::FETCH_ASSOC)['follower_count'];

            return json_encode(['success' => true, 'message' => "Successfully $action user", 'follower_count' => $followerCount, 'is_following' => ($action === 'followed')]);
        } catch (Exception $e) {
            return json_encode(['success' => false, 'message' => "Failed to $action user: " . $e->getMessage()]);
        }
    }

    function checkFollowStatus($followerId, $followedId)
    {
        include "connection.php";

        $sql = "SELECT * FROM followers WHERE follower_id = :follower_id AND followed_id = :followed_id";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':follower_id', $followerId);
        $stmt->bindParam(':followed_id', $followedId);
        $stmt->execute();

        $isFollowing = $stmt->rowCount() > 0;

        return json_encode(['is_following' => $isFollowing]);
    }

    function getFollowerCount($userId)
    {
        include "connection.php";

        $sql = "SELECT COUNT(*) as follower_count FROM followers WHERE followed_id = :user_id";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        return json_encode(['follower_count' => $result['follower_count']]);
    }

    function getFollowingRecipes($userId)
    {
        include "connection.php";

        try {
            $sql = "SELECT r.*, u.username, u.fullname, u.profile_image 
                    FROM recipestbl r 
                    JOIN users u ON r.user_id = u.user_id 
                    WHERE r.user_id IN (
                        SELECT followed_id 
                        FROM followers 
                        WHERE follower_id = :user_id
                    )
                    ORDER BY r.recipe_id DESC";
            
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':user_id', $userId);
            $stmt->execute();

            $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Always return an array, even if it's empty
            return json_encode($recipes);
        } catch (Exception $e) {
            return json_encode(['error' => $e->getMessage()]);
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
            case "getUserRecipes":
                echo $user->getUserRecipes($_GET['user_id']);
                break;
            case "getAllRecipes":
                echo $user->getAllRecipes();
                break;
            case "getFollowerCount":
                echo $user->getFollowerCount($_GET['user_id']);
                break;
            case "checkFollowStatus":
                echo $user->checkFollowStatus($_GET['follower_id'], $_GET['followed_id']);
                break;
            case "getFollowingRecipes":
                echo $user->getFollowingRecipes($_GET['user_id']);
                break;
            default:
                echo json_encode(["error" => "Invalid operation"]);
                break;
        }
    } elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $operation = $_POST['operation'];
        
        switch ($operation) {
            case "addRecipe":
                echo $user->addRecipe($_POST, $_FILES);
                break;
            case "followUnfollowUser":
                echo $user->followUnfollowUser($_POST['follower_id'], $_POST['followed_id']);
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