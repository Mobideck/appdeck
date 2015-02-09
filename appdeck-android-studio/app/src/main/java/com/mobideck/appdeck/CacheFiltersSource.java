package com.mobideck.appdeck;

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.http.HttpRequest;

import org.littleshoot.proxy.HttpFilters;
import org.littleshoot.proxy.HttpFiltersSource;

public class CacheFiltersSource implements HttpFiltersSource
{
	
    public HttpFilters filterRequest(HttpRequest originalRequest) {
        return new CacheFilters(originalRequest, null);
    }
    
    @Override
    public HttpFilters filterRequest(HttpRequest originalRequest,
            ChannelHandlerContext ctx) {
        return filterRequest(originalRequest);
    }

    @Override
    public int getMaximumRequestBufferSizeInBytes() {
    	return 0;//Integer.MAX_VALUE;
    }

    @Override
    public int getMaximumResponseBufferSizeInBytes() {
    	return 0;//Integer.MAX_VALUE;
    }
}
