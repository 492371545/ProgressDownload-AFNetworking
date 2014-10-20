//
//  AttachTableViewCell.m
//  GQ_Doctor_MobileHospital
//
//  Created by Mengying Xu on 14-9-12.
//  Copyright (c) 2014年 Mengying Xu. All rights reserved.
//

#import "AttachTableViewCell.h"
#import "AttachDownloadQueue.h"
#define IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]) || ([(_ref) isKindOfClass:[NSNull class]]))

static NSString* const isDownloadAttachList = @"DownLoadNoticeFile";

@interface AttachTableViewCell()

@property (nonatomic,readonly) NSData *downloadedData;
@property (nonatomic,readonly) NSURL *downloadURL;
@property (nonatomic,readonly,copy) NSString *downloadStr;
@property (nonatomic)FileLoadStatus loadStatus;

@property (nonatomic, readonly) AttachDownloadQueue *downloadQueue;

@end

@implementation AttachTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)reloadViewdownloadURL:(NSURL*)url WithTitle:(NSString*)tit WithStatus:(NSString*)status
{
    _downloadStr = url ?[NSString stringWithFormat:@"%@",url]:@"";
    self.titleLbl.text = tit;
    
    
    if([status isEqualToString:@"isFileNoLoad"])
    {
        [self setLoadStatus:isFileNoLoad];

    }
    else if([status isEqualToString:@"isFileLoading"])
    {    //当滑动tableView，正在下载的cell需要保持下载状态
        [self setLoadStatus:isFileLoading];

        [self downloadFile:url];

    }
    else if([status isEqualToString:@"isFileFinish"])
    {
        [self setLoadStatus:isFileFinish];

    }
    else if([status isEqualToString:@"isFileLoadOK"])
    {
        [self setLoadStatus:isFileLoadOK];

    }
    else if([status isEqualToString:@"isFileFail"])
    {
        [self setLoadStatus:isFileFail];

    }
   
  
}

- (IBAction)downBtnAction:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(downLoadFile:WithProgressCell:)])
    {
        [_delegate downLoadFile:(UIButton*)sender WithProgressCell:self];
    }
}

//设置cell的高度及UI布局
- (void)reload:(BOOL)hidden
{
    self.downView.hidden = hidden;
    
    [self.titleLbl sizeToFit];
    CGRect titleFrame = self.titleLbl.frame;
    
//    CGSize titleSize = [self.titleLbl.text sizeWithFont:self.titleLbl.font constrainedToSize:CGSizeMake(titleFrame.size.width-20, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:self.titleLbl.font,NSFontAttributeName, nil];
    
    CGRect titleSize = [self.titleLbl.text boundingRectWithSize:CGSizeMake(titleFrame.size.width-20, 1000) options:NSStringDrawingUsesFontLeading attributes:dic context:nil];

    CGFloat titleheight = (titleSize.size.height>40)?titleSize.size.height:40;
    titleFrame.origin.y = 10;
    titleFrame.size.height = titleheight;
    self.titleLbl.frame = titleFrame;
    
    CGRect downFrame = self.downView.frame;
    
    downFrame.origin.y = self.titleLbl.frame.origin.y+self.titleLbl.frame.size.height+5;
    downFrame.origin.x = titleFrame.origin.x;
    downFrame.size.height = 22;
    
    self.downView.frame = downFrame;
    
    CGRect cellFrame = [self frame];
    
    if(hidden == YES)
    {
        cellFrame.size.height = titleheight+20;

    }
    else
    {
        cellFrame.size.height = titleheight+42;

    }
    CGRect btnFrame = self.downBtn.frame;
    btnFrame.origin.y = (titleheight+20-btnFrame.size.height)/2;
    self.downBtn.frame = btnFrame;
    
    [self setFrame:cellFrame];
    
}
//设置cell的下载状态
- (void)setLoadStatus:(FileLoadStatus)loadStatus
{
    _loadStatus = loadStatus;
    
    [self setBtnStatus];
}

- (void)setBtnStatus
{
    switch (_loadStatus) {
        case isFileNoLoad:
        {
            
            [self.downBtn setTitle:@"下载"  forState:UIControlStateNormal];
            self.downView.hidden = YES;
            [self reload:YES];
            
        }
            break;
        case isFileLoading:
        {
            [self.downBtn setTitle:@"取消"  forState:UIControlStateNormal];
            self.downView.hidden = NO;
            self.progressView.hidden = NO;
            self.statusLbl.hidden = YES;
            [self reload:NO];
            
        }
            break;
        case isFileFinish:
        {
            [self.downBtn setTitle:@"打开"  forState:UIControlStateNormal];
            self.downView.hidden = NO;
            self.progressView.hidden = YES;
            self.statusLbl.hidden = NO;
            self.statusLbl.text = @"下载成功";
            [self reload:NO];
            
        }
            break;
        case isFileLoadOK:
        {
            [self.downBtn setTitle:@"打开"  forState:UIControlStateNormal];
            
            self.downView.hidden = YES;
            [self reload:YES];
            
        }
            break;
        case isFileFail:
        {
            [self.downBtn setTitle:@"重试"  forState:UIControlStateNormal];
            self.downView.hidden = NO;
            self.progressView.hidden = YES;
            self.statusLbl.hidden = NO;
            
            self.statusLbl.text = @"下载失败";
            [self reload:NO];
            
            
        }
            break;
        default:
            break;
    }
}
//开始下载
- (void)downloadFile:(NSURL*)url
{
    [self showFileByURL: [NSString stringWithFormat:@"%@",url]];
}
//取消该下载
- (void)cancelDown:(NSString *)strURL
{
    __block NSString *blockStrURL = [strURL copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (blockStrURL.length > 1)
            {
                // 从网络下载
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_downloadQueue)
                    {
                        [_downloadQueue removeDownloadFileFromListByURL:blockStrURL];
                    }
                });
            }else{}
        });
    });
    [self setLoadStatus:isFileFail];

}
- (void)setAttachDownloadFileQueue:(AttachDownloadQueue *)objOper
{
    if (_downloadQueue != objOper)
    {
        if (_downloadQueue)
        {
//            _downloadQueue.delegate = nil;
            
        }
        
        _downloadQueue = objOper;
        
        if (_downloadQueue)
        {
//            _downloadQueue.delegate = self;
            
        }
    }
}

//加入下载队列，并开始下载
- (void)showFileByURL:(NSString *)strURL
{
//    [self setDownloadStr:strURL];
    __block NSString *blockStrURL = [strURL copy];
    __block AttachTableViewCell *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (blockStrURL.length > 1)
            {
                // 从网络下载
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_downloadQueue)
                    {
                        [_downloadQueue getFileByURL:blockStrURL withProgress:weakSelf];
                    }else{}
                });
            }else{}
        });
    });
    [self setLoadStatus:isFileLoading];
}

#pragma mark - AttachDownloadManagerProgress Delegate

- (void)setDownloadProgress:(float)newProgress fromURL:(NSString *)strURL
{
    if (_downloadStr && [strURL hasSuffix:_downloadStr])
    {
        _progressView.progress = newProgress;
        double percentage  = newProgress * 100.0;
        
        if([_delegate respondsToSelector:@selector(progressCellDownloadProgress:Percentage:ProgressCell:)]) {
            [_delegate progressCellDownloadProgress:newProgress Percentage:percentage ProgressCell:self];
        }

    }
  
}
- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileSucc:(NSData *)filedata fromURL:(NSString *)strURL
{
    if (filedata)
    {
        if (self.downloadStr && [strURL hasSuffix:self.downloadStr])
        {
            [self saveFile:filedata];
            
            [_downloadQueue removeDownloadFileFromListByURL:strURL];
        }
    }
}
- (void)attachDownloadManager:(AttachDownloadManager *)downlad getFileFailedFromURL:(NSString *)strURL
{
    if (strURL)
    {
        if (_downloadStr && [strURL hasSuffix:_downloadStr])
        {
            if([_delegate respondsToSelector:@selector(progressCellDownloadFail:ProgressCell:)])
            {
                [_delegate progressCellDownloadFail:nil ProgressCell:self];
            }
            [_downloadQueue removeDownloadFileFromListByURL:strURL];
            
        }
    }

    
}
- (void)saveFile:(NSData*)fileData
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString *pathStr = [documentPaths firstObject];
    if (!pathStr) {
        
        NSLog(@"Documents 目录未找到");
        
    }
    //得到完整的文件名
    NSArray *arr = [_downloadStr componentsSeparatedByString:@"/"];
    
    NSString *filename = [arr lastObject];
    
    NSString *pathFile=[pathStr stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",filename]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //如果plist文件不存在，将工程中已建起的plist文件写入沙盒中
    BOOL isExist = [fm fileExistsAtPath:pathFile];
    
    if(!isExist)
    {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        [fileManager createFileAtPath:pathFile contents:nil attributes:nil];
        
    }
    
    if ([fileData writeToFile:pathFile atomically:YES]) {
        
        NSLog(@"下载成功");
        [self setLoadStatus:isFileFinish];
        
        [self savePlist:_downloadStr];
        if([_delegate respondsToSelector:@selector(progressCellDownloadFinished:ProgressCell:)])
        {
            [_delegate progressCellDownloadFinished:nil ProgressCell:self];
        }

    }
    else
    {
        NSLog(@"下载失败");

        [self setLoadStatus:isFileFail];
        if([_delegate respondsToSelector:@selector(progressCellDownloadFail:ProgressCell:)])
        {
            [_delegate progressCellDownloadFail:nil ProgressCell:self];
        }
    }

}

//将下载好的文件名存入DownLoadNoticeFile
- (void)savePlist:(NSString*)str
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString *pathStr = [documentPaths firstObject];
    NSString *filename = isDownloadAttachList;//下载过的文件列表集合
    //得到完整的文件名
    NSString *saveFileName=[pathStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];//fileName就是保存文件的文件名
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:saveFileName])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
        
        [fileManager copyItemAtPath:plistPath toPath:saveFileName error:&error];
        
        
    }
    
    NSMutableArray *arr =[[[NSMutableArray alloc] initWithContentsOfFile:saveFileName] mutableCopy];
    
    if(!IsStrEmpty(str))
    {
        [arr addObject:str];
    }
    
    [arr writeToFile:saveFileName atomically:YES];
}
@end
