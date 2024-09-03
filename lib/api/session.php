<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Allow specific HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With"); // Allow specific headers


class Session {
    function nominationSession($json) {
        include 'connection.php';

        $json = json_decode($json, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
        }
        $sql = "UPDATE tbl_sessions SET nomination_start = :nomination_start, nomination_end = :nomination_end WHERE id = 1";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':nomination_start', $json['nomination_start']);
        $stmt->bindParam(':nomination_end', $json['nomination_end']);
        $stmt->execute();
        return json_encode(['status' => $stmt->rowCount() > 0 ? 'success' : 'error']);
    }

    function votingSession($json) {
        include 'connection.php';
        $json = json_decode($json, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
        }
        $sql = "UPDATE tbl_sessions SET voting_start = :voting_start, voting_end = :voting_end WHERE id = 1";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':voting_start', $json['voting_start']);
        $stmt->bindParam(':voting_end', $json['voting_end']);
        $stmt->execute();
        return json_encode(['status' => $stmt->rowCount() > 0 ? 'success' : 'error']);
    }

    function getNominationSession() {
        include 'connection.php';
        $sql = "SELECT nomination_start, nomination_end FROM tbl_sessions WHERE id = 1";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return json_encode(['status' => 'success', 'data' => $returnValue]);
    }

    function getVotingSession() {
        include 'connection.php';
        $sql = "SELECT voting_start, voting_end FROM tbl_sessions WHERE id = 1";
        $stmt = $conn->prepare($sql);
        $stmt->execute();
        $returnValue = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return json_encode(['status' => 'success', 'data' => $returnValue]);
    }
}

$json = isset($_POST['json']) ? $_POST['json'] : "";
$operation = isset($_POST['operation']) ? $_POST['operation'] : '';

$session = new Session();
switch ($operation) {
    case "nominationSession":
        echo $session->nominationSession($json);
        break;
    case "votingSession":
        echo $session->votingSession($json);
        break;
    case "getNominationSession":
        echo $session->getNominationSession();
        break;
    case "getVotingSession":
        echo $session->getVotingSession();
        break;
    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid operation']);
        break;
}
?>
