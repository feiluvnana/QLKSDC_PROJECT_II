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
if(!isset($_POST["sessionID"]) || !isset($_POST["ownerID"]) || !isset($_POST["name"]) || !isset($_POST["age"]) || !isset($_POST["vaccination"]) || !isset($_POST["sterilization"]) || !isset($_POST["physicalCondition"])){
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
        AND age = ? AND vaccination = ? AND species = ? AND appearance = ?
        AND sterilization = ? AND physicalCondition = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issiissis", $_POST["ownerID"],$_POST["name"], $_POST["gender"], $_POST["age"], $_POST["vaccination"]
, $_POST["species"], $_POST["appearance"], $_POST["sterilization"], $_POST["physicalCondition"]);
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
$sql = "INSERT INTO cat(ownerID, catName, catGender, age, vaccination,
species, appearance, sterilization, physicalCondition) VALUES (?,?,?,?,?,?,?,?,?);";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issiissis", $_POST["ownerID"],$_POST["name"], $_POST["gender"], $_POST["age"], $_POST["vaccination"]
, $_POST["species"], $_POST["appearance"], $_POST["sterilization"], $_POST["physicalCondition"]);
$stmt->execute();

//EXECUTE QUERY
$sql = "SELECT catID 
        FROM cat
        WHERE ownerID = ? AND catName = ? AND catGender = ? 
        AND age = ? AND vaccination = ? AND species = ? AND appearance = ?
        AND sterilization = ? AND physicalCondition = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("issiissis", $_POST["ownerID"],$_POST["name"], $_POST["gender"], $_POST["age"], $_POST["vaccination"]
, $_POST["species"], $_POST["appearance"], $_POST["sterilization"], $_POST["physicalCondition"]);
$stmt->execute();
$result = $stmt->get_result();
$return["catID"] = $result->fetch_array(MYSQLI_ASSOC)["catID"];
uploadImage($return["catID"], $conn);
echo json_encode($return);
$conn->close();
exit();


function uploadImage($catID, $conn) {
    $bin = base64_decode($_POST["image"]);
    $image = imagecreatefromstring($bin);
    $path = "image/cat/" . $catID . ".png";
    imagepng($image, $path, 0);
    $sql = "UPDATE cat SET catImage = ? WHERE catID = ?;";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $path, $catID);
    $stmt->execute();
}
?>