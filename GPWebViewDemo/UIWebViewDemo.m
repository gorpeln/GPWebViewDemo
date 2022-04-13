//
//  ViewController.m
//  GPWebViewDemo
//
//  Created by mac on 2022/4/12.
//

#import "UIWebViewDemo.h"
#include <objc/message.h>

@interface UIWebViewDemo ()<UIWebViewDelegate,TestProtocol>

@property (nonatomic, strong) UIWebView     *webView;    //
@property (nonatomic, strong) JSContext     *context;    //

@end

@implementation UIWebViewDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    // 1.1
//    [self loadUIWebViewWithName:@"UIWebview_OCCallJS.html"];
//    [self loadTestBtn];

    // 1.2
//    [self loadUIWebViewWithName:@"UIWebview_JSCallOC.html"];
    
    
    
}


-(void)loadUIWebViewWithName:(NSString *)name{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    // 加载本地 H5 文件
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
    NSURLRequest *reqeust = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:reqeust];
}


/**
 [1.1] OC 调用 JS 函数
 */
/** [1.1.1] OC 拼接 JS 字符串调用 JS 方法*/
// 无返回值
- (void)didClickLeftItem {
    [self.webView stringByEvaluatingJavaScriptFromString:@"showAlert_noReturnValue('无返回值')"];
}
// 有返回值
- (void)didClickRightItem {
    NSString *resString = [self.webView stringByEvaluatingJavaScriptFromString:@"showAlert_hasReturnValue('有返回值')"];
    NSLog(@"%@", resString);
}


/** [1.1.2] JSContext 上下文环境调用 JS 函数*/
#pragma mark - UIWebViewDelegate
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    self.context = context;
//}
// 无返回值
- (void)didClickLeftItem3 {
    NSDictionary *dict = @{@"name": @"gorpeln", @"age": @28};
    // 上下文调用 JS 函数
    [self.context[@"ocCallJS_byJSContext"] callWithArguments:@[dict]];
}



/**
 [1.2] JS 调用 OC 函数
 */
/** [1.2.1] OC 拦截 JS 超链接操作请求 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // request : host + 路由  : 拦截
    if ([request.URL.scheme isEqualToString:@"gorpeln"]) {
        // 方法名 gorpeln://jsCallOC:/helloword/js
        NSString *routerName = request.URL.host;
        SEL methodSEL = NSSelectorFromString(routerName);
        // 测试方法为 jsCallOC
        NSLog(@"routerName => %@", routerName);
        if ([self respondsToSelector:methodSEL]) {
            objc_msgSend(self,methodSEL,@"");
        } else {
            NSLog(@"没有找到对应的路由方法");
        }
        return NO;
    }
    return YES;
}
/** JS 调用 OC 的响应方法 */
- (void)jsCallOC {
    NSLog(@"被JS调用的方法！");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"JS调用OC方法" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
}

/** [1.2.2] 向 JS 中注入 OC 类 */
#pragma mark - UIWebViewDelegate
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    // 可以注入实例对象也可以注入类对象
//    context[@"ViewController"] = self;
//}

- (NSString *)getUserInfo{
    NSLog(@"JS调用OC方法");
    return @"name = gorpeln";
}

/** [1.2.3] 使用 JSContext 上下文，JS函数 回调 OC 代码块 */
#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 拿到 JS 上下文引用
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.context = context;
    self.context[@"ViewController"] = self;
    // js 中注入全局变量
    [context evaluateScript:@"var arr = ['张三', '李四', '王五', '赵六']"];
    context[@"blockOCCode"] = ^(NSArray *jsArr){
        // jsArr 是 JS 传递给 OC代码块的参数
        NSLog(@"blockOCCode->jsArr == %@", jsArr);
        // 通过上下文拿到 JS 全局属性
        NSArray *orgArr = [JSContext currentArguments];
        NSLog(@"blockOCCode->orgArr == %@", orgArr);
    };
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
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(210, 0, 200, 100);
    btn2.backgroundColor = [UIColor cyanColor];
    [btn2 setTitle:@"OC 调用 JS 有返回值" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(didClickRightItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(0, 110, 200, 100);
    btn3.backgroundColor = [UIColor yellowColor];
    [btn3 setTitle:@"OC 调用 JS 有返回值" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(didClickLeftItem3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
}

@end
