//
//  AttachDownloadManager.h
//  GQ_Manage_MobileHospital
//
//  Created by Mengying Xu on 14-10-8.
//  Copyright (c) 2014年 Mengying Xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@protocol AttachDownloadManagerDelegate;

@interface AttachDownloadManager : NSObject

//@property (unsafe_unretained) id<AttachDownloadManagerDelegate>delegate;
@property (nonatomic, readonly) AFHTTPRequestOperation *opertation;

- (BOOL)getFileFromURL:(NSString *)strSrcURL progressDelegate:(id)progress;

- (void)cancelRequest;

- (void)setProgressDelegate:(id)progress;

@end

//@protocol AttachDownloadManagerDelegate <NSObject>

//- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileSucc:(NSData *)filedata fromURL:(NSString *)strURL;
//- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileFailedFromURL:(NSString *)strURL;
//- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileLoading:(double)progressAttach fromURL:(NSString *)strURL;

//@end