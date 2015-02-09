<?php

print "Start AppDeck Embed Resource Script\n";

if (!defined('EMBED_SUFFIX'))
  define('EMBED_SUFFIX', '');
if (!defined('EMBED_PREFIX'))
  define('EMBED_PREFIX', '');

// read params
$output_dir = APPDECK_OUTPUT_DIR;
$app_json_url = APPDECK_JSON_URL;

print " - App.json URL: {$app_json_url}\n";
print " - Embed Path: {$output_dir}\n";

// Init output dir
if (!file_exists($output_dir))
  mkdir($output_dir, 0777, true);
$output_dir_path = realpath($output_dir);
if ($output_dir_path == false)
  appdeck_error("failed to create embedresource directory {$output_dir}", __FILE__, __LINE__);

// set beacon if needed
// this beacon is used to clear cache on startup after a clean build
$beacon_output_file_path = $output_dir_path."/beacon";
if (defined('FORCE_DOWNLOAD') && FORCE_DOWNLOAD === true && file_exists($beacon_output_file_path))
    unlink($beacon_output_file_path);
if (!file_exists($beacon_output_file_path))
  file_put_contents($beacon_output_file_path, mt_rand());

list($json_headers, $json_data) = ezcurl($app_json_url, $error);

if ($json_data == false)
  appdeck_error("failed to download: {$app_json_url}: {$error}", $app_plist_path);

$info = json_decode(json_minify($json_data));
if ($info == false)
  appdeck_error("{$app_json_url}: invalid json data: {$json_data}");

$base_url = (isset($info->base_url) ? $info->base_url : $app_json_url);

if (!isset($info->embed_url) && !isset($info->embed))
  appdeck_warning("no embed ressources defined in app.json");

// by default we always embed app.json
appdeck_add_ressource($app_json_url, $json_data, true);

// try to add files from embed url
if (isset($info->embed_url))
{
  $embed_url = resolve_url($info->embed_url, $base_url);
  embed_url($embed_url);
}
if (isset($info->embed_url_tablet))
{
  $embed_url = resolve_url($info->embed_url_tablet, $base_url);
  embed_url($embed_url);
}

// inline embed urls
if (isset($info->embed))
  foreach ($info->embed as $line)
    if (trim($line) != "")
      appdeck_add_ressource(trim($line));

// http://appdata.static.appdeck.mobi/res/ios/icons/action_dark.png
// http://appdata.static.appdeck.mobi/res/ios/icons/action.png
// http://appdata.static.appdeck.mobi/res/ios7/icons/action_dark.png
// http://appdata.static.appdeck.mobi/res/ios7/icons/action.png
// http://appdata.static.appdeck.mobi/res/android/icons/action_dark.png
// http://appdata.static.appdeck.mobi/res/android/icons/action.png

$icon_theme = '';
if (isset($info->icon_theme) && strtolower($info->icon_theme) == 'dark')
  $icon_theme = '_dark';

easy_embed("icon_action", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/action{$icon_theme}.png");
easy_embed("icon_cancel", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/cancel{$icon_theme}.png");
easy_embed("icon_close", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/close{$icon_theme}.png");
easy_embed("icon_config", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/config{$icon_theme}.png");
easy_embed("icon_info", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/info{$icon_theme}.png");
easy_embed("icon_menu", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/menu{$icon_theme}.png");
easy_embed("icon_next", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/next{$icon_theme}.png");
easy_embed("icon_previous", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/previous{$icon_theme}.png");
easy_embed("icon_ok", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/ok{$icon_theme}.png");
easy_embed("icon_up", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/up{$icon_theme}.png");
easy_embed("icon_down", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/down{$icon_theme}.png");
easy_embed("icon_refresh", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/refresh{$icon_theme}.png");
easy_embed("icon_search", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/search{$icon_theme}.png");
easy_embed("icon_user", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/icons/user{$icon_theme}.png");

easy_embed("image_loader", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/images/loader{$icon_theme}.png");
easy_embed("image_pull_arrow", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/images/pull_arrow{$icon_theme}.png");
easy_embed("image_network_error", "http://appdata.static.appdeck.mobi/res/".EMBED_TYPE."/images/network_error{$icon_theme}.png");

easy_embed("logo");

appdeck_add_ressource("http://appdata.static.appdeck.mobi/js/appdeck_1.10.js", false, true);
appdeck_add_ressource("http://appdata.static.appdeck.mobi/js/appdeck_dev.js", false, true);
appdeck_add_ressource("http://appdata.static.appdeck.mobi/js/appdeck.js", false, true);
appdeck_add_ressource("http://appdata.static.appdeck.mobi/js/fastclick.js", false, true);

appdeck_ok("{$count_resource} resources embed in app");
