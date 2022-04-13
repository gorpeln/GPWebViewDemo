//
//  WKWebViewDemo.m
//  GPWebViewDemo
//
//  Created by mac on 2022/4/12.
//

#import "WKWebViewDemo.h"
#import <WebKit/WebKit.h>
#include <objc/message.h>

@interface WKWebViewDemo ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView     *webView;    //

@end

@implementation WKWebViewDemo

- (void)viewDidLoad {
    [super viewDidLoad];

//    2.1
//    [self loadWKWebViewWithName:@"WKWebView_OCCallJS.html"];
//    [self loadTestBtn];

//    2.2
    [self loadWKWebViewWithName:@"WKWebView_JSCallOC.html"];
}


-(void)loadWKWebViewWithName:(NSString *)name{
    // 配置类
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

    // 适配移动设备
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    configuration.userContentController = wkUController;
    // 初始化 WebView
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    // <WKUIDelegate, WKNavigationDelegate>
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    // 加载（本地） H5 文件
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];

}

/**
 [2.1] OC 调用 JS 函数
 */
/** OC 调用 JS 返回值在 completionHandler 的回调参数 result 里 */
- (void)didClickLeftItem{
    // OC --> JS 有返回值
    NSString *jsStr = @"ocCallJS('WK_ocCallJS:OC-->JS')";
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // result 是 JS return 回来的值
        NSLog(@"%@----%@",result, error);
    }];
}

#pragma mark -  WKWebView默认禁止了下 Alert弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


/**
 [2.2] JS 调用 OC
 */
//2.2.1 拦截 JS 超链接请求
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    if ([navigationAction.request.URL.scheme isEqualToString:@"gorpeln"]) {
        NSLog(@"-------------");
        NSLog(@"requestURL= %@",navigationAction.request.URL);
        NSLog(@"scheme= %@",navigationAction.request.URL.scheme);
        NSLog(@"host= %@",navigationAction.request.URL.host);
        NSLog(@"port= %@",navigationAction.request.URL.port);
        NSLog(@"absoluteString= %@",navigationAction.request.URL.absoluteString);
        NSLog(@"path= %@",navigationAction.request.URL.path);
        NSLog(@"query= %@",navigationAction.request.URL.query);
        NSLog(@"-------------");

        
        NSString *routerName = navigationAction.request.URL.host;
        SEL methodSEL = NSSelectorFromString(routerName);
        NSLog(@"routerName => %@", routerName);
        if ([self respondsToSelector:methodSEL]) {
            objc_msgSend(self,methodSEL,@"");
            
        } else {
            NSLog(@"没有相应路由");
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 被 JS 调用的 OC 方法
- (void)WKWebView_jsCallOC {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"WK 中JS调用OC方法" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
}

// 2.2.2 OC 接收 JS 发来的消息
// ① 引入协议
// ② 注册消息处理名称为：messgaeToOC
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"messgaeToOC"];
}
// ③ 实现协议方法
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    // message.name 就是我们注册的 messgaeToOC
    // message.body 就是JS发送过来的消息
    NSLog(@"%@---%@",message.name, message.body);
    // 根据这两个参数 写我们的业务代码

}
// ④ 控制器销毁时移除 `ScriptMessageHandler`
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"messgaeToOC"];
}



// test btn
- (void)loadTestBtn{
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 200, 100);
    btn1.backgroundColor = [UIColor yellowColor];
    [btn1 setTitle:@"OC 调用 JS 无返回值" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(didClickLeftItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
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
