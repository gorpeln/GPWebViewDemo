//
//  WebViewJavascriptBridgeDemo.m
//  GPWebViewDemo
//
//  Created by mac on 2022/4/12.
//

#import "WebViewJavascriptBridgeDemo.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"

@interface WebViewJavascriptBridgeDemo ()<WKUIDelegate>

@property (nonatomic, strong) WKWebView                 *webView;    //
@property (nonatomic, strong) WebViewJavascriptBridge   *wjb;

@end

@implementation WebViewJavascriptBridgeDemo

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadWKWebViewWithName:@"WebViewJavascriptBridgeDemo.html"];
    [self loadTestBtn];
    //声明js调用oc方法的处理事件，这里写了后，h5那边只要请求了，oc内部就会响应
    [self jsCallOC];
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
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    // 加载（本地） H5 文件
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];

    [self createWjb];
}

- (void)createWjb {
    // 初始化桥接类实例
    self.wjb = [WebViewJavascriptBridge  bridgeForWebView:self.webView];
    // 设置 WKNavigationDelegate 代理，保留该协议使用者依然可用
    [self.wjb setWebViewDelegate:self];
}

/*
 含义：JS调用OC
 @param registerHandler 要注册的事件名称(比如这里我们为jsCallsOC)
 @param handel 回调block函数 当后台触发这个事件的时候会执行block里面的代码
 */


/**
 // JS 单纯的调用 OC 的 block
 WebViewJavascriptBridge.callHandler('jsCallsOC');

 // JS 调用 OC 的 block，并传递 JS 参数
 WebViewJavascriptBridge.callHandler('jsCallsOC',"JS 参数");

 // JS 调用 OC 的 block，传递 JS 参数，并接受 OC 的返回值。
 WebViewJavascriptBridge.callHandler('jsCallsOC',{data : "这是 JS 传递到 OC 的扫描数据"},function(dataFromOC){
             alert("JS 调用了 OC 的扫描方法!");
             document.getElementById("returnValue").value = dataFromOC;
 });
 */
- (void)jsCallOC {
    // JS-->OC
    [self.wjb registerHandler:@"jsCallsOC" handler:^(id data, WVJBResponseCallback responseCallback) {
        // data 是 JS 传递给OC 的参数，responseCallback可将执行结果回调给 JS
        NSLog(@"%@---%@----%@",[NSThread currentThread],data,responseCallback);
        responseCallback(@"JS调用的OC方法已执行");
    }];
}


/*
 含义：OC调用JS
 @param callHandler 商定的事件名称,用来调用网页里面相应的事件实现
 @param data id类型,相当于我们函数中的参数,向网页传递函数执行需要的参数
 注意，这里callHandler分3种，根据需不需要传参数和需不需要后台返回执行结果来决定用哪个
 */

/**
 // 单纯的调用 JSFunction，不往 JS 传递参数，也不需要 JSFunction 的返回值。
 [_jsBridge callHandler:@"OCCallJSFunction"];
 // 调用 JSFunction，并向 JS 传递参数，但不需要 JSFunciton 的返回值。
 [_jsBridge callHandler:@"OCCallJSFunction" data:@"把 HTML 的背景颜色改成橙色!!!!"];
 // 调用 JSFunction ，并向 JS 传递参数，也需要 JSFunction 的返回值。
 [_jsBridge callHandler:@"OCCallJSFunction" data:@"传递给 JS 的参数" responseCallback:^(id responseData) {
     NSLog(@"JS 的返回值: %@",responseData);
 }];
 */
- (void)OCCallJS {
    [self.wjb callHandler:@"OCCallJSFunction" data:@"传递参数param" responseCallback:^(id responseData) {
        // data 是 OC 传递给 JS 的参数，responseData是 JS 执行完成后回调给OC 的执行结果
        NSLog(@"%@--%@",[NSThread currentThread],responseData);
    }];
}



#pragma mark -  WKWebView默认禁止了下 Alert弹窗 需要将WKWebView的WKUIDelegate设置成self。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? : @"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


// test btn
- (void)loadTestBtn{
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 200, 200, 100);
    btn1.backgroundColor = [UIColor yellowColor];
    [btn1 setTitle:@"OC 调用 JS 无返回值" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(didClickLeftItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
}
-(void)didClickLeftItem{
    [self OCCallJS];
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
