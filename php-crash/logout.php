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

//DATABASE CONNECTION SETUP
require_once "config.php";

//QUIT IF NOT RECEIVED SESSIONID
if(!isset($_POST["sessionID"])){
    echo json_encode(null);
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

//GET USERNAME
$sql = "SELECT username FROM login WHERE session = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $_POST["sessionID"]);
$stmt->execute();
$result = $stmt->get_result();
$username = $result->fetch_array(MYSQLI_ASSOC)["username"];

//EXECUTE QUERY
$sql = "UPDATE login SET session = NULL WHERE session = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $_POST["sessionID"]);
$stmt->execute();

//HISTORY RECORD
date_default_timezone_set("Asia/Ho_Chi_Minh");
$currentTime = date("Y-m-d h:i:s");
$sql = "INSERT INTO history(action, time, perfomer) VALUES (\"Đăng xuất\", \"$currentTime\", \"$username\")";
$stmt = $conn->prepare($sql);
$stmt->execute();

$conn->close();
?>