<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

class Results {
    private $conn;

    function __construct() {
        include "connection.php";
        $this->conn = $conn;
    }

    function addWinner($json){
        $json = json_decode($json, true);
        $femaleId = $json['femaleId'];
        $maleId = $json['maleId'];
        $time = $json['time'];

        $sql = "INSERT INTO tbl_results (result_femaleId, result_maleId, result_time) ";
        $sql .= "VALUES (:femaleId, :maleId, :time)";

        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(":femaleId", $femaleId);
        $stmt->bindParam(":maleId", $maleId);
        $stmt->bindParam(":time", $time);

        $stmt->execute();
        $returnValue = $stmt->rowCount() > 0 ? 1 : 0;

        return $returnValue;
    }

    function getWinners() {
        // Query to get the female winner with the highest votes
        $sql_female = "SELECT n.nomination_id, n.nomination_name, n.nomination_imageUrl, n.nomination_gender, COUNT(v.vote_id) AS total_votes FROM tbl_nomination n
                        LEFT JOIN tbl_votes v ON v.vote_nominationId = n.nomination_id 
                        WHERE n.nomination_gender = 'Female' 
                        GROUP BY 
                                        n.nomination_id, 
                                        n.nomination_name,
                                        n.nomination_imageUrl,
                                        n.nomination_gender 
                        ORDER BY total_votes DESC LIMIT 1;";
        $stmt_female = $this->conn->prepare($sql_female);
        $stmt_female->execute();
        $femaleWinner = $stmt_female->fetch(PDO::FETCH_ASSOC);

        // Query to get the male winner with the highest votes
        $sql_male = "SELECT n.nomination_id, n.nomination_name, n.nomination_imageUrl, n.nomination_gender, COUNT(v.vote_id) AS total_votes FROM tbl_nomination n
                        LEFT JOIN tbl_votes v ON v.vote_nominationId = n.nomination_id 
                        WHERE n.nomination_gender = 'Male' 
                        GROUP BY 
                                        n.nomination_id, 
                                        n.nomination_name,
                                        n.nomination_imageUrl,
                                        n.nomination_gender 
                        ORDER BY total_votes DESC LIMIT 1;";
        $stmt_male = $this->conn->prepare($sql_male);
        $stmt_male->execute();
        $maleWinner = $stmt_male->fetch(PDO::FETCH_ASSOC);

        $winners = [
            'female' => $femaleWinner,
            'male' => $maleWinner
        ];

        return $winners;
    }

    function getAndAddWinners() {
        date_default_timezone_set('Asia/Manila');
        
        $winners = $this->getWinners();
        $femaleWinnerId = $winners['female']['nomination_id'];
        $maleWinnerId = $winners['male']['nomination_id'];
        $time = date('Y-m-d H:i:s'); // Current time

        // Add the winners to the tbl_results
        $json = json_encode([
            'femaleId' => $femaleWinnerId,
            'maleId' => $maleWinnerId,
            'time' => $time
        ]);
        $result = $this->addWinner($json);

        return json_encode([
            'status' => $result ? 'success' : 'error',
            'female' => $winners['female'],
            'male' => $winners['male']
        ]);
    }

    function getResultDetails() {
        $sql = "SELECT 
                    n_f.nomination_id AS female_nomination_id,
                    n_f.nomination_name AS female_nomination_name,
                    n_f.nomination_imageUrl AS female_nomination_imageUrl,
                    n_m.nomination_id AS male_nomination_id,
                    n_m.nomination_name AS male_nomination_name,
                    n_m.nomination_imageUrl AS male_nomination_imageUrl,
                    r.result_time
                FROM 
                    tbl_results r
                INNER JOIN 
                    tbl_nomination n_f ON r.result_femaleId = n_f.nomination_id
                INNER JOIN 
                    tbl_nomination n_m ON r.result_maleId = n_m.nomination_id
                WHERE 
                    r.result_time IS NOT NULL";
    
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        $resultDetails = $stmt->fetchAll(PDO::FETCH_ASSOC); // Fetch all results
    
        return json_encode($resultDetails);
    }
    
}

$json = isset($_POST['json']) ? $_POST['json'] : "";
$operation = $_POST['operation'];

$result = new Results();
switch ($operation) {
    case "addWinner":
        echo $result->addWinner($json);
        break;
    case "getWinners":
        echo json_encode($result->getWinners());
        break;
    case "getAndAddWinners":
        echo $result->getAndAddWinners();
        break;
    case "getResultDetails":
        echo $result->getResultDetails();
        break;
}
?>
