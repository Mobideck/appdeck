#!/usr/bin/php
<?php

define('EMBED_TYPE', 'android');
define('FORCE_DOWNLOAD', false);
define('APPDECK_APPDATA_URL', 'http://appdata.static.appdeck.mobi/res/android/');
define('EMBED_SUFFIX', '.png');

require('embedresources.lib.php');

if (!isset($argv[1]))
  appdeck_error("Usage: {$argv[0]} <project path>");

$project_path = $argv[1];

$app_manifest = openxml($project_path.'/AndroidManifest.xml');

$app_json_url = $app_manifest->xpath("//meta-data[@android:name='AppDeckJSONURL']/@android:value");
/*
$app_package = $app_manifest->xpath("//manifest/@package");
$app_package = $app_package[0];

var_dump(shell_exec("/Applications/Android/sdk/platform-tools/adb shell \"pm uninstall {$app_package}\""));
var_dump(shell_exec("/Applications/Android/sdk/platform-tools/adb shell \"rm -rf /data/app/{$app_package}-*\""));
*/
if ($app_json_url == false)
  appdeck_error('missing AppDeckJSONURL entry in AndroidManifest.xml (add <meta-data android:name="AppDeckJSONURL" android:value="..."></meta-data> in root of your AndroidManifest.xml file)', $app_plist_path);

$app_json_url = (string)$app_json_url[0]['value'];

define('APPDECK_JSON_URL', $app_json_url);
define('APPDECK_OUTPUT_DIR', $project_path.'/assets/httpcache/');

include('embedresources.php');