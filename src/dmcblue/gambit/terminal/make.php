<?php

$haxe = file_get_contents(__DIR__ . DIRECTORY_SEPARATOR . "DisplayTemplate.hx");
$cpp = file_get_contents(__DIR__ . DIRECTORY_SEPARATOR . "Display.cpp");
$cpp = str_replace('"', '\"', $cpp);
$haxe = str_replace("%CPP%", $cpp, $haxe);
file_put_contents(__DIR__ . DIRECTORY_SEPARATOR . "Display.hx", $haxe);
