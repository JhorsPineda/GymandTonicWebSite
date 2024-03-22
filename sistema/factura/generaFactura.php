<?php
	session_start();
	if(empty($_SESSION['active']))
	{
		header('location: ../');
	}
	include "../../conexion.php";
	if(empty($_REQUEST['cl']) || empty($_REQUEST['f']))
	{
		echo "No es posible generar la factura.";
	}else{
		$codCliente = $_REQUEST['cl'];
		$noFactura = $_REQUEST['f'];
		$consulta = mysqli_query($conexion, "SELECT * FROM configuracion");
		$resultado = mysqli_fetch_assoc($consulta);
		$ventas = mysqli_query($conexion, "SELECT * FROM factura WHERE nofactura = $noFactura");
		$result_venta = mysqli_fetch_assoc($ventas);
		$clientes = mysqli_query($conexion, "SELECT * FROM cliente WHERE idcliente = $codCliente");
		$result_cliente = mysqli_fetch_assoc($clientes);
		$productos = mysqli_query($conexion, "SELECT d.nofactura, d.codproducto, d.cantidad, p.codproducto, p.descripcion, p.precio FROM detallefactura d INNER JOIN producto p ON d.nofactura = $noFactura WHERE d.codproducto = p.codproducto");
		require_once 'fpdf/fpdf.php';
		$pdf = new FPDF('L', 'mm', array(120, 170)); // Cambiado a 'L' (horizontal) y ajustado el ancho a 150mm
		$pdf->AddPage();
		$pdf->SetMargins(1, 0, 0);
		$pdf->SetTitle("Venta #" . $noFactura); // Aquí se agrega el número de venta al título
		$pdf->SetFont('Arial', 'B', 9);
		$pdf->Cell(150, 5, "GYM & TONIC", 0, 1, 'C'); // Cambiado el nombre del vendedor a "GYM & TONIC"
		$pdf->SetFont('Arial', '', 9);
		$pdf->Ln();
		$pdf->image("img/logo.png", 100, 18, 30, 30, 'PNG'); // Ajustado la posición y el tamaño del logo
		
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(15, 5, "NIT: ", 0, 0, 'L');
		$pdf->SetFont('Arial', '', 7);	
		$pdf->Cell(20, 5, $resultado['documento'], 0, 1, 'L');
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(15, 5, utf8_decode("Teléfono: "), 0, 0, 'L');
		$pdf->SetFont('Arial', '', 7);
		$pdf->Cell(20, 5, $resultado['telefono'], 0, 1, 'L');
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(15, 5, utf8_decode("Dirección: "), 0, 0, 'L');
		$pdf->SetFont('Arial', '', 7);
		$pdf->Cell(20, 5, utf8_decode($resultado['direccion']), 0, 1, 'L');
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(15, 5, "Ticked: ", 0, 0, 'L');
		$pdf->SetFont('Arial', '', 7);
		$pdf->Cell(20, 5, $noFactura, 0, 0, 'L');
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(16, 5, "Fecha: ", 0, 0, 'R');
		$pdf->SetFont('Arial', '', 7);
		$pdf->Cell(25, 5, $result_venta['fecha'], 0, 1, 'R');
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(150, 5, "Datos del cliente", 0, 1, 'C'); // Ajustado el ancho de la celda para centrar el título
		$pdf->Cell(75, 5, "Nombre", 0, 0, 'C');
		$pdf->Cell(37, 5, utf8_decode("Teléfono"), 0, 0, 'C');
		$pdf->Cell(38, 5, utf8_decode("Dirección"), 0, 1, 'C');
		$pdf->SetFont('Arial', '', 7);
		$pdf->Cell(75, 5, utf8_decode($result_cliente['nombre']), 0, 0, 'C');
		$pdf->Cell(37, 5, utf8_decode($result_cliente['telefono']), 0, 0, 'C');
		$pdf->Cell(38, 5, utf8_decode($result_cliente['direccion']), 0, 1, 'C');
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(150, 5, "Detalle de Productos", 0, 1, 'C'); // Ajustado el ancho de la celda para centrar el título
		$pdf->SetTextColor(0, 0, 0);
		$pdf->SetFont('Arial', 'B', 7);
		$pdf->Cell(90, 5, 'Nombre', 0, 0, 'C'); // Ajustado el ancho de la celda para centrar el título
		$pdf->Cell(20, 5, 'Cant', 0, 0, 'C');
		$pdf->Cell(20, 5, 'Precio', 0, 0, 'C');
		$pdf->Cell(20, 5, 'Total', 0, 1, 'C');
		$pdf->SetFont('Arial', '', 7);
		while ($row = mysqli_fetch_assoc($productos)) {
			$pdf->Cell(90, 5, utf8_decode($row['descripcion']), 0, 0, 'C'); // Ajustado el ancho de la celda para centrar el título
			$pdf->Cell(20, 5, $row['cantidad'], 0, 0, 'C');
			$pdf->Cell(20, 5, number_format($row['precio'], 2, '.', ','), 0, 0, 'C');
			$importe = number_format($row['cantidad'] * $row['precio'], 2, '.', ',');
			$pdf->Cell(20, 5, $importe, 0, 1, 'C');
		}
		$pdf->Ln();
		$pdf->SetFont('Arial', 'B', 10);

		$pdf->Cell(150, 5, 'Total: ' . number_format($result_venta['totalfactura'], 2, '.', ','), 0, 1, 'C'); // Ajustado el ancho de la celda para centrar el título
		$pdf->Ln();
		$pdf->SetFont('Arial', '', 7);
		$pdf->Cell(150, 5, utf8_decode("Gracias por su preferencia"), 0, 1, 'C'); // Ajustado el ancho de la celda para centrar el título
		$pdf->Output("compra.pdf", "I");
	}

?>
