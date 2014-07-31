//
//  ViewController.h
//  MKInputBar
//
//  Created by makai on 14-7-29.
//  Copyright (c) 2014年 makai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKInputBar.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MKInputBarDelegate>

@property (nonatomic, strong) UITableView *msgShowTableView;
@property (nonatomic, strong) MKInputBar *inputView;
@end
