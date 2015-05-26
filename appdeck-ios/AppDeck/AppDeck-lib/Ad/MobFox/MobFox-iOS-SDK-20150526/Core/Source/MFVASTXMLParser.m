//
//  VASTXMLParser.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 11.02.2014.
//
//

#import "MFVASTXMLParser.h"


@implementation MFVASTXMLParser



+(NSMutableArray *)parseVAST:(MFDTXMLElement *)vastElement {
    
    
    NSArray *adElements = [vastElement getNamedChildren:@"Ad"];
    NSMutableArray *ads = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < adElements.count; i++) {
        MFDTXMLElement *element = [adElements objectAtIndex:i];
        VAST_Ad *ad = [self readAd:element];
        
        [ads addObject:ad];
    }
    if([ads count] < 1)
    {
        return nil;
    }
    
    return ads;
}


+(VAST_Ad *)readAd:(MFDTXMLElement *)element {
    VAST_Ad *ad = [[VAST_Ad alloc]init];
    NSMutableDictionary *attributes = element.attributes;
    ad.Id = [attributes objectForKey:@"id"];
    ad.sequence = [attributes objectForKey:@"sequence"];
    
    MFDTXMLElement *inLineElement = [element getNamedChild:@"InLine"];
    MFDTXMLElement *wrapperElement = [element getNamedChild:@"Wrapper"];
    
    if (inLineElement) {
        ad.InLine = [self readInline:inLineElement];
    }
    else if (wrapperElement)
    {
        ad.Wrapper = [self readWrapper:wrapperElement];
    }else{
        NSLog(@"Document is invalid!");
    }

    
    return ad;
}

+(VAST_InLine *)readInline:(MFDTXMLElement *)element {
    VAST_InLine *inLine = [[VAST_InLine alloc]init];
    MFDTXMLElement *adSystem = [element getNamedChild:@"AdSystem"];
    if(adSystem) {
        inLine.adSystem = [self readAdSystem:adSystem];
    }
    inLine.adTitle = [element getNamedChild:@"AdTitle"].text;
    inLine.impressions = [[NSMutableArray alloc]init];
    
    NSArray *impressionElements = [element getNamedChildren:@"Impression"];
    
    for (int i = 0; i < impressionElements.count; i++) {
        MFDTXMLElement *element = [impressionElements objectAtIndex:i];
        VAST_Impression *impression = [self readImpression:element];

        [inLine.impressions addObject:impression];
    }

    inLine.Description = [element getNamedChild:@"Description"].text;
    inLine.advertiser = [element getNamedChild:@"Advertiser"].text;
    inLine.error = [element getNamedChild:@"Error"].text;
    MFDTXMLElement *creatives = [element getNamedChild:@"Creatives"];
    if(creatives) {
        inLine.creatives = [self readCreatives:creatives];
    }
    
    return inLine;
}

+(VAST_AdSystem *)readAdSystem:(MFDTXMLElement *)element {
    VAST_AdSystem *adSystem = [[VAST_AdSystem alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    
    adSystem.version = [attributes objectForKey:@"version"];
    adSystem.name = element.text;
    
    return adSystem;
}

+(NSMutableArray *)readCreatives:(MFDTXMLElement *)element {
    NSMutableArray *creatives = [[NSMutableArray alloc]init];
    
    NSArray *creativeElements = [element getNamedChildren:@"Creative"];
    
    for (int i = 0; i < creativeElements.count; i++) {
        MFDTXMLElement *element = [creativeElements objectAtIndex:i];
        VAST_Creative *creative = [self readCreative:element];
        
        [creatives addObject:creative];
    }
    
    return creatives;
}

+(VAST_Creative *)readCreative:(MFDTXMLElement *)element {
    VAST_Creative *creative = [[VAST_Creative alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    
    creative.adId = [attributes objectForKey:@"adID"];
    creative.Id = [attributes objectForKey:@"id"];
    creative.apiFramework = [attributes objectForKey:@"apiFramwork"];
    creative.sequence = [[attributes objectForKey:@"sequence"] integerValue];
    
    MFDTXMLElement *linear = [element getNamedChild:@"Linear"];
    if(linear) {
        creative.linear = [self readLinear:linear];
    }
    
    MFDTXMLElement *nonLinearAds = [element getNamedChild:@"NonLinearAds"];
    if(nonLinearAds) {
        creative.nonLinearAds = [self readNonLinearAds:nonLinearAds];
    }
    
    MFDTXMLElement *companion = [element getNamedChild:@"CompanionAds"];
    if(companion) {
        creative.companionAds = [self readCompanionAds:companion];
    }
    
    return creative;
}

+(VAST_Impression*)readImpression:(MFDTXMLElement *)element {
    VAST_Impression *impression = [[VAST_Impression alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    impression.Id = [attributes objectForKey:@"id"];
    impression.url = element.text;
    
    return impression;
}

+(VAST_Linear *)readLinear:(MFDTXMLElement *)element {
    VAST_Linear *linear = [[VAST_Linear alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    
    linear.skipoffset = [attributes objectForKey:@"skipoffset"];
    linear.duration = [element getNamedChild:@"Duration"].text;

    MFDTXMLElement *mediaFiles = [element getNamedChild:@"MediaFiles"];
    if(mediaFiles) {
        linear.mediaFiles = [self readMediaFiles:mediaFiles];
    }
    MFDTXMLElement *videoClicks = [element getNamedChild:@"VideoClicks"];
    if(videoClicks) {
        linear.videoClicks = [self readVideoClicks:videoClicks];
    }
    MFDTXMLElement *trackingEvents = [element getNamedChild:@"TrackingEvents"];
    if(trackingEvents) {
        linear.trackingEvents = [self readTrackingEvents:trackingEvents];
    }

    return linear;
}

+(VAST_NonLinearAds *)readNonLinearAds:(MFDTXMLElement *)element {
    VAST_NonLinearAds *nonLinearAds = [[VAST_NonLinearAds alloc]init];
    
    NSArray *nonLinearElements = [element getNamedChildren:@"NonLinear"];
    NSMutableArray *nonLinears = [[NSMutableArray alloc]init];
    for (int i = 0; i < nonLinearElements.count; i++) {
        MFDTXMLElement *element = [nonLinearElements objectAtIndex:i];
        
        VAST_NonLinear *nonLinear = [self readNonLinear:element];
        [nonLinears addObject:nonLinear];
    }
    nonLinearAds.nonLinears = nonLinears;
 
    
    MFDTXMLElement *trackingEvents = [element getNamedChild:@"TrackingEvents"];
    if(trackingEvents) {
        nonLinearAds.trackingEvents = [self readTrackingEvents:trackingEvents];
    }
    
    return nonLinearAds;
}

+(VAST_NonLinear *)readNonLinear:(MFDTXMLElement *)element {
    VAST_NonLinear *nonLinear = [[VAST_NonLinear alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    
    nonLinear.Id = [attributes objectForKey:@"id"];
    nonLinear.scalable = [[attributes objectForKey:@"scalable"] boolValue];
    nonLinear.maintainAspectRatio = [[attributes objectForKey:@"maintainAspectRatio"] boolValue];
    nonLinear.apiFramework = [attributes objectForKey:@"apiFramework"];
    nonLinear.height = [[attributes objectForKey:@"height"] integerValue];
    nonLinear.width = [[attributes objectForKey:@"width"] integerValue];
    nonLinear.expandedHeight = [[attributes objectForKey:@"expandedHeight"] integerValue];
    nonLinear.expandedWidth = [[attributes objectForKey:@"expandedWidth"] integerValue];
    nonLinear.minSuggestedDuration = [attributes objectForKey:@"minSuggestedDuration"];
    
    MFDTXMLElement *staticResource = [element getNamedChild:@"StaticResource"];
    if(staticResource) {
        nonLinear.staticResource = [self readStaticResource:staticResource]; //
    }
    
    MFDTXMLElement *htmlResource = [element getNamedChild:@"HTMLResource"];
    if(htmlResource) {
        nonLinear.htmlResource = htmlResource.text;
    }
    
    MFDTXMLElement *iFrameResource = [element getNamedChild:@"IFrameResource"];
    if(iFrameResource) {
        nonLinear.iFrameResource = iFrameResource.text;
    }
    
    MFDTXMLElement *nonLinearClickThrough = [element getNamedChild:@"NonLinearClickThrough"];
    if(nonLinearClickThrough) {
        nonLinear.nonLinearClickThrough = nonLinearClickThrough.text;
    }
    
    MFDTXMLElement *nonLinearClickTracking = [element getNamedChild:@"NonLinearClickTracking"];
    if(nonLinearClickTracking) {
        nonLinear.nonLinearClickTracking = nonLinearClickTracking.text;
    }
    
    return nonLinear;
}

+(VAST_Wrapper *)readWrapper:(MFDTXMLElement *)element {
    VAST_Wrapper *wrapper = [[VAST_Wrapper alloc]init];
    
    MFDTXMLElement *adSystem = [element getNamedChild:@"AdSystem"];
    if(adSystem) {
        wrapper.adSystem = [self readAdSystem:adSystem];
    }
 
    NSArray *impressionElements = [element getNamedChildren:@"Impression"];
    for (int i = 0; i < impressionElements.count; i++) {
        MFDTXMLElement *element = [impressionElements objectAtIndex:i];
        VAST_Impression *impression = [self readImpression:element];
        
        [wrapper.impressions addObject:impression];
    }
    wrapper.VASTAdTagUri = [element getNamedChild:@"VASTAdTagURI"].text;
    wrapper.error = [element getNamedChild:@"Error"].text;
    wrapper.extensions = [element getNamedChild:@"Extensions"].text;
    
    MFDTXMLElement *creatives = [element getNamedChild:@"Creatives"];
    if(creatives) {
        wrapper.creatives = [self readCreatives:creatives];
    }
    
    return wrapper;
}

+(VAST_StaticResource *)readStaticResource:(MFDTXMLElement *)element {
    VAST_StaticResource *staticResource = [[VAST_StaticResource alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    staticResource.type = [attributes objectForKey:@"creativeType"];
    staticResource.url = element.text;
    
    return staticResource;
}


+(VAST_CompanionAds *)readCompanionAds:(MFDTXMLElement *)element {
    VAST_CompanionAds *companionAds = [[VAST_CompanionAds alloc]init];
    
    NSArray *companionElements = [element getNamedChildren:@"Companion"];
    NSMutableArray *companions = [[NSMutableArray alloc]init];
    for (int i = 0; i < companionElements.count; i++) {
        MFDTXMLElement *element = [companionElements objectAtIndex:i];
        
        VAST_Companion *companion = [self readCompanion:element];
        [companions addObject:companion];
    }
    companionAds.companions = companions;
    
    return companionAds;
}

+(VAST_Companion *)readCompanion:(MFDTXMLElement *)element {
    VAST_Companion *companion = [[VAST_Companion alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    
    companion.Id = [attributes objectForKey:@"id"];
    companion.apiFramework = [attributes objectForKey:@"apiFramework"];
    companion.height = [[attributes objectForKey:@"height"] integerValue];
    companion.width = [[attributes objectForKey:@"width"] integerValue];
    companion.assetHeight = [[attributes objectForKey:@"assetHeight"] integerValue];
    companion.assetWidth = [[attributes objectForKey:@"assetWidth"] integerValue];
    companion.expandedHeight = [[attributes objectForKey:@"expandedHeight"] integerValue];
    companion.expandedWidth = [[attributes objectForKey:@"expandedWidth"] integerValue];
    companion.adSlotId = [attributes objectForKey:@"adSlotId"];
    
    
    
    MFDTXMLElement *staticResource = [element getNamedChild:@"StaticResource"];
    if(staticResource) {
        companion.staticResource = [self readStaticResource:staticResource]; //
    }
    
    MFDTXMLElement *htmlResource = [element getNamedChild:@"HTMLResource"];
    if(htmlResource) {
        companion.htmlResource = htmlResource.text;
    }
    
    MFDTXMLElement *iFrameResource = [element getNamedChild:@"IFrameResource"];
    if(iFrameResource) {
        companion.iFrameResource = iFrameResource.text;
    }
    
    MFDTXMLElement *companionClickThrough = [element getNamedChild:@"CompanionClickThrough"];
    if(companionClickThrough) {
        companion.companionClickThrough = companionClickThrough.text;
    }
    
    MFDTXMLElement *companionClickTracking = [element getNamedChild:@"CompanionClickTracking"];
    if(companionClickTracking) {
        companion.companionClickTracking = companionClickTracking.text;
    }
    
    MFDTXMLElement *altText = [element getNamedChild:@"AltText"];
    if(altText) {
        companion.altText = altText.text;
    }
    
    MFDTXMLElement *trackingEvents = [element getNamedChild:@"TrackingEvents"];
    if(trackingEvents) {
        companion.trackingEvents = [self readTrackingEvents:trackingEvents];
    }

    return companion;
}

+(NSMutableArray *)readMediaFiles:(MFDTXMLElement *)element {
    NSMutableArray *mediaFiles = [[NSMutableArray alloc]init];
    
    NSArray *mediaFileElements = [element getNamedChildren:@"MediaFile"];
    
    for (int i = 0; i < mediaFileElements.count; i++) {
        MFDTXMLElement *element = [mediaFileElements objectAtIndex:i];
        VAST_MediaFile *mediaFile = [self readMediaFile:element];
        
        [mediaFiles addObject:mediaFile];
    }
    
    return mediaFiles;
}

+(NSMutableArray *)readTrackingEvents:(MFDTXMLElement *)element {
    NSMutableArray *trackingEvents = [[NSMutableArray alloc]init];
    
    NSArray *trackingElements = [element getNamedChildren:@"Tracking"];
    
    for (int i = 0; i < trackingElements.count; i++) {
        MFDTXMLElement *element = [trackingElements objectAtIndex:i];
        VAST_Tracking *tracking = [self readTracking:element];
        
        [trackingEvents addObject:tracking];
    }
    
    return trackingEvents;
}

+(VAST_Tracking *)readTracking:(MFDTXMLElement *)element {
    VAST_Tracking *tracking = [[VAST_Tracking alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    
    tracking.event = [attributes objectForKey:@"event"];
    tracking.url = element.text;
    
    return tracking;
}

+(VAST_MediaFile *)readMediaFile:(MFDTXMLElement *)element {
    VAST_MediaFile *mediaFile = [[VAST_MediaFile alloc]init];
    
    NSMutableDictionary *attributes = element.attributes;
    
    mediaFile.delivery = [attributes objectForKey:@"delivery"];
    mediaFile.type = [attributes objectForKey:@"type"];
    mediaFile.codec = [attributes objectForKey:@"codec"];
    mediaFile.Id = [attributes objectForKey:@"id"];
    mediaFile.bitrate = [attributes objectForKey:@"bitrate"];
    mediaFile.scalable = [[attributes objectForKey:@"scalable"] boolValue];
    mediaFile.maintainAspectRatio = [[attributes objectForKey:@"maintainAspectRatio"] boolValue];
    mediaFile.apiFramework = [attributes objectForKey:@"apiFramework"];
    mediaFile.height = [[attributes objectForKey:@"height"] integerValue];
    mediaFile.width = [[attributes objectForKey:@"width"] integerValue];
    
    mediaFile.url = element.text;
    
    return mediaFile;
}

+(VAST_VideoClicks *)readVideoClicks:(MFDTXMLElement *)element {
    VAST_VideoClicks *videoClicks = [[VAST_VideoClicks alloc]init];

    videoClicks.clickThrough = [element getNamedChild:@"ClickThrough"].text;
    
    NSArray *clickTrackingElements = [element getNamedChildren:@"ClickTracking"];
    NSMutableArray *clickTracking = [[NSMutableArray alloc]init];
    for (int i = 0; i < clickTrackingElements.count; i++) {
        MFDTXMLElement *element = [clickTrackingElements objectAtIndex:i];
        [clickTracking addObject:element.text];
    }
    videoClicks.clickTracking = clickTracking;
    
    NSArray *customClickElements = [element getNamedChildren:@"ClickTracking"];
    NSMutableArray *customClicks = [[NSMutableArray alloc]init];
    for (int i = 0; i < customClickElements.count; i++) {
        MFDTXMLElement *element = [customClickElements objectAtIndex:i];
        [customClicks addObject:element.text];
    }
    videoClicks.customClicks = customClicks;
    
    return videoClicks;
}



@end
