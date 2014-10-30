#!/usr/bin/php
<?php

$path = dirname(__FILE__);

chdir($path);
run("rm -rf {$path}/tmp");
@mkdir('tmp');

$archs = array('armv7', 'armv7s', 'i386');

$files = glob('a/*.a');

$odirs = array();

$duplicate_symbols = array('NVASpeechkit.o' => array('_AUDIO_LEVEL_MIN' => '_AUDIO_LEVEL_MIX', '_AUDIO_LEVEL_MAX' => '_AUDIO_LEVEL_MXX'));

var_dump($files);

function run($cmd)
{
  print "-----\n$cmd\n-----\n";
  print shell_exec($cmd);
}

// extract all slices

foreach ($files as $file)
  {
    chdir($path);

    $file = realpath($file);    
    $out = str_replace('a/', 'tmp/', $file); 

    foreach ($archs as $arch)
      {
	$out_arch = str_replace('.a', "-{$arch}.a", $out);

	$cmd = "lipo -thin {$arch} {$file} -output {$out_arch}";
	run($cmd);

	$out_o_dir = str_replace('.a', '', $out_arch);
	@mkdir($out_o_dir);

	if (chdir($out_o_dir) == false)
	  die("failed to cd {$out_o_dir}");

	$cmd = "ar -x {$out_arch}";
	run($cmd);

	// deal with duplicate symbol
	foreach ($duplicate_symbols as $ofile => $symbols)
	  {
	    if (file_exists($out_o_dir.'/'.$ofile))
	      {
	      	$data = file_get_contents("{$out_o_dir}/{$ofile}");
		foreach ($symbols as $symbol => $new_symbol)
		  {
    $data = str_replace($symbol, $new_symbol, $data);

		  	/*
		    $cmd = "ld -r {$out_o_dir}/{$ofile} -o {$out_o_dir}/NEW_{$ofile} -alias '{$symbol}' '{$new_symbol}' -unexported_symbol '{$symbol}'";
		    run($cmd);
		    unlink("{$out_o_dir}/{$ofile}");
		    rename("{$out_o_dir}/NEW_{$ofile}", "{$out_o_dir}/{$ofile}");*/
		  }
		  file_put_contents("{$out_o_dir}/{$ofile}", $data);
	      }
	  }

	$odirs[$arch] []= $out_o_dir;
      }
  }

// extract all object
foreach ($archs as $arch)
  {
    $cmd = "libtool -static ";
    foreach ($odirs[$arch] as $odir)
      {
	$cmd .= " {$odir}/*.o ";
      }

    $cmd .= " -o {$path}/tmp/{$arch}.a";

    run($cmd);
  }

// join
$cmd = "lipo -create ";
foreach ($archs as $arch)
  $cmd .= " {$path}/tmp/{$arch}.a ";
$cmd .= " -o {$path}/libAdSDK.a";
run($cmd);

//run("rm -rf {$path}/tmp");