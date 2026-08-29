<?php

$data_dir = "tree_walk/_data";
if (!is_dir($data_dir)) {
    if (is_dir("_data")) {
        $data_dir = "_data";
    } elseif (is_dir("../_data")) {
        $data_dir = "../_data";
    } elseif (is_dir("../../_data")) {
        $data_dir = "../../_data";
    }
}

$files = [];
if (is_dir($data_dir)) {
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($data_dir));
    foreach ($it as $file) {
        if ($file->isFile() && $file->getExtension() === 'txt') {
            $files[] = $file->getPathname();
        }
    }
}

$total_matches = 0;
foreach ($files as $f) {
    $content = file_get_contents($f);
    if (preg_match_all('/category=[A-Z_]+/', $content, $matches)) {
        $total_matches += count($matches[0]);
    }
}

printf("Tree walk complete: files=%d, matches=%d\n", count($files), $total_matches);
