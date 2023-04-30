<?php
//CORS SETUP
header('Access-Control-Allow-Origin: *');
// Specify which request methods are allowed
header('Access-Control-Allow-Methods: PUT, GET, POST, DELETE, OPTIONS');
// Additional headers which may be sent along with the CORS request
header('Access-Control-Allow-Headers: *');
// Set the age to 1 day to improve speed/caching.
header('Access-Control-Max-Age: 86400');
//header("Access-Control-Allow-Credentials: true");
// Exit early so the page isn't fully loaded for options requests
if (strtolower($_SERVER['REQUEST_METHOD']) == 'options') {
    exit();
}

require_once "config.php";

//QUIT IF NOT RECEIVED DATA
if(!isset($_POST["sessionID"])){
    echo json_encode([]);
    $conn->close();
    exit();
}

//QUIT IF SESSIONID NOT TRUE
$sql = "SELECT * FROM login WHERE session = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $_POST["sessionID"]);
$stmt->execute();
$result = $stmt->get_result();
if($result->num_rows == 0) {
    echo json_encode([]);
    $conn->close();
    exit();
}

//EXECUTE QUERY
$sql = "SELECT * FROM service";
$stmt = $conn->prepare($sql);
$stmt->execute();

//RETURN
$result = $stmt->get_result();
echo json_encode($result->fetch_all(MYSQLI_ASSOC));

?>