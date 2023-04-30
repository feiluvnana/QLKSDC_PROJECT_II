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

$return = array();
$return["message"] = "";

//EXECUTE QUERY
$sql = "SELECT *
        FROM booking
        WHERE roomID = ? AND subNumber = ? AND
        ((checkInDate BETWEEN ? AND ?) OR
        (checkOutDate BETWEEN ? AND ?))";
$stmt = $conn->prepare($sql);
$stmt->bind_param("iissss", $_POST["roomID"], $_POST["subNumber"], $_POST["checkInDate"], $_POST["checkOutDate"],
$_POST["checkInDate"], $_POST["checkOutDate"]);
$stmt->execute();
$result = $stmt->get_result();
if($result->num_rows != 0) {
    $return["message"] = "Không thể đặt phòng do đã có khách đặt trước.";
    echo json_encode($return);
    $conn->close();
    exit();
}

//EXECUTE QUERY
$sql = "SELECT * FROM login WHERE session = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $_POST["sessionID"]);
$stmt->execute();
$result = $stmt->get_result();
$repName = $result->fetch_array(MYSQLI_ASSOC)["fullname"];

date_default_timezone_set("Asia/Ho_Chi_Minh");
$bookingDate = date("Y-m-d h:i:s");

//EXECUTE QUERY
$sql = "INSERT INTO booking(roomID, catID, bookingDate, subNumber, checkInDate, checkOutDate, attention, note, byRep, eatingRank) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sisisssssi", $_POST["roomID"], $_POST["catID"], $bookingDate, $_POST["subNumber"], $_POST["checkInDate"], $_POST["checkOutDate"], $_POST["attention"], $_POST["note"], $repName, $_POST["eatingRank"]);
$stmt->execute();

//EXECUTE QUERY


$return["message"] = "Đã đặt phòng thành công.";
echo json_encode($return);
$conn->close();
exit();
?>