<?php
$servername = "localhost";
$dbusername = "root";
$dbpassword = "";
$conn = new mysqli($servername, $dbusername, $dbpassword, "qlkstc_project_ii");
if($conn->connect_error) {
  die("Connection failed.");
}
?>