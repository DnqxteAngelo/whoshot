<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

class Vote {
    function addVote($json){
        include 'connection.php';
    
        $json = json_decode($json, true);
        $nominationId = $json['nominationId'];
        $time = $json['time'];
        $userId = $json['userId'];
    
        // Retrieve the gender of the nominee being voted for
        $genderSql = "SELECT nomination_gender FROM tbl_nomination WHERE nomination_id = :nominationId";
        $genderStmt = $conn->prepare($genderSql);
        $genderStmt->bindParam(':nominationId', $nominationId);
        $genderStmt->execute();
        $gender = $genderStmt->fetchColumn();
    
        if (!$gender) {
            return json_encode(['status' => 'error', 'message' => 'Invalid nomination ID.']);
        }
    
        // Check if the IP has already voted for this gender
        $checkSql = "SELECT COUNT(*) FROM tbl_votes 
                     INNER JOIN tbl_nomination ON tbl_votes.vote_nominationId = tbl_nomination.nomination_id
                     WHERE tbl_nomination.nomination_gender = :gender AND tbl_votes.vote_userId = :userId";
        $checkStmt = $conn->prepare($checkSql);
        $checkStmt->bindParam(':gender', $gender);
        $checkStmt->bindParam(':userId', $userId);
        $checkStmt->execute();
    
        $hasVoted = $checkStmt->fetchColumn();
    
        if ($hasVoted > 0) {
            // User has already voted for this gender
            return json_encode(['status' => 'error', 'message' => 'You have already voted for this gender.']);
        }
    
        // Proceed with voting
        $sql = "INSERT INTO tbl_votes(vote_nominationId, vote_time, vote_userId) VALUES(:nominationId, :time, :userId)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':nominationId', $nominationId);
        $stmt->bindParam(':time', $time);
        $stmt->bindParam(':userId', $userId);
        $stmt->execute();
    
        $returnValue = $stmt->rowCount() > 0 ? json_encode(['status' => 'success', 'message' => 'Vote successfully added.']) : json_encode(['status' => 'error', 'message' => 'Failed to add vote.']);
    
        return $returnValue;
    }
    

    function getRankings() {
        include "connection.php";
    
        try {
            $sql = "SELECT 
                n.nomination_id, 
                n.nomination_name,
                n.nomination_imageUrl, 
                n.nomination_gender,
                n.nomination_time,
                COUNT(v.vote_id) AS total_votes
            FROM 
                tbl_nomination n
            LEFT JOIN 
                tbl_votes v 
            ON 
                n.nomination_id = v.vote_nominationId
            GROUP BY 
                n.nomination_id, 
                n.nomination_name,
                n.nomination_imageUrl,
                n.nomination_gender,
                n.nomination_time
            ORDER BY 
                total_votes DESC;";
            $stmt = $conn->prepare($sql);
            $stmt->execute();
            $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            return json_encode(['status' => 'success', 'data' => $returnValue]);
        } catch (PDOException $e) {
            return json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        } finally {
            // Close the database connection
            $conn = null;
        }
    }
}

$json = isset($_POST['json']) ? $_POST['json'] : "";
$operation = isset($_POST['operation']) ? $_POST['operation'] : "";

$vote = new Vote();
switch ($operation){
    case "addVote":
        echo $vote->addVote($json); 
        break;
    case "getRankings":
        echo $vote->getRankings(); 
        break;
    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid operation']);
        break;
}
?>
