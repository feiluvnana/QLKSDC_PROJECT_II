<?php
//CORS SETUP
header('Access-Control-Allow-Origin: *');
// Specify which request methods are allowed
header('Access-Control-Allow-Methods: PUT, GET, POST, DELETE, OPTIONS');
// Additional headers which may be sent along with the CORS request
header('Access-Control-Allow-Headers: *');
// Set the age to 1 day to improve speed/caching.
header('Access-Control-Max-Age: 86400');
header("Access-Control-Allow-Credentials: true");
// Exit early so the page isn't fully loaded for options requests
if (strtolower($_SERVER['REQUEST_METHOD']) == 'options') {
    exit();
}

//DATABASE CONNECTION SETUP
require_once "config.php";

//RETURN ARRAY INITIALIZATION
$return = array();
$return["error"] = true;
$return["success"] = false;

//QUIT IF NOT RECEIVED AUTHSTRING
if(!isset($_POST["authString"])){
  echo json_encode($return);
  $conn->close();
  exit();
}

//GET USERNAME AND PASSWORD FROM AUTHSTRING
$userPassData = explode(":", $_POST["authString"]);
$username = $userPassData[0];
$password = $userPassData[1];

//EXECUTE QUERY
$sql = "SELECT * FROM login WHERE username = ? AND password = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $username, $password);
$stmt->execute();
$result = $stmt->get_result();

//LOGIN FAILED BECAUSE OF WRONG PASSWORD OR USERNAME
$return["error"] = false;
if($result->num_rows == 0) {
  echo json_encode($return);
  $conn->close();
  exit();
}
$fullname = $result->fetch_array(MYSQLI_ASSOC)["fullname"];

//PREPARE SESSIONID
$sessionID = generateRandomString();

//INSERT SESSION
$sql = "UPDATE login SET session = ? WHERE username = ? AND password = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $sessionID, $username, $password);
$stmt->execute();
$return["success"] = true;
$return["sessionID"] = $sessionID;
$return["fullname"] = $fullname;

//CREATE HISTORY RECORD
date_default_timezone_set("Asia/Ho_Chi_Minh");
$currentTime = date("Y-m-d h:i:s");
$sql = "INSERT INTO history(action, time, perfomer) VALUES (\"Đăng nhập\", \"$currentTime\", \"$username\")";
$stmt = $conn->prepare($sql);
//$stmt->execute();

//RETURN
echo json_encode($return);
$conn->close();
exit();

//Function
function generateRandomString($length = 10) {
  return substr(str_shuffle(str_repeat($x='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil($length/strlen($x)) )),1,$length);
}
?>