<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

class Auth {
    function login($json){
        include 'connection.php';

        $json = json_decode($json, true);

        $sql = "SELECT * FROM tbl_user WHERE user_studentId = :studentId";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':studentId', $json['studentId']);
        $stmt->execute();
        $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);

        return json_encode($returnValue);
    }
}

$json = isset($_POST['json']) ? $_POST['json'] : "";
    $operation = $_POST['operation'];

    $auth = new Auth();
    switch ($operation){
        case "login":
            echo $auth->login($json);
            break;
        
    }