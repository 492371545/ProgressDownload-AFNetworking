//
//  AttachTableViewCell.h
//  GQ_Doctor_MobileHospital
//
//  Created by Mengying Xu on 14-9-12.
//  Copyright (c) 2014年 Mengying Xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AttachTableViewCell;
@class AttachDownloadQueue;

typedef enum
{
    isFileNoLoad = 0,//还未下载状态
    isFileLoading,//下载中状态
    isFileFinish,//下载完成状态
    isFileLoadOK,//已下载过
    isFileFail,//下载失败状态
}FileLoadStatus;


@protocol AttachTableViewCellDelegate<NSObject>
@required
-(void)progressCellDownloadProgress:(double)progress Percentage:(double)percentage ProgressCell:(AttachTableViewCell*)cell;
-(void)progressCellDownloadFinished:(NSData*)fileData ProgressCell:(AttachTableViewCell*)cell;
-(void)progressCellDownloadFail:(NSError*)error ProgressCell:(AttachTableViewCell*)cell;

//下载按钮Action
- (void)downLoadFile:(UIButton *)sender  WithProgressCell:(AttachTableViewCell*)cell;

@end

@interface AttachTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;

@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;


@property (nonatomic,strong) id<AttachTableViewCellDelegate> delegate;


- (void)setAttachDownloadFileQueue:(AttachDownloadQueue *)objOper;

- (void)reloadViewdownloadURL:(NSURL*)url
                    WithTitle:(NSString*)tit
                   WithStatus:(NSString*)status;

- (void)downloadFile:(NSURL*)url;
- (void)cancelDown:(NSString *)strURL;

- (void)setLoadStatus:(FileLoadStatus)loadStatus;

@end
