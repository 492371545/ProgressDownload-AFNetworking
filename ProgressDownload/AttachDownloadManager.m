//
//  AttachDownloadManager.m
//  GQ_Manage_MobileHospital
//
//  Created by Mengying Xu on 14-10-8.
//  Copyright (c) 2014年 Mengying Xu. All rights reserved.
//

#import "AttachDownloadManager.h"
#import "AttachTableViewCell.h"

@protocol AttachDownloadManagerProgressDelegate <NSObject>

- (void)setDownloadProgress:(float)newProgress fromURL:(NSString *)strURL;
- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileSucc:(NSData *)filedata fromURL:(NSString *)strURL;
- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileFailedFromURL:(NSString *)strURL;
@end

@interface AttachDownloadManager ()

@property (nonatomic, readonly) id <AttachDownloadManagerProgressDelegate> downloadProgressDelegate;

@end
@implementation AttachDownloadManager
- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    if (_opertation)
    {
        [_opertation cancel];
        _opertation = nil;
    }
//    _delegate = nil;
}
- (BOOL)getFileFromURL:(NSString *)strSrcURL progressDelegate:(id)progress WithSize:(long long)size
{
    BOOL bRet = NO;

    [self cancelRequest];
    
    if(strSrcURL && (strSrcURL.length > 0))
    {
        bRet = YES;

        [self cancelRequest];
        [self setProgressDelegate:progress];
        
        __block NSString *blockStrUrl = [strSrcURL copy];
        __block typeof(self) blockSelf = self;
        _opertation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:blockStrUrl]]];
        _opertation.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_opertation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            @try {
                NSData *data = (NSData *)responseObject;

                if(data)
                {
                    if(blockSelf.downloadProgressDelegate && [blockSelf.downloadProgressDelegate respondsToSelector:@selector(attachDownloadManager:getFileSucc:fromURL:)])
                    {
                        // delegate 通知获取成功

                        [blockSelf.downloadProgressDelegate attachDownloadManager:blockSelf getFileSucc:data fromURL:blockStrUrl];
                    }
                }
                else
                {
                    if(blockSelf.downloadProgressDelegate && [blockSelf.downloadProgressDelegate respondsToSelector:@selector(attachDownloadManager:getFileFailedFromURL:)])
                    {
                        // delegate 通知获取失败
                        
                        [blockSelf.downloadProgressDelegate attachDownloadManager:blockSelf getFileFailedFromURL:blockStrUrl];
                    }
                }
                
            }
            @catch (NSException *exception) {
                if(blockSelf.downloadProgressDelegate && [blockSelf.downloadProgressDelegate respondsToSelector:@selector(attachDownloadManager:getFileFailedFromURL:)])
                {
                    // delegate 通知获取失败
                    
                    [blockSelf.downloadProgressDelegate attachDownloadManager:blockSelf getFileFailedFromURL:blockStrUrl];
                }

            }
            @finally {
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if(blockSelf.downloadProgressDelegate && [blockSelf.downloadProgressDelegate respondsToSelector:@selector(attachDownloadManager:getFileFailedFromURL:)])
            {
                // delegate 通知获取失败
                
                [blockSelf.downloadProgressDelegate attachDownloadManager:blockSelf getFileFailedFromURL:blockStrUrl];
            }

        }];
        
        [_opertation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            
            // delegate 下载中...
            totalBytesExpectedToRead = size;
            double f = (double)totalBytesRead / totalBytesExpectedToRead;
            
            if(blockSelf.downloadProgressDelegate)
            {
                [blockSelf.downloadProgressDelegate setDownloadProgress:f fromURL:blockStrUrl];

            }
            
        }];
        
        [_opertation start];

    }
    else
    {
        bRet = NO;
    }
    
    return bRet;
    
}

- (void)cancelRequest
{
    if (_opertation)
    {
        [_opertation cancel];
        _opertation = nil;
    }
}

- (void)setProgressDelegate:(id)progress
{
    _downloadProgressDelegate = progress;
   
}

- (void)setCellProgress:(AttachTableViewCell*)cell
{
    
    
}

@end
