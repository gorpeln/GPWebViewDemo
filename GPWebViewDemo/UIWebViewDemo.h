//
//  ViewController.h
//  GPWebViewDemo
//
//  Created by mac on 2022/4/12.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestProtocol <JSExport>
- (NSString *)getUserInfo;
@end

@interface UIWebViewDemo : UIViewController


@end

