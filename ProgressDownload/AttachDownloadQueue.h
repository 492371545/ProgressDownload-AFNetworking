//
//  AttachDownloadQueue.h
//  GQ_Manage_MobileHospital
//
//  Created by Mengying Xu on 14-10-8.
//  Copyright (c) 2014年 Mengying Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AttachDownloadManager;
@protocol AttachDownloadQueueDelegate;

@interface AttachDownloadQueue : NSObject
@property (nonatomic,assign) id<AttachDownloadQueueDelegate>delegate;

- (void)getFileByURL:(NSString *)strURL withProgress:(id)progress WithSize:(long long)size;
- (void)resetListSize:(NSInteger)iSize;
- (void)removeDownloadFileFromListByURL:(NSString *)strURL;
- (void)removeAllDownload;
@end

@protocol AttachDownloadQueueDelegate <NSObject>

//- (void)attachQueue:(AttachDownloadManager *)downlad getFileSucc:(NSData *)filedata fromURL:(NSString *)strURL;
//- (void)attachQueue:(AttachDownloadManager *)downlad getFileFailedFromURL:(NSString *)strURL;

@end