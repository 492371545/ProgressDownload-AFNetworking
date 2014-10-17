//
//  detailWebViewViewController.m
//  ProgressDownload
//
//  Created by Mengying Xu on 14-10-17.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import "detailWebViewViewController.h"

@interface detailWebViewViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic)  NSString *downStr;

@end

@implementation detailWebViewViewController

- (id)initWithStr:(NSString*)str
{
    self = [super init];
    
    if (self) {
        self.downStr = str;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    self.webView.backgroundColor = [UIColor clearColor];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString *pathStr = [documentPaths objectAtIndex:0];
    
    
    //得到完整的文件名
    NSString *path=[pathStr stringByAppendingPathComponent:[[self.downStr componentsSeparatedByString:@"/"] lastObject]];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
   NSURLRequest* _request = [NSURLRequest requestWithURL:url];
    
  
    [self.webView loadRequest:_request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
