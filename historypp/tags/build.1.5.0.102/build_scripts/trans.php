<?php

/*
 * Description expected...
 *
 */


$detailed_file = false;
$ignore_menuitems = true;


// empty captions and captions consiting from
// whitespace, -, /, <, >, _ are skipped
$skip_empty_captions = '/^[\s\-\<\>\/\_]*$/';

if (count($argv) < 2) {
  print "Wrong params\r\n";
  exit;
}

$file_to_parse = $argv[1];
//$file_to_parse = '..\plugin\HistoryForm.pas';

if (preg_match('/(.*)\.dfm$/',$file_to_parse,$matches)) {
  $file_to_parse = $matches[1];
  }
if (preg_match('/(.*)\.pas$/',$file_to_parse,$matches)) {
  $file_to_parse = $matches[1];
  }

function file_put($filename, $text) {
  $f = fopen($filename,'w',false);
  fwrite($f,$text);
  fclose($f);
}

if (file_exists("$file_to_parse.trans.txt")) { unlink("$file_to_parse.trans.txt"); }
if (file_exists("$file_to_parse.trans-err.txt")) { unlink("$file_to_parse.trans-err.txt"); }
if (file_exists("$file_to_parse.trans-details.txt")) { unlink("$file_to_parse.trans-details.txt"); }

/*$files = array();
$d = dir('..\plugin');
while(false !== ($entry = $d->read())) {
	if (is_dir($entry)) continue;
	$pattern='/.*\.dfm$/';
	if (preg_match($pattern,$entry))
		$files[] = $entry;
}*/

$lines = file($file_to_parse.'.dfm');
$lineid = 0;
$no_add = false;
$dfm_str = array();
$dfm_prop = array();
$dfm_noadd = array();

function parse_object() {
  global $ignore_menuitems,$lines, $lineid, $dfm_str, $dfm_prop, $dfm_noadd, $no_add;
  $in_strings = false;
  $in_str_count = 0;
  $in_str_name = '';
  $cur_object = '';

  if (preg_match('/object (.*):/',$lines[$lineid],$matches)) {
    // first object is empty
    if ($lineid !== 0) {
      $cur_object = $matches[1]."."; }
    $lineid = $lineid + 1;
  }

  while(false == (preg_match('/\s*end$/',rtrim($lines[$lineid])))) {
    $lines[$lineid] = rtrim($lines[$lineid]);
    if (preg_match('/^(\s)*object (.*): (.*)$/',$lines[$lineid],$matches)) {
      if ($ignore_menuitems && (($matches[3] == "TMenuItem")||($matches[3] == "TTntMenuItem"))) {
        $no_add = true;
        parse_object();
        $no_add = false;
      } else { parse_object(); }
    }

    // parse values

    // we are in .Strings = ( ... ) area
    if ($in_strings) {
      if (preg_match('/^\s*\'(.*)\'\)?$/',$lines[$lineid],$matches)) {
        $dfm_prop[] = $cur_object.$in_str_name.'['.$in_str_count.']';
        $dfm_str[] = $matches[1];
        $dfm_noadd[] = $no_add;
        $in_str_count += 1;
        $in_strings = !(preg_match('/\)$/',$lines[$lineid]));
      } else  { $in_strings = false; }
    } else
    // value = '...' types
    if (preg_match('/^\s+([\d\w\.]*) = \'(.*)\'$/',$lines[$lineid],$matches)) {
      if (($matches[1] !== 'Name')&&(!preg_match('/\.Name$/',$matches[1]))) {
        $dfm_noadd[] = $no_add;
        $dfm_prop[] = $cur_object.$matches[1];
        $dfm_str[] = $matches[2];
      }
    } else
    // .Strings = ( ... ) area start
    if (preg_match('/^\s+([\d\w\.]+)\.Strings = \($/',$lines[$lineid],$matches)) {
      $in_str_count = 0;
      $in_strings = true;
      $in_str_name = $matches[1];
    }

    if ($lineid >= (count($lines)-1)) { break; }
    $lineid = $lineid + 1;
  }
}

// parse form file
parse_object();

// parse .pas :

$lines = file($file_to_parse.'.pas');

$pas_str = array();
$pas_prop = array();
$pas_str_line = array();
$pas_prop_line = array();
$pas_var = array();
$pas_var_line = array();
$pas_var_str = array();

function add_str($str,$line){
  global $pas_str,$pas_str_line;
  $pas_str[] = $str;
  $pas_str_line[] = $line;
}

function add_var($name,$str,$line){
  global $pas_var,$pas_var_str,$pas_var_line;
  $pas_var[] = $name;
  $pas_var_str[] = $str;
  $pas_var_line[] = $line;
}

function add_prop($prop,$line){
  global $pas_prop,$pas_prop_line;
  if (preg_match('/^P(Ansi|Wide)?Char\((.*)\)$/i',$prop,$matches)) {
    $prop = $matches[2]; }
  $pas_prop[] = $prop;
  $pas_prop_line[] = $line;
}

foreach($lines as $i => $line) {
  $line = rtrim($line);
  $cur_match = '';
  // here we capture Translate('...') text
  // it's buggy, because we can capture:
  // "...'),Translate('..."
  // from such string:
  // "Translate('...'),Translate('...')"
  if (preg_match_all('/Translate(W|WideW|AnsiW)?\(\'(.*)\'\)/i',$line,$matches)) {
    foreach($matches[2] as $match) { add_str($match,$i); }
  } else
  // capture Translate(var)
  if (preg_match_all('/Translate(W|WideW|AnsiW)?\((.*)\)/i',$line,$matches)) {
    foreach($matches[2] as $match) { add_prop($match,$i); }
  }
  $pattern = "/([\w\d]+)\s*\:\s*[\w\d]+\s*\=\s*\'(.*)\';$/is";
  if (preg_match($pattern,$line,$matches)) {
    add_var($matches[1],$matches[2],$line);
  }

}

// delete properties which are actually vars

foreach($pas_var as $i => $var){
  $found = false;
  $var = strtolower($var);
  foreach($pas_prop as $n => $prop) {
    $prop = strtolower($prop);
    if ($var == $prop) {
      unset($pas_prop[$n]);
      unset($pas_prop_line[$n]);
      $found = true;
      break;
    }
  }
  if (!$found) {
    unset($pas_var[$i]);
    unset($pas_var_str[$i]);
    unset($pas_var_line[$i]);
  }
}

// write strings to file

$strings = array();
$strings_d = array();

$filename = $file_to_parse.'.trans.txt';
$filename_d = $file_to_parse.'.trans-details.txt';

if (count($dfm_str) > 0) {
  $strings[] = ";; Text found in $file_to_parse.dfm:";
  $strings_d[] = ";; Text found in $file_to_parse.dfm:";
  foreach($dfm_str as $i => $str){
    if (!preg_match($skip_empty_captions,$str)) {
        $strings[] = $str;
        $strings_d[] = "$str ($dfm_prop[$i])";
    }
  }
}

if (count($pas_str) > 0) {
  $strings[] = ";; Text found in $file_to_parse.pas:";
  $strings_d[] = ";; Text found in $file_to_parse.pas:";
  foreach($pas_str as $i => $str){
    $strings[] = $str;
    $strings_d[] = "$str (line # $pas_str_line[$i])";
  }
}

if (count($pas_var_str) > 0) {
  $strings[] = ";; Text from variables in $file_to_parse.pas:";
  $strings_d[] = ";; Text from variables in $file_to_parse.pas:";
  foreach($pas_var_str as $i => $str){
    $strings[] = $str;
    $strings_d[] = "$str (line # $pas_var_line[$i])";
  }
}

if (count($strings) > 0) {
  file_put($filename, join("\r\n", $strings));
}

if ($detailed_file && (count($strings) > 0)) {
  file_put($filename_d, join("\r\n", $strings_d));
}

// search for pas properties not found in dfm

$not_found_in_dfm = array();

foreach($pas_prop as $i => $prop) {
  $found = false;
  if (preg_match('/\{TRANSLATE-IGNORE\}$/i',$prop)) { continue; }

  foreach($dfm_prop as $n => $value) {
    if (strcasecmp($prop,$value) == 0) {
      unset($dfm_prop[$n]);
      unset($dfm_noadd[$n]);
      unset($dfm_str[$n]);
      //print "Found $prop in dfm, deleted\r\n";
      $found = true;
      break;
    }
    if (preg_match('/^([\d\.\w]+)\[([\d\.\w]+)\]$/',$prop,$matches)) {
      $pref = $matches[1];
      if (preg_match('/^'.$pref.'\[(\d+)\]/',$dfm_prop[$n])) {
        unset($dfm_prop[$n]);
        unset($dfm_noadd[$n]);
        unset($dfm_str[$n]);
        //print "Found $prop in dfm as array, deleted\r\n";
        $found = true;
        continue;
      }
    }
    if ($found) { break; }
  }

  if (!$found) { $not_found_in_dfm[] = $prop; }
}

// search for error-looking strings grabbed from pas

$other_errors = array();

foreach($pas_str as $i => $str) {
  if (preg_match('/\'{1}/',$str)) {
    $other_errors[] = "* This string from $file_to_parse.pas($pas_str_line[$i]) looks suspicius:";
    $other_errors[] = "* (generally, it's a good rule not to put anything on the line after translate function call)";
    $other_errors[] = "$str\r\n";
  }
}

// search for dfm properties not represented in pas

$not_found_in_pas = array();

foreach($dfm_prop as $i => $prop) {
  $found = false;

  if ($dfm_noadd[$i]) { continue; }
  if (preg_match($skip_empty_captions,$dfm_str[$i])) { continue; }

  foreach($pas_prop as $n => $value) {
    if (strcasecmp($prop,$value) == 0) {
      unset($pas_prop[$n]);
      unset($pas_prop_line[$n]);
      $found = true;
      break;
    }
    if ($found) { break; }
  }

  if (!$found) { $not_found_in_pas[] = $prop; }
}

if ((count($other_errors)+count($not_found_in_pas)+count($not_found_in_dfm))>0) {
  $strings = array();
  $filename = $file_to_parse.'.trans-err.txt';

  $strings[] = "We have errors!";
  if (count($not_found_in_pas) > 0) {
    $strings[] = "\r\n************ NOT TRANSLATED ***************";
    $strings[] = "Form properties not translated in .pas file";
    $strings[] = "See translate_guide.txt for what it can mean and how to fix it";
    $strings[] = "********************************************\r\n";
  }
  foreach($not_found_in_pas as $prop){ $strings[] = $prop;}
  if (count($not_found_in_dfm) > 0) {
    $strings[] = "\r\n************ NOT FOUND IN DFM **************";
    $strings[] = "Some properites in the code were not found in DFM,";
    $strings[] = "so they were not added to the strings list";
    $strings[] = "See translate_guide.txt for for how to make me find them";
    $strings[] = "********************************************\r\n";
  }
  foreach($not_found_in_dfm as $prop){ $strings[] = $prop;}

  if (count($other_errors) > 0) {
    $strings[] = "\r\n********************************************";
    $strings[] = "Other errors. Explanation see below.";
    $strings[] = "********************************************\r\n";
  }
  foreach($other_errors as $err){ $strings[] = $err;}

  if (count($strings) > 0) {
    file_put($filename, join("\r\n", $strings));
  }
}

?>