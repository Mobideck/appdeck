//
//  AdManager.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 04/11/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "AdManager.h"
#import "AppDeckAdEngine.h"
//#import "Ad/WideSpace/WideSpaceAdEngine.h"
#import "SwipeViewController.h"
#import "LoaderChildViewController.h"
#import "LoaderConfiguration.h"
#import "PageViewController.h"
#import "JSonHTTPApi.h"
#import "AppDeckAdUsage.h"
#import "AdActionHelper.h"
#import "AdRequest.h"
#import "AdPlacement.h"
#import "AdRation.h"

//#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define APPDECK_CARRIER_INFO_DEFAULTS_KEY   @"com.appdeck.carrierinfo"

@implementation AdManager

-(id)initWithLoader:(LoaderViewController *)loader
{
    self = [self init];
    
    if (self)
    {
        self.loader = loader;
    
//        self.fakeCtl = [[UIViewController alloc] init];
    
        adEngines = [[NSMutableDictionary alloc] init];
        
        [self initializeCarrierInfo];
    }
    
    return self;
}

-(void)dealloc
{
    [self clean];
}

-(void)clean
{
    adEngines = nil;
}

#pragma mark - fetch an ad

-(void)fetchAdFor:(PageViewController *)page appearWithEvent:(AdManagerEvent)event
{

    
    
}

#pragma mark - PageViewController Ad Injection

-(void)pageViewController:(PageViewController *)page appearWithEvent:(AdManagerEvent)event
{
    /*
    // ad disabled in user profile ?
    if (self.loader.appDeck.userProfile.enable_ad == NO)
        return;
    */
    // event binding
    if (event != AdManagerEventNone)
        page.adEvent = event;
/*
    // only one ad per page
    if (page.interstitialAd != nil || page.rectangleAd != nil || page.bannerAd != nil)
        return;
    
    // ad disabled ?
    if (page.disableAds)
        return;
    */
    // ad request already fetching
    if (page.adRequest != nil)
        return;
    
    page.adRequest = [[AdRequest alloc] initWithManager:self page:page];
}

-(void)ad:(AppDeckAdViewController *)ad didUpdateState:(AppDeckAdState)state
{
    /*
    
    // move ready banner from working to ready
    if (state == AppDeckAdStateReady)
    {
        for (NSString *adType in self.adTypes)
        {
            AppDeckAdPreload *adPreload = [self.adPreloads objectForKey:adType];
            if (adPreload.workingAd == ad)
            {
                adPreload.readyAd = ad;
                adPreload.workingAd = nil;
                adPreload.AdEngineChain = nil;
                
                AppDeckAdUsage *adUsage = [self.adUsages objectForKey:adType];
                [adUsage Ad:ad willAppearWithEvent:adPreload.originEvent];
                adUsage = [ad.adEngine.adUsages objectForKey:adType];
                [adUsage Ad:ad willAppearWithEvent:adPreload.originEvent];

            }
        }
    }
    
    else if (state == AppDeckAdStateFailed)
    {
        // remove ad from fakeCtl
        [ad removeFromParentViewController];
        [ad.view removeFromSuperview];
        
        for (NSString *adType in self.adTypes)
        {
            AppDeckAdPreload *adPreload = [self.adPreloads objectForKey:adType];
            if (adPreload.workingAd == ad)
            {
                // update error ad usage
                AppDeckAdUsage *engineAdUsage = [ad.adEngine.adUsages objectForKey:adType];
                [engineAdUsage AdDidFailed:ad];
                
                adPreload.workingAd = nil;
                [self tryNextAdWithType:adType];
            }
        }
    }*/
}

#pragma mark - AdEngine

+(void)registerAdEngine:(NSString *)name class:(NSString *)className
{
    NSMutableDictionary *adEngineList = [AdManager getAvailableAdEngines];
    [adEngineList setObject:className forKey:name];
}

+(NSMutableDictionary *)getAvailableAdEngines
{
    static NSMutableDictionary *adEngineList = nil;
    
    if (adEngineList == nil)
        adEngineList = [[NSMutableDictionary alloc] init];
    return adEngineList;
}

-(AppDeckAdEngine *)adEngineFromId:(NSString *)engineId type:(NSString *)type config:(NSDictionary *)config
{
    AppDeckAdEngine *adEngine = [adEngines objectForKey:engineId];
        
    if (adEngine)
        return adEngine;

    NSMutableDictionary *adEngineList = [AdManager getAvailableAdEngines];
    NSString *adEngineClassName = [adEngineList objectForKey:type];
    
    if (adEngineClassName == nil)
    {
        NSLog(@"ERROR: no ad engine class found for type %@ (#%@)", type, engineId);
        return nil;
    }
    
    Class adEngineClass = NSClassFromString(adEngineClassName);
    if (adEngineClass == nil)
    {
        NSLog(@"ERROR: no ad engine class definition found for class name %@, type %@ (#%@)", adEngineClassName, type, engineId);
        return nil;
    }
    
    adEngine = [adEngineClass alloc];
    
    if (adEngine == nil)
    {
        NSLog(@"ERROR: failed to alloc ad engine for class name %@, type %@ (#%@)", adEngineClassName, type, engineId);
        return nil;
    }

    adEngine = [adEngine initWithAdManager:self andConfiguration:config];
    
    if (adEngine == nil)
    {
        NSLog(@"ERROR: failed to init ad engine for class name %@, type %@ (#%@)", adEngineClassName, type, engineId);
        return nil;
    }    

    if (adEngine != nil)
    {
        [adEngines setObject:adEngine forKey:engineId];
        return adEngine;
    }

    NSLog(@"ERROR: no ad engine found for type %@ (#%@)", type, engineId);
    
    return nil;
}

#pragma mark - Ad Action Helper

-(BOOL)handleActionURL:(NSString *)url withTarget:(NSString *)target
{
    if (adAction)
        [adAction cancel];

    adAction = [[AdActionHelper alloc] initWithURL:url target:target adManager:self];
    return YES;
}

#pragma mark - Initializing Carrier Info

- (void)initializeCarrierInfo
{
    self.carrierInfo = [NSMutableDictionary dictionary];
    
    // check if we have a saved copy
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:APPDECK_CARRIER_INFO_DEFAULTS_KEY];
    if(saved != nil) {
        [self.carrierInfo addEntriesFromDictionary:saved];
    }
    
    // now asynchronously load a fresh copy
    __block AdManager *me = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        [me performSelectorOnMainThread:@selector(updateCarrierInfoForCTCarrier:) withObject:networkInfo.subscriberCellularProvider waitUntilDone:NO];
    });
}

- (void)updateCarrierInfoForCTCarrier:(CTCarrier *)ctCarrier
{
    // use setValue instead of setObject here because ctCarrier could be nil, and any of its properties could be nil
    [self.carrierInfo setValue:ctCarrier.carrierName forKey:@"carrierName"];
    [self.carrierInfo setValue:ctCarrier.isoCountryCode forKey:@"isoCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileCountryCode forKey:@"mobileCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileNetworkCode forKey:@"mobileNetworkCode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.carrierInfo forKey:APPDECK_CARRIER_INFO_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Event handling

+(NSString *)AdManagerEventToString:(AdManagerEvent)event
{
    if (event == AdManagerEventNone)
        return @"none";
    if (event == AdManagerEventPush)
        return @"push";
    if (event == AdManagerEventPop)
        return @"pop";
    if (event == AdManagerEventSwipe)
        return @"swipe";
    if (event == AdManagerEventRoot)
        return @"root";
    if (event == AdManagerEventLaunch)
        return @"launch";
    if (event == AdManagerEventPopUp)
        return @"popup";
    if (event == AdManagerEventWakeUp)
        return @"wakeup";
    return @"unknow";
}

-(void)sendEvents:(NSTimer *)origin
{
    /*
    NSString *url = @"http://oxom-cloud.seb-dev-new.paris.office.netavenir.com/api/ads/event/track";

    
     
{
  "success": true,
  "serverRequestDate": "2014-09-12 10:13:39",
  "pageViewId": "5412ab337ecf38.10711187",
  "signature": "5412ab337ecf38.10711187",
  "template": {
    "id": "1b4b6629d6fa09ac3616f165938d9fee",
    "placements": [
      {
        "id": "91109dd499592e3e71cbf2c7b3b10de6",
        "settings": {
          "method": "appendTo",
          "target": "html body div#pubHorizontale div.text-center",
          "css": "margin-top:5px;"
        },
        "scenarios": [
          {
            "rules": {
              "maxWidth": 970,
              "maxHeight": 90
            },
            "ads": [
              {
                "id": "c950d372295c6db55aab529bd0605851",
                "type": "html_chunk",
                "settings": {
                  "code": "<a target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img style=\"border:0;\" src=\"http:\/\/placehold.it\/970x90\/0000FF&text=EzDBAd::33 (970x90)\" \/><\/a>\r\n",
                  "passbackable": false
                },
                "format": {
                  "id": "1b4b6629d6fa09ac3616f165938d9fee",
                  "type": "display",
                  "width": 970,
                  "height": 90
                },
                "offer": {
                  "id": "3ee435ebbd1d05f28ffa3b2f63374492",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 728,
              "maxHeight": 90
            },
            "ads": [
              {
                "id": "914c9571c6ef679b3f108e0287925ab5",
                "type": "javascript",
                "settings": {
                  "code": "google_ad_client = \"ca-pub-6988918329432153\";\r\ngoogle_ad_slot = \"3499811046\";\r\ngoogle_ad_width = 728;\r\ngoogle_ad_height = 90;\r\ngoogle_page_url = \"http:\/\/www.play3-live.com\/\";\r\n\r\ndocument.write('<scr'+'ipt type=\"text\/javascript\" src=\"http:\/\/pagead2.googlesyndication.com\/pagead\/show_ads.js\"><\/scr'+'ipt>');\r\n",
                  "passbackable": true
                },
                "format": {
                  "id": "914c9571c6ef679b3f108e0287925ab5",
                  "type": "display",
                  "width": 728,
                  "height": 90
                },
                "offer": {
                  "id": "d4f1a8bb799cdf476230e286b83ad654",
                  "type": "javascript",
                  "settings": [
                    
                  ]
                }
              },
              {
                "id": "e0d85a72c80094dcccd70821215c18ad",
                "type": "html_chunk",
                "settings": {
                  "code": "<a target=\"_blank\" href=\"http:\/\/u.mobpartner.mobi\/?mobtag=201094_5412ab24ed832_14091210&s=1024486&a=2339&dfb=&doci=&dad=192550&dc=768&dt=0&dco=FR&dpool=46539&ip=81.64.4.57&dse=95498&dbrid=0&dds=1410509604&dp=64675&dcr=&dpro=0&dgp=39322&drep=1&du=1&diu=1&dtl=1&dmoid=0&ddid=3&dopid=280&dosid=15&dovid=0&dtid=&dmod=&dosv=&dos=Web+Traffic&dbr=&ds=4&dsv=4&dm=&dsm=&dr=&ap=com.tap4fun.spartanwar&lg=FR&dcpty=2&dic=0&dst=1&source=&medium=&road=&referer=\"><img style=\"border:0\" src=\"http:\/\/assets.mobpartner.mobi\/creatives\/768\/2339\/15192\/64675\/370323_spartan-wars-android-app_android-app-install_install-spartan-wars-3-english_320x50.jpg\" \/><\/a>",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "90157f474648d02cc92bda6cfd245319",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 468,
              "maxHeight": 60
            },
            "ads": [
              {
                "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab339c9db4.04302314\" style=\"border:0;\" width=\"468\" height=\"60\" src=\"http:\/\/placehold.it\/468x60&text=EzDBAd::4 (468x60)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "756107633cf7e6311eb86be8dc2842af",
                  "type": "display",
                  "width": 468,
                  "height": 60
                },
                "offer": {
                  "id": "5a90ed443cbd6fa73f29dee1af233060",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 320,
              "maxHeight": 50
            },
            "ads": [
              {
                "id": "91109dd499592e3e71cbf2c7b3b10de6",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab339ca5b9.52337448\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::5 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "d08daa7be7ab1aa57a230d012f752fd8",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          }
        ]
      },
      {
        "id": "d12da8f1ccf2a4d5338968037e1d63aa",
        "settings": {
          "method": "appendTo",
          "target": "html body div#backContenu div#contenu div.fond div.container div.row div.col-md-4.no-gutter div#pubCarre.encart.col-xs-12.col-sm-6.col-md-12 div.contentEncart.encartNoir.no-gutter"
        },
        "scenarios": [
          {
            "rules": {
              "maxWidth": 300,
              "maxHeight": 600
            },
            "ads": [
              {
                "id": "24c00274b83b4f67f8d0d39276476816",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3380e7a8.38356452\" style=\"border:0;\" width=\"300\" height=\"600\" src=\"http:\/\/placehold.it\/300x600&text=EzDBAd::7 (300x600)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "cb3ad769c8bf75e1a595348af48299e9",
                  "type": "display",
                  "width": 300,
                  "height": 600
                },
                "offer": {
                  "id": "121be740e850c015bb3d9db9fb8dfb10",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 300,
              "maxHeight": 250
            },
            "ads": [
              {
                "id": "d12da8f1ccf2a4d5338968037e1d63aa",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3380ef50.59303924\" style=\"border:0;\" width=\"300\" height=\"250\" src=\"http:\/\/placehold.it\/300x250&text=EzDBAd::6 (300x250)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "d12da8f1ccf2a4d5338968037e1d63aa",
                  "type": "display",
                  "width": 300,
                  "height": 250
                },
                "offer": {
                  "id": "d96b6564c632400df0f1e4284be3a807",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          }
        ]
      },
      {
        "id": "24c00274b83b4f67f8d0d39276476816",
        "settings": {
          "method": "insertAfter",
          "target": "html body div#backContenu",
          "css": "text-align:center;"
        },
        "scenarios": [
          {
            "rules": {
              "maxWidth": 970,
              "maxHeight": 90
            },
            "ads": [
              {
                "id": "cb2104c9bc4c929454095357be7790de",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab33822545.21084674\" style=\"border:0;\" width=\"970\" height=\"90\" src=\"http:\/\/placehold.it\/970x90&text=EzDBAd::8 (970x90)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "1b4b6629d6fa09ac3616f165938d9fee",
                  "type": "display",
                  "width": 970,
                  "height": 90
                },
                "offer": {
                  "id": "45d560cdaa8a798ad43b14ba56ba20cf",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 728,
              "maxHeight": 90
            },
            "ads": [
              {
                "id": "e29d621fd0bd01045b034e6c80d42a6d",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab33822c57.82106624\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::11 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "31b428a0d03a65a60e9a22b02765116e",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 468,
              "maxHeight": 60
            },
            "ads": [
              {
                "id": "e29d621fd0bd01045b034e6c80d42a6d",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab33822c57.82106624\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::11 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "845d1ed697d2d5166f662056fce02f5e",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 320,
              "maxHeight": 50
            },
            "ads": [
              {
                "id": "e29d621fd0bd01045b034e6c80d42a6d",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab33822c57.82106624\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::11 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "abb85614624140b05becfecee65b6159",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          }
        ]
      },
      {
        "id": "cb2104c9bc4c929454095357be7790de",
        "settings": {
          "method": "prependTo",
          "target": "html body div#backContenu div#contenu div.fond div.container div.row div.col-md-8 div#hotNews.encart div.contentEncart",
          "css": "text-align:center; margin-bottom:10px;"
        },
        "scenarios": [
          {
            "rules": {
              "maxWidth": 728,
              "maxHeight": 90
            },
            "ads": [
              {
                "id": "93ba429fabfb007d2760f2b3d94da82f",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3381f8e4.93012747\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::14 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "ba6bb317d696b0ae3f23c529b808af10",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 468,
              "maxHeight": 60
            },
            "ads": [
              {
                "id": "93ba429fabfb007d2760f2b3d94da82f",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3381f8e4.93012747\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::14 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "ff2c7f136ebbfb16286030ea7b39ca52",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 320,
              "maxHeight": 50
            },
            "ads": [
              {
                "id": "93ba429fabfb007d2760f2b3d94da82f",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3381f8e4.93012747\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::14 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "1d181ab09e0ea307dec4998909be02a9",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          }
        ]
      },
      {
        "id": "cb3ad769c8bf75e1a595348af48299e9",
        "settings": {
          "method": "insertAfter",
          "target": "html body div#footer",
          "css": "text-align:center; margin-top:10px; margin-bottom:8px;"
        },
        "scenarios": [
          {
            "rules": {
              "maxWidth": 970,
              "maxHeight": 90
            },
            "ads": [
              {
                "id": "52cd3fecb9eac55f261adfdc6e788425",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3381b715.51902037\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::22 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "14d9a0f40bc1b4e612d1fbc26e0b7c55",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 728,
              "maxHeight": 90
            },
            "ads": [
              {
                "id": "ece9bde503baabd58a4916f4f91b430a",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3381be88.04370495\" style=\"border:0;\" width=\"728\" height=\"90\" src=\"http:\/\/placehold.it\/728x90&text=EzDBAd::20 (728x90)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "914c9571c6ef679b3f108e0287925ab5",
                  "type": "display",
                  "width": 728,
                  "height": 90
                },
                "offer": {
                  "id": "bcba27f4c426ce4679cd6ef277ab365f",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 468,
              "maxHeight": 60
            },
            "ads": [
              {
                "id": "f8b7848ce9d54ff0e69cae2a0b180182",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3381c597.15671939\" style=\"border:0;\" width=\"468\" height=\"60\" src=\"http:\/\/placehold.it\/468x60&text=EzDBAd::21 (468x60)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "756107633cf7e6311eb86be8dc2842af",
                  "type": "display",
                  "width": 468,
                  "height": 60
                },
                "offer": {
                  "id": "000d7f8ee20b343bf275be4c0bbb879c",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          },
          {
            "rules": {
              "maxWidth": 320,
              "maxHeight": 50
            },
            "ads": [
              {
                "id": "52cd3fecb9eac55f261adfdc6e788425",
                "type": "html_chunk",
                "settings": {
                  "code": "<a generated=\"true\" target=\"_top\" href=\"http:\/\/www.google.fr\/\"><img id=\"5412ab3381b715.51902037\" style=\"border:0;\" width=\"320\" height=\"50\" src=\"http:\/\/placehold.it\/320x50&text=EzDBAd::22 (320x50)\" \/><\/a>\"",
                  "passbackable": false
                },
                "format": {
                  "id": "7521b9b49a0d1e28a2c8d2e845d475db",
                  "type": "display",
                  "width": 320,
                  "height": 50
                },
                "offer": {
                  "id": "469d35d50287615e175312768bd2f4f5",
                  "type": "html_chunk",
                  "settings": [
                    
                  ]
                }
              }
            ]
          }
        ]
      }
    ]
  }
}
     context[apiVersion]=1.0
     context[browser][appCodeName]=Mozilla
     context[browser][appName]=Netscape
     context[browser][appVersion]=5.0 (Macintosh)
     context[browser][cookieEnabled]=true
     context[browser][doNotTrack]=yes
     context[browser][flashEnabled]=true
     context[browser][javaEnabled]=true
     context[browser][language]=fr
     context[browser][platform]=MacIntel
     context[browser][product]=Gecko
     context[browser][userAgent]=Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:31.0) Gecko/20100101 Firefox/31.0
     context[page][height]=759
     context[page][width]=1952
     context[referrer]=
     context[screen][height]=1320
     context[screen][width]=2347
     context[url]=http://www.play3-live.com/
     customerId=914c9571c6ef679b3f108e0287925ab5
     events[0][data][client_visibility_duration]=1410509603168
     events[0][data][impression_id]=5412ab22070463.18795039
     events[0][data][pageview_server_request_date]=2014-09-12 10:13:36
     events[0][type]=visibility_duration
     events[1][data][client_visibility_duration]=1410509603168
     events[1][data][impression_id]=5412ab22070479.41706258
     events[1][data][pageview_server_request_date]=2014-09-12 10:13:36
     events[1][type]=visibility_duration
     events[2][data][client_visibility_duration]=1410509603169
     events[2][data][impression_id]=5412ab22070484.78252384
     events[2][data][pageview_server_request_date]=2014-09-12 10:13:36
     events[2][type]=visibility_duration
     events[3][data][client_visibility_duration]=1410509603169
     events[3][data][impression_id]=5412ab22070495.68698640
     events[3][data][pageview_server_request_date]=2014-09-12 10:13:36
     events[3][type]=visibility_duration
     events[4][data][client_visibility_duration]=1410509603169
     events[4][data][impression_id]=5412ab220704a8.23394090
     events[4][data][pageview_server_request_date]=2014-09-12 10:13:36
     events[4][type]=visibility_duration
     method=cors
     
    events[0][data][client_admanager_loaded_ts]=1410509604863
    events[0][data][client_admanager_start_ts]=1410509604621
    events[0][data][client_mainrequest_loaded_ts]=1410509605059
    events[0][data][client_mainrequest_start_ts]=1410509604865
    events[0][data][client_page_start_ts]=1410509603165
    events[0][data][pageViewId]=5412ab337ecf38.10711187
    events[0][data][server_request_date]=2014-09-12 10:13:39
    events[0][data][template_id]=1b4b6629d6fa09ac3616f165938d9fee
    events[0][type]=pageview
    method=cors
     
     events[0][data][ad_id]=24c00274b83b4f67f8d0d39276476816
     events[0][data][client_insertion_done_ts]=1410509605441
     events[0][data][client_insertion_start_ts]=1410509605095
     events[0][data][impression_id]=5412ab25c58910.50479585
     events[0][data][pageview_id]=5412ab337ecf38.10711187
     events[0][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[0][data][parent_impression_id]=
     events[0][type]=impression
     events[1][data][ad_id]=93ba429fabfb007d2760f2b3d94da82f
     events[1][data][client_insertion_done_ts]=1410509605455
     events[1][data][client_insertion_start_ts]=1410509605143
     events[1][data][impression_id]=5412ab25c58938.66105932
     events[1][data][pageview_id]=5412ab337ecf38.10711187
     events[1][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[1][data][parent_impression_id]=
     events[1][type]=impression
     events[2][data][client_fill_ts]=1410509605456
     events[2][data][impression_id]=5412ab25c58901.00639792
     events[2][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[2][type]=fill
     events[3][data][client_fill_ts]=1410509605458
     events[3][data][impression_id]=5412ab25c58910.50479585
     events[3][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[3][type]=fill
     events[4][data][client_fill_ts]=1410509605478
     events[4][data][impression_id]=5412ab25c58924.79928515
     events[4][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[4][type]=fill
     events[5][data][client_fill_ts]=1410509605488
     events[5][data][impression_id]=5412ab25c58938.66105932
     events[5][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[5][type]=fill
     events[6][data][client_fill_ts]=1410509605492
     events[6][data][impression_id]=5412ab25c58947.91489466
     events[6][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[6][type]=fill
     events[7][data][ad_id]=c950d372295c6db55aab529bd0605851
     events[7][data][client_insertion_done_ts]=1410509605498
     events[7][data][client_insertion_start_ts]=1410509605066
     events[7][data][impression_id]=5412ab25c58901.00639792
     events[7][data][pageview_id]=5412ab337ecf38.10711187
     events[7][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[7][data][parent_impression_id]=
     events[7][type]=impression
     events[8][data][ad_id]=cb2104c9bc4c929454095357be7790de
     events[8][data][client_insertion_done_ts]=1410509605499
     events[8][data][client_insertion_start_ts]=1410509605119
     events[8][data][impression_id]=5412ab25c58924.79928515
     events[8][data][pageview_id]=5412ab337ecf38.10711187
     events[8][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[8][data][parent_impression_id]=
     events[8][type]=impression
     events[9][data][ad_id]=52cd3fecb9eac55f261adfdc6e788425
     events[9][data][client_insertion_done_ts]=1410509605500
     events[9][data][client_insertion_start_ts]=1410509605166
     events[9][data][impression_id]=5412ab25c58947.91489466
     events[9][data][pageview_id]=5412ab337ecf38.10711187
     events[9][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[9][data][parent_impression_id]=
     events[9][type]=impression
     method=cors
     
     events[0][data][client_visibility_ts]=1410509606552
     events[0][data][impression_id]=5412ab25c58901.00639792
     events[0][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[0][type]=visibility
     events[1][data][client_visibility_ts]=1410509606553
     events[1][data][impression_id]=5412ab25c58938.66105932
     events[1][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[1][type]=visibility
     method=cors
     
     
     context[apiVersion]=1.0
     context[browser][appCodeName]=Mozilla
     context[browser][appName]=Netscape
     context[browser][appVersion]=5.0 (Macintosh)
     context[browser][cookieEnabled]=true
     context[browser][doNotTrack]=yes
     context[browser][flashEnabled]=true
     context[browser][javaEnabled]=true
     context[browser][language]=fr
     context[browser][platform]=MacIntel
     context[browser][product]=Gecko
     context[browser][userAgent]=Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:31.0) Gecko/20100101 Firefox/31.0
     context[page][height]=759
     context[page][width]=1952
     context[referrer]=
     context[screen][height]=1320
     context[screen][width]=2347
     context[url]=http://www.play3-live.com/
     customerId=914c9571c6ef679b3f108e0287925ab5
     events[0][data][client_visibility_duration]=489007
     events[0][data][impression_id]=5412ab25c58910.50479585
     events[0][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[0][type]=visibility_duration
     method=cors
     
     
     */
    
    // events type
    /*
     
     // pageview: page loaded

     events[0][data][client_page_start_ts]=1410509603165 // page start
     events[0][data][client_admanager_start_ts]=1410509604621 // oxom js code start
     events[0][data][client_admanager_loaded_ts]=1410509604863 // oxom js loaded
     events[0][data][client_mainrequest_start_ts]=1410509604865 // request start
     events[0][data][client_mainrequest_loaded_ts]=1410509605059 // request received and loaded


     events[0][data][pageViewId]=5412ab337ecf38.10711187 // from oxom get template response
     events[0][data][server_request_date]=2014-09-12 10:13:39 // from oxom get template response
     events[0][data][template_id]=1b4b6629d6fa09ac3616f165938d9fee // from oxom get template response
     events[0][data][signature]=1b4b6629d6fa09ac3616f165938d9fee // from oxom get template response
     events[0][type]=pageview
     
    // impression: ad ask to server
     
     events[1][data][ad_id]=93ba429fabfb007d2760f2b3d94da82f
     events[1][data][client_insertion_start_ts]=1410509605143 // start ask for an ad
     events[1][data][client_insertion_done_ts]=1410509605455 // either ad loaded or failure
     events[1][data][impression_id]=5412ab25c58938.66105932 // auto generated uniqid('', true);
     events[1][data][pageview_id]=5412ab337ecf38.10711187 // from oxom get template response
     events[1][data][pageview_server_request_date]=2014-09-12 10:13:39 // from oxom get template response
     events[1][data][signature]=1b4b6629d6fa09ac3616f165938d9fee // from oxom get template response
     events[1][data][parent_impression_id]= // si passback
     events[1][type]=impression

     // fill: ad print to user
     
     events[5][data][client_fill_ts]=1410509605488
     events[5][data][impression_id]=5412ab25c58938.66105932
     events[5][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[5][type]=fill
     
     // visibility: IAB visibility: +50% of pixel are onscreen more than 1 seconde
     
     events[1][data][client_visibility_ts]=1410509606553 // current timestamp
     events[1][data][impression_id]=5412ab25c58938.66105932
     events[1][data][pageview_server_request_date]=2014-09-12 10:13:39 // from oxom get template response
     events[1][data][signature]=1b4b6629d6fa09ac3616f165938d9fee // from oxom get template response
     events[1][type]=visibility
     
     // visibility duration: total IAB visibility
     
     events[0][data][client_visibility_duration]=489007
     events[0][data][impression_id]=5412ab25c58910.50479585
     events[0][data][pageview_server_request_date]=2014-09-12 10:13:39
     events[0][type]=visibility_duration
     
     */
}

@end
