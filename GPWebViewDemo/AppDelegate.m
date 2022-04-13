//
//  AppDelegate.m
//  GPWebViewDemo
//
//  Created by mac on 2022/4/12.
//

#import "AppDelegate.h"
#import "UIWebViewDemo.h"
#import "WKWebViewDemo.h"
#import "WebViewJavascriptBridgeDemo.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[WKWebViewDemo alloc]init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}




@end
