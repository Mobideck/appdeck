#!/usr/bin/php
<?php

define('EMBED_TYPE', 'ios7');
define('FORCE_DOWNLOAD', false);
define('APPDECK_APPDATA_URL', 'http://appdata.static.appdeck.mobi/res/iphone/');

require('embedresources.lib.php');

// Init dir
$output_dir = env('CONFIGURATION_BUILD_DIR').'/'.env('UNLOCALIZED_RESOURCES_FOLDER_PATH').'/embedresource/';

// AppDeck - Embed resources script

$app_plist_path = env('SRCROOT').'/'.env('INFOPLIST_FILE');
$app_plist = openxml($app_plist_path);

$app_api_key = plistget($app_plist, 'AppDeckApiKey');
if ($app_api_key != false)
  $app_api_key = preg_replace('/#.*/', '', $app_api_key);
$app_json_url = plistget($app_plist, 'AppDeckJSONURL');
if ($app_api_key == false && $app_json_url == false)
  appdeck_error("missing AppDeckApiKey entry", $app_plist_path);
if ($app_json_url == false)
  $app_json_url = 'http://config.appdeck.mobi/json/'.$app_api_key;

define('APPDECK_API_KEY', $app_json_url);
define('APPDECK_JSON_URL', $app_json_url);
define('APPDECK_OUTPUT_DIR', $output_dir);

require('embedresources.php');