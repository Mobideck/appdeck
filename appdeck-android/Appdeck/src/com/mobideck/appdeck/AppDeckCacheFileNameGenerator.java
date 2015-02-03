package com.mobideck.appdeck;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import com.nostra13.universalimageloader.cache.disc.naming.FileNameGenerator;

public class AppDeckCacheFileNameGenerator implements FileNameGenerator {
	@Override
	public String generate(String imageUri) {
		String asset_path =  imageUri.replace("http://", "");	
		String path = null;
		try {
			path = URLEncoder.encode(asset_path, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return path;
		//return String.valueOf(imageUri.hashCode());
	}
}
