#!/bin/php
<?php

//-----------------------------------------------------------------------------

$db = new SQLite3('sokoban.db');

$db->exec("CREATE TABLE IF NOT EXISTS author(id INTEGER PRIMARY KEY ASC, name TEXT)");
$db->exec("CREATE TABLE IF NOT EXISTS levels_set(id INTEGER PRIMARY KEY ASC, author_id INTEGER, name TEXT)");

//-----------------------------------------------------------------------------

$stm1 = $db->prepare("INSERT or REPLACE INTO author(id, name) VALUES (?, ?)");
$stm1->bindParam(1, $id);
$stm1->bindParam(2, $name);

$stm2 = $db->prepare("INSERT or REPLACE INTO levels_set(id, author_id, name) VALUES (?, ?, ?)");
$stm2->bindParam(1, $id);
$stm2->bindParam(2, $author_id);
$stm2->bindParam(3, $name);

//-----------------------------------------------------------------------------

$dom = new DomDocument;
$dom->loadHTMLFile("levels/list.txt");

$optgroups = $dom->getElementsByTagName('optgroup');

//-----------------------------------------------------------------------------

$sN = 1;
foreach ($optgroups as $group) {
  $id   = $sN;
  $name = $group->attributes[0]->nodeValue;
  $stm1->execute();

  $opts = $group->getElementsByTagName('option');
  foreach ($opts as $option) {
    $id        = $option->attributes[0]->nodeValue;
    $author_id = $sN;
    $name      = explode('|', $option->nodeValue)[0];
    $stm2->execute();
  }

  $sN++;
}

//-----------------------------------------------------------------------------

$db->exec("CREATE TABLE IF NOT EXISTS levels(id INTEGER PRIMARY KEY ASC, levels_set_id INTEGER NOT NULl, ordinal_number INTEGER NOT NULL, x INTEGER, y INTEGER, content TEXT)");

$stm = $db->prepare("INSERT or REPLACE INTO levels(id, levels_set_id, ordinal_number, x, y, content) VALUES (?, ?, ?, ?, ?, ?)");
$stm->bindParam(1, $id);
$stm->bindParam(2, $levels_set_id);
$stm->bindParam(3, $ordinal_number);
$stm->bindParam(4, $x);
$stm->bindParam(5, $y);
$stm->bindParam(6, $content);

//-----------------------------------------------------------------------------

$lId = 1;
for ($i = 1; $i <= 132; $i++) {
    $file = fopen("levels/$i.txt", 'r');

    $lN = 1;
    while(!feof($file)) {
      $id             = $lId;
      $levels_set_id  = $i;
      $ordinal_number = $lN;
      $x              = fgets($file);
      $y              = fgets($file);
      $content        = fgets($file);
      if ($x != '') {
        $stm->execute();
        $lId++;
      }

      $lN++;
    }

    fclose($file);
}

//-----------------------------------------------------------------------------

