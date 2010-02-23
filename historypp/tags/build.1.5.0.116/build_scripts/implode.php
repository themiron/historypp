<?php

/*
 * Description expected...
 *
 */

ini_set("register_globals","1");
ini_set("register_argc_argv","1");

$path = realpath(dirname($argv[1]));
$mask = basename($argv[1]);
$files = array();

$mask = str_replace(".","\.",$mask);
$mask = str_replace("?","[^\.]",$mask);
$mask = str_replace("*",".*?",$mask);
$mask = "/($mask)/is";

$d = dir($path);
while (false !== ($entry = $d->read())) {
	if (preg_match($mask,$entry,$match)) {
		$files[] = $match[1];
	}
}
$d->close();

sort($files);

foreach ($files as $entry) {
	echo "\r\n";
	echo "\r\n";
	echo ";; $entry file\r\n";
	echo "\r\n";
	$fp = fopen($path."\\".$entry,"r");
	fpassthru($fp);
	fclose($fp);
}

?>