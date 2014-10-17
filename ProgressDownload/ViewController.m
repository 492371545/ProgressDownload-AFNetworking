//
//  TableViewController.m
//  ProgressDownload
//
//  Created by Mengying Xu on 14-10-17.
//  Copyright (c) 2014年 Crystal Xu. All rights reserved.
//

#import "ViewController.h"
#import "AttachTableViewCell.h"
#import "AttachDownloadQueue.h"
#import "detailWebViewViewController.h"

static NSString* const isDownloadAttachList = @"DownLoadNoticeFile";

@interface ViewController ()<AttachTableViewCellDelegate>
{
    BOOL _isLoad;//是否下载

}
@property (nonatomic,strong)NSMutableArray *statusArr;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *saveAllFilwUrl;//保存下载过的地址

@property (nonatomic,strong)AttachDownloadQueue *downloadQueue;

@end

@implementation ViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
//        _statusArr = [[NSMutableArray alloc] init];
//        _saveAllFilwUrl = [[NSMutableArray alloc] init];
//
//        _downloadQueue = [[AttachDownloadQueue alloc] init];
//        [_downloadQueue resetListSize:10];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _statusArr = [[NSMutableArray alloc] init];
    _saveAllFilwUrl = [[NSMutableArray alloc] init];
    
    _downloadQueue = [[AttachDownloadQueue alloc] init];
    [_downloadQueue resetListSize:10];
    [self loadDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// load image URL from imgur.com
- (void)loadDataSource
{
    
    if(!_dataArr)
    {
        _dataArr = [[NSMutableArray alloc] init];

    }
    
    // Request
    NSString *URLPath = [NSString stringWithFormat:@"http://imgur.com/gallery.json"];
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200) {
            id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (res && [res isKindOfClass:[NSDictionary class]]) {
                NSArray *arrItems = [res objectForKey:@"data"];
                if (arrItems)
                {
                    for (NSDictionary *item in arrItems)
                    {
                        [self.dataArr addObject:[NSString stringWithFormat:@"http://i.imgur.com/%@%@", [item objectForKey:@"hash"], [item objectForKey:@"ext"]]];
                    }
                }else{}
                
                [self dataSourceDidLoad:res];
            } else {
                [self dataSourceDidError];
            }
        } else {
            [self dataSourceDidError];
        }
    }];
}

- (void)dataSourceDidLoad:(id)res
{
    [self.tableView reloadData];
    NSLog(@"dataArr === %@",_dataArr);
    
    for(int i=0; i<_dataArr.count; i++)
    {
        [_statusArr addObject:@"isFileNoLoad"];
    }
    
    NSLog(@"res === %@",res);

}

- (void)dataSourceDidError {
    [self.tableView reloadData];
    
    NSLog(@"获取图片URL失败！");
    

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [[NSBundle  mainBundle] loadNibNamed:@"AttachTableViewCell" owner:self options:nil] ;
    
    AttachTableViewCell *cell= [arr  lastObject];
    
    cell.delegate = self;
    cell.tag = indexPath.row+1;
    NSString * status = @"isFileNoLoad";
    if(_statusArr.count > indexPath.row)
    {
        status = [_statusArr objectAtIndex:indexPath.row];
    }
    
    NSString *str = [_dataArr objectAtIndex:indexPath.row];
    
    BOOL isDown = [self judgeIsLoaded:str];
    
    if(isDown == YES)
    {
        if([status isEqualToString:@"isFileFinish"])
        {
            [self.statusArr replaceObjectAtIndex:indexPath.row withObject:@"isFileLoadOK"];

        }
        
    }
    [cell setAttachDownloadFileQueue:_downloadQueue];
    
    [cell reloadViewdownloadURL:[NSURL URLWithString:str]
                      WithTitle:str?str:@""
                     WithStatus:status];
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AttachTableViewCell *cell = (AttachTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (BOOL)judgeIsLoaded:(NSString*)name
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString *pathStr = [documentPaths objectAtIndex:0];
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
    
    
    self.saveAllFilwUrl = arr;
    
    [self.saveAllFilwUrl enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString *str = (NSString*)obj;
         
         if([str rangeOfString:name?name:@""].location != NSNotFound)
         {
             _isLoad = YES;
             *stop = YES;
         }
         else
         {
             _isLoad = NO;
         }
     }];
    
    return _isLoad;
    
}
#pragma mark -AttachTableViewCell Btn delegate
- (void)downLoadFile:(UIButton *)sender  WithProgressCell:(AttachTableViewCell *)cell
{
    
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    
    NSString *str = [self.dataArr objectAtIndex:index.row];
    
    if([sender.titleLabel.text isEqualToString:@"打开"])
    {        
        detailWebViewViewController *vc = [[detailWebViewViewController alloc] initWithStr:str];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        
        AttachTableViewCell* cell = (AttachTableViewCell*)[self.tableView cellForRowAtIndexPath:index];
        
        if([sender.titleLabel.text isEqualToString:@"取消"])
        {
            [cell cancelDown:str];
            [self.statusArr replaceObjectAtIndex:index.row withObject:@"isFileFail"];
        }
        else
        {
            [cell downloadFile:[NSURL URLWithString:str]];
            [self.statusArr replaceObjectAtIndex:index.row withObject:@"isFileLoading"];

        }
        
        [self.tableView reloadData];
        
    }
    
}

#pragma mark - progressCell
-(void)progressCellDownloadProgress:(double)progress Percentage:(double)percentage ProgressCell:(AttachTableViewCell *)cell{
    if(progress == 0)
    {
        [self.statusArr replaceObjectAtIndex:cell.tag-1 withObject:@"isFileNoLoad"];
    }
    else if(progress != 1)
    {
        [self.statusArr replaceObjectAtIndex:cell.tag-1 withObject:@"isFileLoading"];
    }
    else if(progress == 1)
    {
    
        [self.statusArr replaceObjectAtIndex:cell.tag-1 withObject:@"isFileFinish"];

    }
    
}
-(void)progressCellDownloadFinished:(NSData*)fileData ProgressCell:(AttachTableViewCell *)cell
{
    [self.statusArr replaceObjectAtIndex:cell.tag-1 withObject:@"isFileFinish"];
    
    [cell setLoadStatus:isFileFinish];
    
}
-(void)progressCellDownloadFail:(NSError*)error ProgressCell:(AttachTableViewCell *)cell{
    
    [self.statusArr replaceObjectAtIndex:cell.tag-1 withObject:@"isFileFail"];

    [cell setLoadStatus:isFileFail];
    
}

@end
