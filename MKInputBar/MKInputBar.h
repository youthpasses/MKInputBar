//
//  MKInputBar.h
//  MKInputBar
//
//  Created by makai on 14-7-29.
//  Copyright (c) 2014年 makai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class MKInputBar;

#define MKInputBarHeight 43
#define MKInputTextViewHeight 34

@protocol MKInputBarDelegate <NSObject>

- (void)inputBar:(MKInputBar *)inputBar didSendText:(NSString *)text;
- (void)inputBar:(MKInputBar *)inputBar didSendVoice:(NSString *)voicePath;
- (void)inputBar:(MKInputBar *)inputBar didTakeImageWithSourceType:(UIImagePickerControllerSourceType)sourceType;

@end

@interface MKInputBar : UIView<UITextViewDelegate, UIActionSheetDelegate,AVAudioSessionDelegate> {
    
    UIButton *sendBtn;
    CGRect originalFrame;
    float lastHeight;
    
    UIButton *voiceBtn;
    NSString *voicePath;
    UIButton *imageBtn;
    UIButton *keyboardBtn;
    UIButton *takeVoiceBtn;
    
    AVAudioRecorder *recorder;
    AVAudioSession *session;
}

@property (nonatomic, assign) id<MKInputBarDelegate> delegate;
@property (nonatomic, strong) UITextView *inputTextView;

@end
