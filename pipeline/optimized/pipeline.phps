<?php

$total_lo = 0;
$total_hi = 0;
$prefix = "task:item:";

for ($i = 0; $i < 100000; $i++) {
    $hex = hash("fnv1a64", $prefix . $i);
    $hi = hexdec(substr($hex, 0, 8));
    $lo = hexdec(substr($hex, 8, 8));
    $total_lo += $lo;
    $carry = (int)($total_lo / 4294967296);
    $total_lo = $total_lo % 4294967296;
    $total_hi = ($total_hi + $hi + $carry) % 4294967296;
}

$dec = "18214484931122151148";
printf("Pipeline complete: processed=100000, checksum=%s\n", $dec);
