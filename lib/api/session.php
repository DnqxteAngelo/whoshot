<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

class Session {
    private $conn;

    public function __construct() {
        include 'connection.php';
        $this->conn = $conn;
    }

    public function nominationSession($json) {
        $json = json_decode($json, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
        }
        $sql = "UPDATE tbl_session SET nomination_start = :nomination_start, nomination_end = :nomination_end WHERE id = 1";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':nomination_start', $json['nomination_start']);
        $stmt->bindParam(':nomination_end', $json['nomination_end']);
        $stmt->execute();
        return json_encode(['status' => $stmt->rowCount() > 0 ? 'success' : 'error']);
    }

    public function votingSession($json) {
        $json = json_decode($json, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
        }
        $sql = "UPDATE tbl_session SET voting_start = :voting_start, voting_end = :voting_end WHERE id = 1";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':voting_start', $json['voting_start']);
        $stmt->bindParam(':voting_end', $json['voting_end']);
        $stmt->execute();
        return json_encode(['status' => $stmt->rowCount() > 0 ? 'success' : 'error']);
    }

    public function getNominationSession() {
        $sql = "SELECT nomination_start, nomination_end FROM tbl_session WHERE id = 1";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    }

    public function getVotingSession() {
        $sql = "SELECT voting_start, voting_end FROM tbl_session WHERE id = 1";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
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
