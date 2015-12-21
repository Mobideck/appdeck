<?php

function openxml($filepath, &$error_str = false)
{
  $xmlstr = @file_get_contents($filepath);
  if ($xmlstr == false)
  {
    $error_str = "failed to open file {$filepath}";
    return false;
  }
  $options = LIBXML_NOERROR | LIBXML_NOWARNING | LIBXML_ERR_NONE | LIBXML_COMPACT;
  $xmldoc = new DOMDocument();
  $xmldoc->strictErrorChecking = false;
  $xmldoc->recover = true;
  $old = error_reporting(0);
  $old_libxml = libxml_use_internal_errors(true);
  $ret = @$xmldoc->loadXml($xmlstr, $options);
  if ($ret == false)
  {
    $error_str = "failed to load xml from {$filepath}";
    return false;
  }
  $errors = libxml_get_errors();
  if (count($errors) > 0)
      foreach ($errors as $error)
          if ($error->level == LIBXML_ERR_FATAL)
          {
              $error_str = "file: {{$filepath}} line: {$error->line} column: {$error->column}: fatal error: {$error->code}: {$error->message}";
              return false;
          }

  $xml = @simplexml_import_dom($xmldoc);
  error_reporting($old);
  libxml_use_internal_errors($old_libxml);
  return $xml;
}

function env($name)
{
  if (isset($_ENV[$name]))
    return $_ENV[$name];
  if (isset($_SERVER[$name]))
    return $_SERVER[$name];
  $backtrace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS);
  appdeck_error("missing {$name} env var from xcode", $backtrace[0]['file'], $backtrace[0]['line']);
  exit(1);
}

function ezcurl($url, &$error = null)
{
    static $ch = false;

    if ($ch == false)
    $ch = curl_init();
    // download data
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_HEADER, 1);
    curl_setopt($ch, CURLOPT_USERAGENT, 'AppDeck');
    //curl_setopt($ch, CURLOPT_PROXY, '127.0.0.1:3128');
    curl_setopt($ch, CURLOPT_ENCODING, 'identity');
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    $data = curl_exec($ch);
    $headers = array();
    if ($error_id = curl_errno($ch))
    {
        $error = curl_error($ch);
        return array(false, false);
    }
    // extract header and body
    while (1)
      {
        $pos = strpos($data, "\r\n\r\n");
        $headers = substr($data, 0, $pos);
        $headers = explode("\r\n", $headers);
        $cmd = array_shift($headers);
        $body = substr($data, $pos + 4  );
        if ($cmd != 'HTTP/1.1 100 Continue')
          break;
        $data = $body;
      }
      // explode headers
      $h = array();
      foreach ($headers as $header)
        {
          $pos = strpos($header, ': ');
          if ($pos === false)
            continue;
          $header_name = substr($header, 0, $pos);
          $header_value = substr($header, $pos + 2);
           // if header already exist, we create array
           if (isset($h[$header_name]))
           {
              if (!is_array($h[$header_name]))
                $h[$header_name] = array($h[$header_name]);
             $h[$header_name] []= $header_value;
           } else {
             $h[$header_name] = $header_value;
           }
        }
    return array($h, $body);
}

/*! JSON.minify()
  v0.1 (c) Kyle Simpson
  MIT License
  https://raw.github.com/getify/JSON.minify/master/minify.json.php
*/
function json_minify($json) {
  $tokenizer = "/\"|(\/\*)|(\*\/)|(\/\/)|\n|\r/";
  $tokenizer = "/\"|(\/\*)|(\*\/)|(\/\/)|\n|\r/";
  $in_string = false;
  $in_multiline_comment = false;
  $in_singleline_comment = false;
  $tmp; $tmp2; $new_str = array(); $ns = 0; $from = 0; $lc; $rc; $lastIndex = 0;
  $rc = '';
  while (preg_match($tokenizer,$json,$tmp,PREG_OFFSET_CAPTURE,$lastIndex)) {
    $tmp = $tmp[0];
    $lastIndex = $tmp[1] + strlen($tmp[0]);
    $lc = substr($json,0,$lastIndex - strlen($tmp[0]));
    $rc = substr($json,$lastIndex);
    if (!$in_multiline_comment && !$in_singleline_comment) {
      $tmp2 = substr($lc,$from);
      if (!$in_string) {
        $tmp2 = preg_replace("/(\n|\r|\s)*/","",$tmp2);
      }
      $new_str[] = $tmp2;
    }
    $from = $lastIndex;

    if ($tmp[0] == "\"" && !$in_multiline_comment && !$in_singleline_comment) {
      preg_match("/(\\\\)*$/",$lc,$tmp2);
      if (!$in_string || !$tmp2 || (strlen($tmp2[0]) % 2) == 0) { // start of string with ", or unescaped " character found to end string
        $in_string = !$in_string;
      }
      $from--; // include " character in next catch
      $rc = substr($json,$from);
    }
    else if ($tmp[0] == "/*" && !$in_string && !$in_multiline_comment && !$in_singleline_comment) {
      $in_multiline_comment = true;
    }
    else if ($tmp[0] == "*/" && !$in_string && $in_multiline_comment && !$in_singleline_comment) {
      $in_multiline_comment = false;
    }
    else if ($tmp[0] == "//" && !$in_string && !$in_multiline_comment && !$in_singleline_comment) {
      $in_singleline_comment = true;
    }
    else if (($tmp[0] == "\n" || $tmp[0] == "\r") && !$in_string && !$in_multiline_comment && $in_singleline_comment) {
      $in_singleline_comment = false;
    }
    else if (!$in_multiline_comment && !$in_singleline_comment && !(preg_match("/\n|\r|\s/",$tmp[0]))) {
      $new_str[] = $tmp[0];
    }
  }
  $new_str[] = $rc;
  return implode("",$new_str);
}

function strip_c_comment($src)
{
  $replace = array(
    "#/\*.*?\*/#s" => "\n",  // Strip C style comments.
    "#\s\s+#"      => " ", // Strip excess whitespace.
  );
  $search = array_keys($replace);
  $src = preg_replace("#/\*.*?\*/#s", "\n", $src); // Strip /* comment */
  $src = preg_replace("#\s\s+#", "\n", $src); // Strip # comment
  $src = preg_replace("_^\s*((^\s*(#+|//+)\s*.+?$\n)+)_ms", "\n", $src); // Strip // comment 
  return $src;
}

function plistget($plist, $name)
{
  $last_name = -1;
  foreach ($plist as $child)
  {
    if ($child->getName() == 'key')
    {
      $last_name = (string)$child;
    }
    else if ($last_name == $name)
      return $child;
    else
    {
      $ret = plistget($child, $name);
      if ($ret !== false)
        return $ret;
    }
  }
  return false;
}

function appdeck_warning($msg, $file = false, $line = '')
{
  if ($file != false && realpath($file))
    $file = realpath($file);
  if ($file == false)
    print "warning: {$msg}\n";
  else
    print "{$file}:{$line}:{$column}: warning: {$msg}";
}

function appdeck_error($msg, $file = false, $line = '', $column = '')
{
  if ($file != false && realpath($file))
    $file = realpath($file);
  if ($file == false)
    print "error: {$msg}\n";
  else
    print "{$file}:{$line}:{$column}: error: {$msg}";
  exit(1);
}

function appdeck_ok($msg)
{
  print "Ok: {$msg}";
  exit(0);
}

function get_absolute_path($path)
 {
        $path = str_replace(array('/', '\\'), DIRECTORY_SEPARATOR, $path);
        $parts = array_filter(explode(DIRECTORY_SEPARATOR, $path), 'strlen');
        $absolutes = array();
        foreach ($parts as $part) {
            if ('.' == $part) continue;
            if ('..' == $part) {
                array_pop($absolutes);
            } else {
                $absolutes[] = $part;
            }
        }
        return implode(DIRECTORY_SEPARATOR, $absolutes);
    }

function resolve_url($url_str, $source_url_str)
{
    if (strpos($url_str, 'http://') === 0) // nothing to do
      return $url_str;
    if (strpos($url_str, 'https://') === 0) // nothing to do
      return $url_str;

    $source_url = parse_url($source_url_str);
    $url = parse_url($url_str);

    $final_url = "{$source_url['scheme']}://";
    if (isset($source_url['user']) || isset($source_url['pass']))
        $final_url .= "{$source_url['user']}:{$source_url['pass']}@";
    $final_url .= $source_url['host'];
    if (isset($source_url['port']))
        $final_url .= ":{$source_url['port']}";

    if (strpos($url_str, '/') === 0) // absolute url, just add host/user/port
      return $final_url.$url_str;

    if (strrpos($source_url['path'], '/') === strlen($source_url['path']) - 1)
      $final_url .= '/'.get_absolute_path($source_url['path'] . $url['path']);
    else
      $final_url .= '/'.get_absolute_path(dirname($source_url['path']) .'/'. $url['path']);

    if (isset($url['query']))
        $final_url .= "?{$url['query']}";

    if (isset($url['fragment']))
        $final_url .= "#{$url['fragment']}";

    return $final_url;
}

$count_resource = 0;
function appdeck_add_ressource($url, $data = false, $force = false, $headers = false)
{
  global $output_dir_path, $count_resource, $base_url;

  if (defined('FORCE_DOWNLOAD') && FORCE_DOWNLOAD === true)
    $force = true;
  $url = resolve_url($url, $base_url);
  print " - - add resource for {$url}\n";
  $file_name = urlencode(str_replace('http://', '', $url));
  //print " - - ORIGINAL FileName: {$file_name}\n";    
  if (strlen($file_name) > 48)
  {
    $file_name = substr($file_name, 0, 48).'_'.md5($file_name);
    //print " - - MD5 PATCH FileName: {$file_name}\n";  
  }
  print " - - FileName: {$file_name}\n";  
  $file_name_meta = EMBED_PREFIX.$file_name.'.meta'.EMBED_SUFFIX;
  $file_name = EMBED_PREFIX.$file_name.EMBED_SUFFIX;
  //$tmp_file_path = $tmp_dir_path."/".$file_name;
  $output_file_path = $output_dir_path."/".$file_name;
  $output_file_path_meta = $output_dir_path."/".$file_name_meta;
  if (!file_exists($output_file_path) || $force == true)
    {
      if ($data === false)
    	{
    	  print " - - download {$url} into {$output_file_path}\n";
        list($headers, $data) = ezcurl($url, $error);
    	  if ($data == false)
    	    {
    	      appdeck_warning("failed to download: {$url}: {$error}");
    	      return;
    	    }
    	}
      else
    	  print " - - add resource for {$url} from data into {$output_file_path}\n";
      $res = file_put_contents($output_file_path, $data);
      if ($res == false)
        appdeck_warning("failed to write resource {$url} in {$output_file_path}");
      // clean headers
      unset($headers['Set-Cookie']);
      unset($headers['set-cookie']);
      $res = file_put_contents($output_file_path_meta, json_encode($headers));
      if ($res == false)
        appdeck_warning("failed to write resource meta {$url} in {$output_file_path_meta}");
    }
  else
    print " - - resource {$url} already downloaded in {$output_file_path}\n";
  $count_resource++;
}

function embed_url($embed_url)
{
  print " - Embed URL: {$embed_url}\n";

  list($headers, $data) = ezcurl($embed_url, $error);

  if ($data == false)
    {
      appdeck_warning("failed to download: {$embed_url}: {$error}");
      return;
    }
  if (strpos($data, "<") !== false)
    {
      appdeck_warning("failed to parse: {$embed_url}: HTML code found, this should be a text file");
      return;
    }
  $data = strip_c_comment($data);
  // we embed embed_url in application
  appdeck_add_ressource($embed_url, $data, true, $headers);
  // we embed all url listed in this file
  $lines = explode("\n", $data);
  foreach ($lines as $line)
    if (trim($line) != "")
      appdeck_add_ressource(trim($line));
}

function easy_embed_rec($names, $base_info)
{
  global $base_url;

  $name = array_shift($names);
  $count = 0;
  foreach (array($name, $name.'_tablet', $name.'_phone', $name.'_tablet_ios', $name.'_phone_ios', $name.'_tablet_android', $name.'_phone_android', $name.'_ios', $name.'_android') as $field)
  {
    if (count($names) == 0)
    {
      if (isset($base_info->$field)) {
        $url = resolve_url($base_info->$field, $base_url);
        appdeck_add_ressource($url);
        $count++;
      }     
    }
    else
    {
      if (isset($base_info->$field)) {
        easy_embed_rec($names, $base_info->$field);
        $count++;
      }
    }
  }
  return $count;
}


function easy_embed($name, $default_url = false)
{
  global $info;

  $names = explode('.', $name);

  $count = easy_embed_rec($names, $info);
  if ($count == 0 && $default_url)
    appdeck_add_ressource($default_url);
}

function buildAppDeckAndroidRes()
{
  global $info, $project_path;

  $xml = file_get_contents($project_path.'/extra/appdeck.xml');
  if (isset($info->icon_theme) && $info->icon_theme == 'dark')
    $conf = array('AppDeckColorTopBarBg1' => '#000000',
                  'AppDeckColorTopBarBg2' => '#000000',
                  'AppDeckColorTopBarText' => '#FFFFFF',
                  'AppDeckColorTheme' => '#000000',
                  'AppDeckColorApp' => '#000000');
  else
    $conf = array('AppDeckColorTopBarBg1' => '#FFFFFF',
                  'AppDeckColorTopBarBg2' => '#FFFFFF',
                  'AppDeckColorTopBarText' => '#000000',
                  'AppDeckColorTheme' => '#FFFFFF',
                  'AppDeckColorApp' => '#000000');

  // patch conf
  if (isset($info->app_topbar_color[0]) && $info->app_topbar_color[0] != '') {
    $conf['AppDeckColorTopBarBg1'] = $info->app_topbar_color[0];
    $conf['AppDeckColorTopBarBg2'] = $info->app_topbar_color[0];
  }
  if (isset($info->app_topbar_color[1]) && $info->app_topbar_color[1] != '')
    $conf['AppDeckColorTopBarBg2'] = $info->app_topbar_color[1];
  if (isset($info->app_topbar_text_color) && $info->app_topbar_text_color != '')
    $conf['AppDeckColorTopBarText'] = $info->app_topbar_text_color;
  if (isset($info->app_color) && $info->app_color != '')
    $conf['AppDeckColorApp'] = $info->app_color;

  if (isset($info->icon_theme) && $info->icon_theme == 'light')
    $xml = str_replace('Theme.AppCompat.NoActionBar', 'Theme.AppCompat.Light.NoActionBar', $xml);
  if (isset($info->icon_theme) && $info->icon_theme == 'dark')
    $xml = str_replace('Theme.AppCompat.NoActionBar', 'Theme.AppCompat.NoActionBar', $xml);

  foreach ($conf as $k => $v)
  {
    $xml = str_replace('##'.$k.'##', $v, $xml);
  }
  $xml_path = $project_path.'/app/src/main/res/values/appdeck.xml';
  if (!file_exists($xml_path) || file_get_contents($project_path.'/app/src/main/res/values/appdeck.xml') != $xml)
    file_put_contents($project_path.'/app/src/main/res/values/appdeck.xml', $xml);
}
