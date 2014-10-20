//
//  AttachDownloadQueue.h
//  GQ_Manage_MobileHospital
//
//  Created by Mengying Xu on 14-10-8.
//  Copyright (c) 2014年 Mengying Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AttachDownloadManager;

@interface AttachDownloadQueue : NSObject

- (void)getFileByURL:(NSString *)strURL withProgress:(id)progress;
- (void)resetListSize:(NSInteger)iSize;
- (void)removeDownloadFileFromListByURL:(NSString *)strURL;
- (void)removeAllDownload;
@end
