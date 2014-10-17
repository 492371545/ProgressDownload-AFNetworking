//
//  AttachDownloadQueue.m
//  GQ_Manage_MobileHospital
//
//  Created by Mengying Xu on 14-10-8.
//  Copyright (c) 2014年 Mengying Xu. All rights reserved.
//

#import "AttachDownloadQueue.h"
#import "AttachDownloadManager.h"

#define INT_DefaultListSize                 10
#define STR_ListElementRequest              @"HTTPRequest"
#define STR_ListElementURL                  @"DownloadFileURL"
#define STR_ListElementCell                  @"DownloadCell"

@interface AttachDownloadQueue ()

@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, readonly) NSMutableArray *arrOperation;
@property (nonatomic, readonly) NSInteger listSize;

@end
@implementation AttachDownloadQueue
- (id)init
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("com.cienet.subeiDoctor.AttachDownloadList", NULL);
        _arrOperation = [[NSMutableArray alloc] init];

        _listSize = INT_DefaultListSize;
    }
    return self;
}
- (void)dealloc
{
    dispatch_sync(_queue, ^{
        for (NSDictionary *dicItem in _arrOperation)
        {
            AttachDownloadManager *objOper = [dicItem objectForKey:STR_ListElementRequest];
            if (objOper)
            {
                [objOper cancelRequest];
                
            }else{}
        }
        
        [_arrOperation removeAllObjects];
    });
    
    _queue = nil;
}
- (void)removeAllDownload
{
    dispatch_sync(_queue, ^{
        for (NSDictionary *dicItem in _arrOperation)
        {
            AttachDownloadManager *objOper = [dicItem objectForKey:STR_ListElementRequest];
            if (objOper)
            {
                [objOper cancelRequest];
                
            }else{}
        }
        
        [_arrOperation removeAllObjects];
    });

}
// 设置列表最大长度
- (void)resetListSize:(NSInteger)iSize
{
    dispatch_sync(_queue, ^{
        _listSize = (iSize > 0) ? iSize : INT_DefaultListSize;
    });
}
// 从网络下载文件，带进度条delegate
// 进度条delegate方法：
- (void)getFileByURL:(NSString *)strURL withProgress:(id)progress WithSize:(long long)size
{
    if(strURL && strURL.length > 0)
    {
        __block NSString *strBlockURl = [strURL copy];
//        __weak typeof(self) blockSelf = self;

        dispatch_sync(_queue, ^{
            BOOL bIsRequesting = NO;

            //判断该下载是否已经存在，不存在则添加到字典，存在则保持该下载进度
            for(NSDictionary *dicItem in _arrOperation)
            {
                NSString *strElementURL = [dicItem objectForKey:STR_ListElementURL];
                
                if(strElementURL && [strElementURL isEqualToString:strBlockURl])
                {//存在则保持该下载进度
                    AttachDownloadManager *op = [dicItem objectForKey: STR_ListElementRequest];
                    if (progress)
                    {
                        [op setProgressDelegate:progress];
                        
                    }
                    bIsRequesting = YES;
                    break;
                }
                
            }
            
            if(!bIsRequesting)
            {
                AttachDownloadManager *op = [[AttachDownloadManager alloc] init];
//                op.delegate = blockSelf;
                //不存在则添加到字典
                NSMutableDictionary *dicElement = [[NSMutableDictionary alloc] init];
                [dicElement setObject:op forKey:STR_ListElementRequest];
                [dicElement setObject:strBlockURl forKey:STR_ListElementURL];
                [_arrOperation addObject:dicElement];
                
                //开始下载
                [op getFileFromURL:strBlockURl progressDelegate:progress WithSize:size];
                
                // 列表满，取消第一个的下载并推出。
                if(_arrOperation && _arrOperation.count > _listSize)
                {
                    NSDictionary *dic1 = [_arrOperation safeObjectAtIndex:0];
                    
                    if(dic1)
                    {
                        AttachDownloadManager *op = [dic1 objectForKey:STR_ListElementRequest];
                        if(op)
                        {
                            [op cancelRequest];
                            op = nil;
                        }
                    }
                    
                    [_arrOperation removeObjectAtIndex:0];
                }
                
            }
            
        });
        
    }
}

- (void)removeDownloadFileFromListByURL:(NSString *)strURL
{
    if(_queue)
    {
        dispatch_async(_queue, ^{
            
            for(NSDictionary *dic in _arrOperation)
            {
                if(dic)
                {
                    NSString *s = [dic objectForKey:STR_ListElementURL];
                    if(strURL && [strURL isEqualToString:s])
                    {
                        AttachDownloadManager *op = [dic objectForKey:STR_ListElementRequest];
                        [op cancelRequest];
                        [_arrOperation removeObject:dic];
                        break;          // break loop
                    }
                }
            }
            
        });

    }
  
}

//#pragma mark - AttachDownloadManager delegate
//- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileSucc:(NSData *)filedata fromURL:(NSString *)strURL
//{
//    if(_delegate && [_delegate respondsToSelector:@selector(attachQueue:getFileSucc:fromURL:)])
//    {
//        [_delegate attachQueue:downlad getFileSucc:filedata fromURL:strURL];
//    }
//}
//- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileFailedFromURL:(NSString *)strURL
//{
//    if(_delegate && [_delegate respondsToSelector:@selector(attachQueue:getFileFailedFromURL:)])
//    {
//        [_delegate attachQueue:downlad getFileFailedFromURL:strURL];
//    }
//
//}

@end
