//
//  ViewController.m
//  ProtobufTestClient
//
//  Created by Fan Lv on 2018/1/19.
//  Copyright © 2018年 DouYu. All rights reserved.
//

#import "ViewController.h"
#import "User.pbobjc.h"

#define SCREEN_HEIGHT                   [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH                    [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()
{
    UILabel *_infolabel;
    UITextView *_textView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0,64, SCREEN_WIDTH, 200)];
    _textView.editable = NO;
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_textView];
    
    _infolabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 280, SCREEN_WIDTH - 20, 30)];
    _infolabel.textColor = [UIColor blackColor];
    _infolabel.font = [UIFont systemFontOfSize:12];
    _infolabel.text = @"数据大小：0K";
    [self.view addSubview:_infolabel];


    UIButton *bBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 400, SCREEN_WIDTH - 20, 50)];
    bBtn.backgroundColor = [UIColor orangeColor];
    bBtn.layer.cornerRadius = 25;
    bBtn.clipsToBounds = YES;
    [bBtn setTitle:@"请求Protobuf格式数据" forState:UIControlStateNormal];
    [bBtn addTarget:self action:@selector(requestHttpProtobuf) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bBtn];

}



- (void)requestHttpProtobuf
{
    NSDate *startDate = [NSDate date];
    LoginRequest *req = [[LoginRequest alloc] init];
    req.username = @"admin";
    req.password = @"123456";
    [self postUrl:@"http://127.0.0.1:8080/login" dataBody:[req data] Completetion:^(id result, NSError *error) {
        if (!error && [result isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)result;
            NSError *pError;
            LoginResponse *resp = [[LoginResponse alloc] initWithData:data error:&pError];
            if (!pError) {
                NSDate *endDate1 = [NSDate date];
                _infolabel.text = [NSString stringWithFormat:@"数据大小 ： %.3f KB, 请求耗时：%f",[data length]/1000.0,[endDate1 timeIntervalSinceDate:startDate]];
                _textView.text = resp.description;
            }
        }
    }];
}

-(void)postUrl:(NSString *)urlStr dataBody:(NSData *)dataBody Completetion:(void (^) (id result,NSError * error))completion
{

    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];

    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:urlStr];

    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";

    //5.设置请求体
    request.HTTPBody = dataBody;

    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //8.解析数据
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] == 200)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data,nil);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,error);
            });
        }

    }];

    //7.执行任务
    [dataTask resume];
}





@end
