//
//  MyTabBarViewController.m
//  AppDeck
//
//  Created by hanine ben saad on 16/05/2018.
//  Copyright © 2018 Mathieu De Kermadec. All rights reserved.
//

#import "MyTabBarViewController.h"
#import "LoaderChildViewController.h"
#import "SwipeViewController.h"
#import "LoaderConfiguration.h"
#import "Singleton.h"
#import "AppURLCache.h"

@interface MyTabBarViewController (){
   
    NSMutableArray*items;
}

@end

@implementation MyTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(instancetype)initWithLoaderChild:(LoaderChildViewController*)child
{
    self=[super init];
    self.child=child;
    
    items=[[NSMutableArray alloc]init];
    _tabVC.view.backgroundColor=[UIColor redColor];
    
    _tabVC=  [[UITabBarController alloc] init];
    
    _tabVC.tabBar.barTintColor=[UIColor darkGrayColor];
    
    
    [self.view addSubview: _tabVC.view];
    
    return self;
}

-(void)loadWithItem:(NSDictionary*)item url:(NSURL*)url
{
    
    LoaderChildViewController * page = [self.child.loader getChildViewControllerFromURL:url.absoluteString type:@"default"];
    
    SwipeViewController *container = [[SwipeViewController alloc] initWithNibName:nil bundle:nil];
    container.current = page;
    container.tabBarItem.title=item[@"title"];
    
    if ([[item objectForKey:@"image"] hasPrefix:@"!"])
    {
        
         [[container tabBarItem] setImage:[[Singleton sharedInstance]getIconFromName:[item objectForKey:@"image"] withLoader:self.child.loader]];
        
    }
    else if ([item objectForKey:@"image"])
        [self downloadImage:[item objectForKey:@"image"] forItem:[container tabBarItem]];
    
    
    [items addObject:container];
    [_tabVC setViewControllers:items];

    if ([item[@"selected"] boolValue]==true) {
        _tabVC.selectedViewController=[_tabVC.viewControllers objectAtIndex:[_tabVC.viewControllers indexOfObject:container]];//or whichever index you want

    }
}

-(void)downloadImage:(NSString *)url forItem:(UITabBarItem*)item
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url relativeToURL:self.child.url]];
    
    NSCachedURLResponse *cachedResponse = [self.child.loader.appDeck.cache getCacheResponseForRequest:request];
    
    if (cachedResponse)
    {
        // [self setImageFromData:cachedResponse.data forState:state];
    }
    else
    {
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (error == nil)
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^
                                                             {
                                                                 item.image = [UIImage imageWithData:data];
                                                             });
                                          }
                                          else
                                              NSLog(@"Failed to download icon: %@: %@", url, error);
                                      }];
        
        [task resume];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _tabVC.view.frame=self.view.bounds;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
