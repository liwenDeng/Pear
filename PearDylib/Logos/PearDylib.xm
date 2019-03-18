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

%hook WKWebView

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    id instance = %orig;
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

%new
- (void)playWithVidelUrl:(NSString *)videoUrl {
    textView.text = videoUrl;
    NSURL *url = [NSURL URLWithString:videoUrl];
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

%new
- (void)choosePlayType {
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

%new
- (void)sendRequest:(NSString *)type {
    
    NSString *absoluteString = self.URL.absoluteString;
    NSString *movieId = [absoluteString bd_getURLParameters][@"id"];
    
//     old cookies getter
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSLog(@"key:%@, value:%@",cookie.name, cookie.value);
    }
    // cookies转为字典
    NSDictionary *dicCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieStorage.cookies];
    
    
    // new cookie getter
//    NSLog(@"dicCookies:%@",dicCookies);
//    if (!dicCookies) {
//        [self.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * cookies) {
//            NSLog(@"get");
//            for (NSHTTPCookie *cookie in cookies) {
//                NSLog(@"key:%@, value:%@",cookie.name, cookie.value);
//            }
//            dicCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
//            NSLog(@"dicCookies:%@",dicCookies);
//            //        dispatch_async(dispatch_get_main_queue(), ^{
//            //            //回调或者说是通知主线程刷新，
//            //        });
//
//        }];
//    } else {
//        [self loadVideo:type movieId:movieId dicCookies:dicCookies];
//    }
    
    // 构造请求
//     old urlString
    NSString *urlString = [NSString stringWithFormat:@"https://cn.baidu-ch.com/api/movieplay/GetMovieCloud//%@?onlyCzn=%@",movieId,type];
    
//     new urlString
//    NSString *urlString = [NSString stringWithFormat:@"https://d.pear2.org/api/movieplay/GetMovieCloud/%@?onlyCzn=%@",movieId,type];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    // 注入cookie
    [request setValue:[dicCookies objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    NSURLSession *session = [NSURLSession sharedSession];
    // 发送请求
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
    //开始请求
    [dataTask resume];
}

%new
- (void)loadVideo:(NSString *)type movieId:(NSString *)movieId dicCookies:(NSDictionary *)dicCookies{
    // new urlString
    NSString *urlString = [NSString stringWithFormat:@"https://d.pear2.org/api/movieplay/GetMovieCloud/%@?onlyCzn=%@",movieId,type];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    // 注入cookie
    [request setValue:[dicCookies objectForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    NSURLSession *session = [NSURLSession sharedSession];
    // 发送请求
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
    //开始请求
    [dataTask resume];
}

%new
- (void)playButtonClicked:(UIButton*) sender {
    //判断是否是影片详情页面
    NSString *absoluteString = self.URL.absoluteString;
    NSLog(absoluteString);
    if ([absoluteString containsString:@"movie/movieDetail"]) {
        //选择播放方式
        [self choosePlayType];
    }
}

%new
- (void)handlePan:(UIPanGestureRecognizer*) recognizer
{
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
%end

