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

@interface ChatListController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<GroupChat *> *data;
@end

@implementation ChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarTitle:@"Chat"];
    
    
    _data = [NSMutableArray array];
    
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, ScreenWidth, ScreenHeight - SafeAreaTopHeight - 10)];
    _tableView.backgroundColor = ColorClear;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.alwaysBounceVertical = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [_tableView registerClass:[TextMessageCell class] forCellReuseIdentifier:NSStringFromClass(TextMessageCell.class)];
    
    
    [self.view addSubview:_tableView];

    [self loadData:0 pageSize:20];
    
 
    
}



- (void)loadData:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    GroupChatListRequest *request = [GroupChatListRequest new];
    request.page = pageIndex;
    request.size = pageSize;
    
    __weak typeof(self) weakSelf = self;
    [NetworkHelper getWithUrlPath:FindGroupChatByPagePath request:request success:^(id data) {
        NSError *error = nil;
        GroupChatListResponse *response = [[GroupChatListResponse alloc]initWithDictionary:data error:&error];
        
        [weakSelf processData:response.data];
    } failure:^(NSError *error) {
        
    }];
}
- (void)processData:(NSArray<GroupChat *> *)data {
    if (data.count == 0) {
        return;
    }
    
    NSMutableArray <GroupChat *> *tempArray = [NSMutableArray array];
    for (GroupChat *chat in data) {
        if ([chat.msg_type isEqualToString:@"text"]) {
            chat.cellAttributedString = [self cellAttributedString:chat];
            chat.contentSize = [self cellContentSize:chat];
            [tempArray addObject:chat];
        }
    }
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tempArray count])];
    [self.data insertObjects:tempArray atIndexes:indexes];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupChat *chat = _data[indexPath.row];
//    if ([chat.msg_type isEqualToString:@"text"]) {
        TextMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TextMessageCell.class) forIndexPath:indexPath];
        cell.textLabel.text = chat.msg_content;
        return cell;
//    }
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
//        return [ImageMessageCell contentSize:chat];
        return CGSizeZero;
    }else {
//        return [TimeCell contentSize:chat];
        return CGSizeZero;
    }
}

@end
