#line 1 "/Users/dengliwen/Documents/Pear/PearDylib/Logos/PearDylib.xm"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "NSString+ParseUrl.h"
#import <MediaPlayer/MediaPlayer.h>

WKWebView *webView = nil;
UITextView *textView = nil;
NSDictionary *dicCookies = nil;

@interface WKWebView ()
- (void)playWithVidelUrl:(NSString *)videoUrl;
- (void)choosePlayType ;
- (void)sendRequest:(NSString *)type;
- (void)loadVideo:(NSString *)type movieId:(NSString *)movieId dicCookies:(NSDictionary *)dicCookies;
@end


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class WKWebView; 
static WKWebView* (*_logos_orig$_ungrouped$WKWebView$initWithFrame$configuration$)(_LOGOS_SELF_TYPE_INIT WKWebView*, SEL, CGRect, WKWebViewConfiguration *) _LOGOS_RETURN_RETAINED; static WKWebView* _logos_method$_ungrouped$WKWebView$initWithFrame$configuration$(_LOGOS_SELF_TYPE_INIT WKWebView*, SEL, CGRect, WKWebViewConfiguration *) _LOGOS_RETURN_RETAINED; static void _logos_method$_ungrouped$WKWebView$playWithVidelUrl$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST, SEL, NSString *); static void _logos_method$_ungrouped$WKWebView$choosePlayType(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$WKWebView$sendRequest$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST, SEL, NSString *); static void _logos_method$_ungrouped$WKWebView$loadVideo$movieId$dicCookies$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST, SEL, NSString *, NSString *, NSDictionary *); static void _logos_method$_ungrouped$WKWebView$playButtonClicked$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST, SEL, UIButton*); static void _logos_method$_ungrouped$WKWebView$handlePan$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST, SEL, UIPanGestureRecognizer*); 

#line 18 "/Users/dengliwen/Documents/Pear/PearDylib/Logos/PearDylib.xm"


static WKWebView* _logos_method$_ungrouped$WKWebView$initWithFrame$configuration$(_LOGOS_SELF_TYPE_INIT WKWebView* __unused self, SEL __unused _cmd, CGRect frame, WKWebViewConfiguration * configuration) _LOGOS_RETURN_RETAINED {
    id instance = _logos_orig$_ungrouped$WKWebView$initWithFrame$configuration$(self, _cmd, frame, configuration);
    webView = instance;
    NSLog(@"hook wkWebViewInit");
    
    UIButton *swi = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [swi setTitle:@"播放" forState:(UIControlStateNormal)];
    [swi setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    swi.frame = CGRectMake(0, 0, 50, 40);
    [swi sizeToFit];
    [self addSubview:swi];
    [self bringSubviewToFront:swi];
    [swi addTarget:self action:@selector(playButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [swi addGestureRecognizer:panGestureRecognizer];
    
    return instance;
}


static void _logos_method$_ungrouped$WKWebView$playWithVidelUrl$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString * videoUrl) {
    textView.text = videoUrl;
    NSURL *url = [NSURL URLWithString:videoUrl];
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}


static void _logos_method$_ungrouped$WKWebView$choosePlayType(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    UIAlertController *choosePlayType = [UIAlertController alertControllerWithTitle:@"选择播放方式" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *onLine = [UIAlertAction actionWithTitle:@"在线播放" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self sendRequest:@"0"];
    }];
    
    UIAlertAction *cnPlay = [UIAlertAction actionWithTitle:@"中文字幕" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self sendRequest:@"1"];
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [choosePlayType addAction:onLine];
    [choosePlayType addAction:cnPlay];
    [choosePlayType addAction:cancle];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:choosePlayType animated:YES completion:nil];
}


static void _logos_method$_ungrouped$WKWebView$sendRequest$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString * type) {
    
    NSString *absoluteString = self.URL.absoluteString;
    NSString *movieId = [absoluteString bd_getURLParameters][@"id"];
    

    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSLog(@"key:%@, value:%@",cookie.name, cookie.value);
    }
    
    NSDictionary *dicCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieStorage.cookies];
    
    
    

















    
    

    NSString *urlString = [NSString stringWithFormat:@"https://d.pear2.me/api/movieplay/GetMovieCloud/%@?onlyCzn=%@",movieId,type];
    


    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [request setValue:[dicCookies objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"请求失败");
            } else {
                NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"%@",responseDict);
                NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"jsonString:%@",jsonString);
                NSString *js = [NSString stringWithFormat:@"window.webkit.messageHandlers.play.postMessage('%@')", jsonString];
                NSLog(@"js:%@",js);
                [self evaluateJavaScript:js completionHandler:nil];
                return ;
                NSArray *list = responseDict[@"resolution"];
                if (list.count > 0) {
                    NSDictionary *dic = list.firstObject;
                    NSString *videoUrl = dic[@"url"];

                    NSString *m3u8VideoUrl = @"";
                    NSString *mp4VideoUrl = @"";

                    if([type isEqualToString:@"1"]) {
                        mp4VideoUrl = videoUrl;
                    } else{
                        m3u8VideoUrl = videoUrl;
                    }

                    NSMutableDictionary *outDic = [NSMutableDictionary dictionary];
                    outDic[@"movieId"] = responseDict[@"mov"];
                    outDic[@"name"] = responseDict[@"name"];
                    outDic[@"thumbnail"] = responseDict[@"thumbnail"];
                    outDic[@"mp4VideoUrl"] = mp4VideoUrl;
                    outDic[@"m3u8VideoUrl"] = m3u8VideoUrl;
                    NSString *paramString = [[outDic chx_URLParameterString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString *openUrlString =  [NSString stringWithFormat:@"hgplayer://www.hgplayer.com/play?%@",paramString];
                    NSURL *openUrl = [NSURL URLWithString:openUrlString];
                    [[UIApplication sharedApplication] openURL:openUrl];
                    
                    
                }
            }
        });
    }];
    
    [dataTask resume];
}


static void _logos_method$_ungrouped$WKWebView$loadVideo$movieId$dicCookies$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString * type, NSString * movieId, NSDictionary * dicCookies){
    
    NSString *urlString = [NSString stringWithFormat:@"https://d.pear2.org/api/movieplay/GetMovieCloud/%@?onlyCzn=%@",movieId,type];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [request setValue:[dicCookies objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"请求失败");
            } else {
                NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"%@",responseDict);
                NSArray *list = responseDict[@"resolution"];
                if (list.count > 0) {
                    NSDictionary *dic = list.firstObject;
                    NSString *videoUrl = dic[@"url"];
                    
                    NSString *m3u8VideoUrl = @"";
                    NSString *mp4VideoUrl = @"";
                    
                    if([type isEqualToString:@"1"]) {
                        mp4VideoUrl = videoUrl;
                    } else{
                        m3u8VideoUrl = videoUrl;
                    }
                    
                    NSMutableDictionary *outDic = [NSMutableDictionary dictionary];
                    outDic[@"movieId"] = responseDict[@"mov"];
                    outDic[@"name"] = responseDict[@"name"];
                    outDic[@"thumbnail"] = responseDict[@"thumbnail"];
                    outDic[@"mp4VideoUrl"] = mp4VideoUrl;
                    outDic[@"m3u8VideoUrl"] = m3u8VideoUrl;
                    NSString *paramString = [[outDic chx_URLParameterString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSString *openUrlString =  [NSString stringWithFormat:@"hgplayer://www.hgplayer.com/play?%@",paramString];
                    NSURL *openUrl = [NSURL URLWithString:openUrlString];
                    [[UIApplication sharedApplication] openURL:openUrl];
                }
            }
        });
    }];
    
    [dataTask resume];
}


static void _logos_method$_ungrouped$WKWebView$playButtonClicked$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIButton* sender) {
    
    NSString *absoluteString = self.URL.absoluteString;
    NSLog(absoluteString);
    if ([absoluteString containsString:@"movie/movieDetail"]) {
        
        [self choosePlayType];
    }
}



static void _logos_method$_ungrouped$WKWebView$handlePan$(_LOGOS_SELF_TYPE_NORMAL WKWebView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIPanGestureRecognizer* recognizer) {
    CGPoint translation = [recognizer translationInView:self];
    CGFloat centerX = recognizer.view.center.x+ translation.x;
    CGFloat thecenter = 0;
    recognizer.view.center = CGPointMake(centerX,recognizer.view.center.y+ translation.y);
    [recognizer setTranslation:CGPointMake(0,0) inView:self];
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat ScreenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat kFloatButtonWidth = 50;
    
    if(recognizer.state==UIGestureRecognizerStateEnded|| recognizer.state==UIGestureRecognizerStateCancelled) {
        if(centerX > ScreenWidth / 2) {
            thecenter = ScreenWidth - kFloatButtonWidth/2;
        }else{
            thecenter = kFloatButtonWidth/2;
        }
        CGFloat endY = recognizer.view.center.y+ translation.y;
        CGFloat bottomEndY = (ScreenHeight - kFloatButtonWidth/2);
        if (endY < kFloatButtonWidth/2) {
            endY = kFloatButtonWidth/2;
        } else if (endY > bottomEndY) {
            endY = bottomEndY;
        }
        recognizer.view.center = CGPointMake(thecenter, endY);
    }
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$WKWebView = objc_getClass("WKWebView"); MSHookMessageEx(_logos_class$_ungrouped$WKWebView, @selector(initWithFrame:configuration:), (IMP)&_logos_method$_ungrouped$WKWebView$initWithFrame$configuration$, (IMP*)&_logos_orig$_ungrouped$WKWebView$initWithFrame$configuration$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSString *), strlen(@encode(NSString *))); i += strlen(@encode(NSString *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$WKWebView, @selector(playWithVidelUrl:), (IMP)&_logos_method$_ungrouped$WKWebView$playWithVidelUrl$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$WKWebView, @selector(choosePlayType), (IMP)&_logos_method$_ungrouped$WKWebView$choosePlayType, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSString *), strlen(@encode(NSString *))); i += strlen(@encode(NSString *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$WKWebView, @selector(sendRequest:), (IMP)&_logos_method$_ungrouped$WKWebView$sendRequest$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSString *), strlen(@encode(NSString *))); i += strlen(@encode(NSString *)); memcpy(_typeEncoding + i, @encode(NSString *), strlen(@encode(NSString *))); i += strlen(@encode(NSString *)); memcpy(_typeEncoding + i, @encode(NSDictionary *), strlen(@encode(NSDictionary *))); i += strlen(@encode(NSDictionary *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$WKWebView, @selector(loadVideo:movieId:dicCookies:), (IMP)&_logos_method$_ungrouped$WKWebView$loadVideo$movieId$dicCookies$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIButton*), strlen(@encode(UIButton*))); i += strlen(@encode(UIButton*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$WKWebView, @selector(playButtonClicked:), (IMP)&_logos_method$_ungrouped$WKWebView$playButtonClicked$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIPanGestureRecognizer*), strlen(@encode(UIPanGestureRecognizer*))); i += strlen(@encode(UIPanGestureRecognizer*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$WKWebView, @selector(handlePan:), (IMP)&_logos_method$_ungrouped$WKWebView$handlePan$, _typeEncoding); }} }
#line 247 "/Users/dengliwen/Documents/Pear/PearDylib/Logos/PearDylib.xm"
