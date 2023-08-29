<?php
// Create connection
$conn = mysqli_connect($_POST['host'], $_POST['user'], $_POST['pwd'], $_POST['dbname']);

// Check connection
if (!$conn) {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
} else {
  // This SQL statement selects ALL from the table 'Locations'
  $sql = "SELECT NAME, CATEGORY, RATE FROM taxes ORDER BY RATE";

  // Check if there are results
  if ($result = mysqli_query($conn, $sql)) {
    // If so, then create a results array and a temporary one to hold the data
    $resultArray = array();
    $tempArray = array();

    // Loop through each row in the result set
    while ($row = $result->fetch_object()) {
      $tempArray = $row;
      array_push($resultArray, $tempArray);
    }

    // Finally, encode the array to JSON and output the results
    echo json_encode($resultArray);
  }
}
// Close connections
mysqli_close($conn);
