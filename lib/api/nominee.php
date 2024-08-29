<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

class Nomination {
    function addNominees($json){
        include 'connection.php';

        $json = json_decode($json, true);

        $imageUrl = $json['file'];  

        // Decode the base64 image data
        $imageDataDecoded = base64_decode($imageUrl);

        // Directory where the image will be stored
        $targetDir = './images/';

        // Determine the MIME type of the image
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->buffer($imageDataDecoded);

        // Define possible image extensions based on MIME type
        $extensions = [
            'image/jpeg' => '.jpg',
            'image/png' => '.png',
            'image/gif' => '.gif',
            'image/webp' => '.webp',
            'image/bmp' => '.bmp',
        ];

        // Assign the appropriate extension, defaulting to '.jpg'
        $extension = isset($extensions[$mime]) ? $extensions[$mime] : '.jpg';

        // Generate a random string for the filename
        $randomString = bin2hex(random_bytes(5));

        // Construct the target filename
        $filename = $randomString . $extension;
        $targetFile = $targetDir . $filename;

        // Save the decoded image data to the specified file path
        if (file_put_contents($targetFile, $imageDataDecoded)){
            try {
                // Prepare the SQL insert statement
                $sql = "INSERT INTO tbl_nomination (nomination_name, nomination_imageUrl, nomination_gender, nomination_time) 
                        VALUES (:name, :imageUrl, :gender, :time)";
                $stmt = $conn->prepare($sql);

                // Bind parameters to the prepared statement
                $stmt->bindParam(':name', $json['name']);
                $stmt->bindParam(':imageUrl', $filename);
                $stmt->bindParam(':gender', $json['gender']);
                $stmt->bindParam(':time', $json['time']);

                // Execute the statement
                $stmt->execute();
                
                return json_encode(['status' => 'success', 'message' => 'Nominee added successfully']);
            } catch (PDOException $e) {
                return json_encode(['status' => 'error', 'message' => $e->getMessage()]);
            } finally {
                // Close the database connection
                $conn = null;
            }
        } else {
            return json_encode(['status' => 'error', 'message' => 'Failed to save image']);
        }
    }

    function getNominees() {
        include "connection.php";
    
        try {
            $sql = "SELECT * FROM tbl_nomination";
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

$nomination = new Nomination();
switch ($operation){
    case "addNominees":
        echo $nomination->addNominees($json); 
        break;
    case "getNominees":
        echo $nomination->getNominees(); 
        break;
    default:
        echo json_encode(['status' => 'error', 'message' => 'Invalid operation']);
        break;
}
?>
