<?php


$filename = "productos.xls";

header("Content-Type: application/vnd.ms-excel");
header("Content-Disposition: attachment; filename=\"$filename\"");

include "../../conexion.php";

$query = mysqli_query($conexion, "SELECT * FROM producto");
$result = mysqli_num_rows($query);

if ($result > 0) {
  echo "ID\tDescripción\tPrecio\tExistencia\n";

  while ($data = mysqli_fetch_assoc($query)) {
    echo $data['codproducto'] . "\t" . $data['descripcion'] . "\t" . $data['precio'] . "\t" . $data['existencia'] . "\n";
  }
}

header("Location: ../lista_productos.php");
exit;

?>
