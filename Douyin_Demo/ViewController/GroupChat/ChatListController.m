//
//  ChatListController.m
//  Douyin_Demo
//
//  Created by 谢汝 on 2018/11/26.
//  Copyright © 2018 谢汝. All rights reserved.
//

#import "ChatListController.h"
#import "NetworkHelper.h"
#import "TextMessageCell.h"
#import "ImageMessageCell.h"
#import "Visitor.h"
#import "RefreshControl.h"
#import "ChatTextView.h"
@interface ChatListController ()<UITableViewDataSource,UITableViewDelegate,ChatTextViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RefreshControl *refreshControl;
@property (nonatomic, strong) ChatTextView *textView;

@property (nonatomic, strong) NSMutableArray<GroupChat *> *data;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, strong) Visitor *visitor;

@end

@implementation ChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitle:@"Chat"];
    _visitor = readVisitor();
    
    _data = [NSMutableArray array];
    _pageSize = 20;
    _pageIndex = 0;
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, ScreenWidth, ScreenHeight - SafeAreaTopHeight - 10)];
    _tableView.backgroundColor = ColorClear;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceVertical = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    [_tableView registerClass:[TextMessageCell class] forCellReuseIdentifier:NSStringFromClass(TextMessageCell.class)];
    [_tableView registerClass:[ImageMessageCell class] forCellReuseIdentifier:NSStringFromClass(ImageMessageCell.class)];
    [self.view addSubview:_tableView];

    
    
    _refreshControl = [RefreshControl new];
    __weak typeof(self) weakSelf = self;
    [_refreshControl setOnRefresh:^{
        [weakSelf loadData:weakSelf.pageIndex pageSize:weakSelf.pageSize];
    }];
    [_tableView addSubview:_refreshControl];
    
    _textView = [ChatTextView new];
    _textView.delegate = self;
    
    [self loadData:_pageIndex pageSize:_pageSize];
    
 
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_textView show];
}




- (void)loadData:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    GroupChatListRequest *request = [GroupChatListRequest new];
    request.page = pageIndex;
    request.size = pageSize;
    
    __weak typeof(self) weakSelf = self;
    [NetworkHelper getWithUrlPath:FindGroupChatByPagePath request:request success:^(id data) {
        NSError *error = nil;
        GroupChatListResponse *response = [[GroupChatListResponse alloc]initWithDictionary:data error:&error];
        NSInteger preCount = weakSelf.data.count;
        
        [UIView setAnimationsEnabled:NO];
        [weakSelf processData:response.data];
        NSInteger currentCount = weakSelf.data.count;
        
        
        if (weakSelf.pageIndex ++ == 0 || preCount == 0 || (currentCount - preCount) <= 0) {
            [weakSelf scrollToBottom];
        }else {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(currentCount - preCount) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        [UIView setAnimationsEnabled:YES];
        [weakSelf.refreshControl endRefresh];
    } failure:^(NSError *error) {
        [weakSelf.refreshControl endRefresh];
    }];
}
- (void)processData:(NSArray<GroupChat *> *)data {
    if (data.count == 0) {
        return;
    }
    
    NSMutableArray <GroupChat *> *tempArray = [NSMutableArray array];
    for (GroupChat *chat in data) {
        if ([chat.msg_type isEqualToString:@"text"] || [chat.msg_type isEqualToString:@"image"]) {
            chat.cellAttributedString = [self cellAttributedString:chat];
            chat.contentSize = [self cellContentSize:chat];
            chat.cellHeight = [self cellHeight:chat];
            [tempArray addObject:chat];
        }
    }
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tempArray count])];
    [self.data insertObjects:tempArray atIndexes:indexes];
    [self.tableView reloadData];
}


- (void)onChatViewHeightChange:(CGFloat)height {
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
    [self scrollToBottom];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChat *chat = _data[indexPath.row];
    
    return chat.cellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChat *chat = _data[indexPath.row];
    if ([chat.msg_type isEqualToString:@"text"]) {
        TextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TextMessageCell.class) forIndexPath:indexPath];
        [cell initData:chat];
        return cell;
    }else {
        ImageMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ImageMessageCell.class) forIndexPath:indexPath];
        [cell initData:chat];
        return cell;
    }
    
    
    
    
//    }
}


- (void)scrollToBottom {
    if (self.data.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.data.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}



- (NSMutableAttributedString *)cellAttributedString:(GroupChat *)chat {
    if([chat.msg_type isEqualToString:@"system"]){
//        return [SystemMessageCell cellAttributedString:chat];
    }else if([chat.msg_type isEqualToString:@"text"]){
        return [TextMessageCell cellAttributedString:chat];
    }else  if([chat.msg_type isEqualToString:@"image"]){
        return nil;
    }else {
//        return [TimeCell cellAttributedString:chat];
         return nil;
    }
   return nil;
}

- (CGSize)cellContentSize:(GroupChat *)chat {
    if([chat.msg_type isEqualToString:@"system"]){
//        return [SystemMessageCell contentSize:chat];
        return CGSizeZero;
    }else if([chat.msg_type isEqualToString:@"text"]){
        return [TextMessageCell contentSize:chat];
    }else  if([chat.msg_type isEqualToString:@"image"]){
        return [ImageMessageCell contentSize:chat];
        return CGSizeZero;
    }else {
//        return [TimeCell contentSize:chat];
        return CGSizeZero;
    }
}

- (CGFloat)cellHeight:(GroupChat *)chat {
    if([chat.msg_type isEqualToString:@"system"]){
//        return [SystemMessageCell cellHeight:chat];
        return 0;
    }else if([chat.msg_type isEqualToString:@"text"]){
        return [TextMessageCell cellHeight:chat];
    }else  if([chat.msg_type isEqualToString:@"image"]){
        return [ImageMessageCell cellHeight:chat];
    }else {
//        return [TimeCell cellHeight:chat];
        return 0;
    }
}

@end
