#!/usr/bin/php
<?php

//-----------------------------------------------------------------------------

error_reporting(0);

//-----------------------------------------------------------------------------
// compressor.php -n fly -l 130
//-----------------------------------------------------------------------------

define("S_WAL", 0b11100000); // $e0 '#' wall
define("S_GRA", 0b11000000); // $c0 'x' gras
define("S_PLA", 0b10100000); // $a0 '@' player
define("S_PLD", 0b10000000); // $80 '+' player on deck
define("S_DEC", 0b01100000); // $60 '.' deck
define("S_CRA", 0b01000000); // $40 '$' crate
define("S_CRD", 0b00100000); // $20 '*' crate on deck
define("S_FLO", 0b00000000); // $00 ' ' floor

//-----------------------------------------------------------------------------

$options = getopt("n:l:h:");

if (empty($options['n'])) {
  exit("give me name\n");
} else {
  $name = $options['n'];
}

if (empty($options['l'])) {
  exit("give me loID\n");
} else {
  $loID = $options['l'];
}

if (empty($options['h'])) {
  $hiID = $loID;
} else {
  $hiID = $options['h'];
}


//-----------------------------------------------------------------------------

$fp = fopen("/dev/shm/$name.bin", 'wb');
$db = new SQLite3('../lvs/sokoban.db');

//-----------------------------------------------------------------------------

$results = $db->query("SELECT DISTINCT content,x,y from levels WHERE (levels_set_id BETWEEN $loID AND $hiID) and x<=20 and y<=14");

//-----------------------------------------------------------------------------

$counter = 0;
while ($row = $results->fetchArray()) {
  $packed = '' . chr($row['x']) . chr($row['y']);

  $content = str_replace('!', '', $row['content']);

  $i = 0; $b = 0; $length = strlen($content) - 1;
  do {
    $q = 0; $c = $content[$i];

    do { $q++; $i++; $t = $content[$i]; } while ($t == $c);

    $z = 0;
    switch ($c) {
        case '#': $z = S_WAL | $q; break;
        case 'x': $z = S_GRA | $q; break;
        case '@': $z = S_PLA | $q; break;
        case '+': $z = S_PLD | $q; break;
        case '.': $z = S_DEC | $q; break;
        case '$': $z = S_CRA | $q; break;
        case '*': $z = S_CRD | $q; break;
        case ' ': $z = S_FLO | $q; break;
    }

    if ($z != 0) { $packed .= chr($z); $b++; }

  } while ($i < $length);

  $packed = chr(strlen($packed) + 1) . $packed;

  fwrite($fp, $packed);

  $counter++;
}

//-----------------------------------------------------------------------------

fclose($fp);

//-----------------------------------------------------------------------------

exec("apultra /dev/shm/$name.bin /dev/shm/$name.apl");

//-----------------------------------------------------------------------------

$set_size = exec("stat --printf='%s' /dev/shm/$name.bin");

$apl_size = exec("stat --printf='%s' /dev/shm/$name.apl");

echo "$set_size\t$name.bin\t$counter levels was packed\t$apl_size\t$name.apl", PHP_EOL;

//-----------------------------------------------------------------------------
