<?php

$prefix = "Hello, this is iteration number: ";
$chunk = "";
$stdout = fopen("php://stdout", "wb");

for ($n = 0; $n < 1000000; $n++) {
	$chunk .= $prefix . $n . "\n";
	if ($n % 10000 === 9999) {
		fwrite($stdout, $chunk);
		$chunk = "";
	}
}

if ($chunk !== "") {
	fwrite($stdout, $chunk);
}
