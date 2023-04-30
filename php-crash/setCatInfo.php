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

$return = array();
$return["catID"] = -1;

//EXECUTE QUERY
$sql = "SELECT catID 
        FROM cat
        WHERE ownerID = ? AND catName = ? AND catGender = ? 
        AND catAge = ? AND catVaccination = ? AND catSpecies = ? AND catAppearance = ?
        AND catSterilization = ? AND catPhysicalCondition = ? AND catWeight = ? AND catWeightLevel = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issiissisdi", $_POST["ownerID"],$_POST["catName"], $_POST["catGender"], $_POST["catAge"], $_POST["catVaccination"]
, $_POST["catSpecies"], $_POST["catAppearance"], $_POST["catSterilization"], $_POST["catPhysicalCondition"], $_POST["catWeight"], $_POST["catWeightLevel"]);
$stmt->execute();
$result = $stmt->get_result();
if($result->num_rows != 0) {
    $return["catID"] = $result->fetch_array(MYSQLI_ASSOC)["catID"];
    uploadImage($return["catID"], $conn);
    echo json_encode($return);
    $conn->close();
    exit();
}

//EXECUTE QUERY
$sql = "INSERT INTO cat(ownerID, catName, catGender, catAge, catVaccination,
catSpecies, catAppearance, catSterilization, catPhysicalCondition, catWeight, catWeightLevel) VALUES (?,?,?,?,?,?,?,?,?,?,?);";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issiissisdi", $_POST["ownerID"],$_POST["catName"], $_POST["catGender"], $_POST["catAge"], $_POST["catVaccination"]
, $_POST["catSpecies"], $_POST["catAppearance"], $_POST["catSterilization"], $_POST["catPhysicalCondition"], $_POST["catWeight"], $_POST["catWeightLevel"]);
$stmt->execute();

//EXECUTE QUERY
$sql = "SELECT catID 
        FROM cat
        WHERE ownerID = ? AND catName = ? AND catGender = ? 
        AND catAge = ? AND catVaccination = ? AND catSpecies = ? AND catAppearance = ?
        AND catSterilization = ? AND catPhysicalCondition = ? AND catWeight = ? AND catWeightLevel = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issiissisdi", $_POST["ownerID"],$_POST["catName"], $_POST["catGender"], $_POST["catAge"], $_POST["catVaccination"]
, $_POST["catSpecies"], $_POST["catAppearance"], $_POST["catSterilization"], $_POST["catPhysicalCondition"], $_POST["catWeight"], $_POST["catWeightLevel"]);
$stmt->execute();
$result = $stmt->get_result();
$return["catID"] = $result->fetch_array(MYSQLI_ASSOC)["catID"];
uploadImage($return["catID"], $conn);
echo json_encode($return);
$conn->close();
exit();


function uploadImage($catID, $conn) {
    if(!isset($_POST["catImage"])) return;
    $bin = base64_decode($_POST["catImage"]);
    $image = imagecreatefromstring($bin);
    $path = "image/cat/" . $catID . ".png";
    imagepng($image, $path, 0);
    $sql = "UPDATE cat SET catImage = ? WHERE catID = ?;";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $path, $catID);
    $stmt->execute();
}
?>