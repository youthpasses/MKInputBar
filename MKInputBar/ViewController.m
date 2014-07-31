//
//  ViewController.m
//  MKInputView
//
//  Created by makai on 14-7-29.
//  Copyright (c) 2014年 makai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    
    NSMutableArray *textArray;
}

@end

@implementation ViewController
@synthesize msgShowTableView, inputView;

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    
    [self.inputView removeObserver:self.inputView forKeyPath:@"frame"];
    self.inputView = nil;
    self.msgShowTableView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self config];
    [self addItems];
}

- (void)config {
    
    self.navigationItem.title = @"MKInputBar";
    
    textArray = [[NSMutableArray alloc] initWithObjects:@"fa", @"fdsa", @"weew", @"weew", @"weew", @"weew", @"weew", @"weew", @"weew", @"weew", @"weew", nil];
}

- (void)addItems {
    
    self.msgShowTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, mksize.width, mksize.height - MKInputBarHeight)];
    [self.msgShowTableView setDelegate:self];
    [self.msgShowTableView setDataSource:self];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.msgShowTableView.tableFooterView = footerView;
    [self.view addSubview:self.msgShowTableView];
    
    self.inputView = [[MKInputBar alloc] initWithFrame:CGRectMake(0, mksize.height - MKInputBarHeight, mksize.width, MKInputBarHeight)];
    [self.inputView setDelegate:self];
    [self.view addSubview:self.inputView];
    
    [self.inputView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [self msgTableViewScrollToBottomAnimation:NO];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.inputView && [keyPath isEqualToString:@"frame"]) {
        
        [self.msgShowTableView setFrame:CGRectMake(0, 0, mksize.width, self.inputView.frame.origin.y)];
        [self.msgShowTableView setNeedsDisplay];
    }
}

#pragma mark - UITableView Delegate / Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return textArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
    cell.textLabel.text = [textArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    [self.inputView.inputTextView resignFirstResponder];
}


- (void)msgTableViewScrollToBottomAnimation:(BOOL)animation {
    
    if (textArray.count == 0) {
        
        return;
    }
    
    [self.msgShowTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animation];
}

#pragma mark - MKInputView Delegate
- (void)inputBar:(MKInputBar *)inputBar didSendText:(NSString *)text {
    
    [textArray addObject:text];
    [self.msgShowTableView reloadData];
    [self msgTableViewScrollToBottomAnimation:YES];
}

- (void)inputBar:(MKInputBar *)inputBar didSendVoice:(NSString *)voicePath {
    
    [textArray addObject:@"[语音]"];
    [self.msgShowTableView reloadData];
    [self msgTableViewScrollToBottomAnimation:YES];
}

- (void)inputBar:(MKInputBar *)inputBar didTakeImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    
}

#pragma mark - 键盘 显示消息 通告
- (void)keyboardWillShow:(NSNotification *)noti{
    
    NSDictionary *dic = [noti userInfo];
    
    float duration = [[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect rect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.inputView setFrame:CGRectMake(0, mksize.height - rect.size.height - self.inputView.frame.size.height, mksize.width, self.inputView.frame.size.height)];
    }];
    [self msgTableViewScrollToBottomAnimation:YES];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    
    NSDictionary *dic = [noti userInfo];
    
    float duration = [[dic objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        [self.inputView setFrame:CGRectMake(0, mksize.height - self.inputView.frame.size.height, mksize.width, self.inputView.frame.size.height)];
    }];
}



@end
