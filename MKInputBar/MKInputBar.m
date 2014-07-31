//
//  MKInputBar.m
//  MKInputBar
//
//  Created by makai on 14-7-29.
//  Copyright (c) 2014年 makai. All rights reserved.
//

#import "MKInputBar.h"
#import "lame.h"

@implementation MKInputBar
@synthesize delegate, inputTextView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        originalFrame = frame;
        [self config];
        [self addItems];
        
    }
    return self;
}

- (void)config {
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setBorderColor:[[UIColor colorWithWhite:.7 alpha:1] CGColor]];
    [self.layer setBorderWidth:.6];
    [self setUserInteractionEnabled:YES];
    lastHeight = MKInputTextViewHeight;
}

- (void)addItems {
    
    inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(80, 5, 180, MKInputTextViewHeight)];
    [inputTextView setDelegate:self];
    [inputTextView setFont:[UIFont systemFontOfSize:15]];
    [inputTextView.layer setCornerRadius:5];
    [inputTextView.layer setBorderWidth:.5];
    [inputTextView.layer setBorderColor:[[UIColor colorWithWhite:.6 alpha:1] CGColor]];
    [self addSubview:inputTextView];
    
    //发送按钮
    sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(265, 5, 50, 33)];
    [sendBtn.layer setCornerRadius:5];
    [sendBtn.layer setBorderColor:[[UIColor colorWithWhite:.6 alpha:1] CGColor]];
    [sendBtn.layer setBorderWidth:.5];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setEnabled:NO];
    [sendBtn addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];
    
    //语音
    voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [voiceBtn setFrame:CGRectMake(5, 5, 32, 32)];
    [voiceBtn setTitle:@"语" forState:UIControlStateNormal];
    [voiceBtn.layer setCornerRadius:5];
    [voiceBtn.layer setBorderColor:[[UIColor colorWithWhite:.6 alpha:1] CGColor]];
    [voiceBtn.layer setBorderWidth:.5];
    [voiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(takeVoice) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceBtn];
    //键盘
    keyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [keyboardBtn setFrame:CGRectMake(5, 5, 32, 32)];
    [keyboardBtn setTitle:@"键" forState:UIControlStateNormal];
    [keyboardBtn.layer setCornerRadius:5];
    [keyboardBtn.layer setBorderColor:[[UIColor colorWithWhite:.6 alpha:1] CGColor]];
    [keyboardBtn.layer setBorderWidth:.5];
    [keyboardBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [keyboardBtn addTarget:self action:@selector(takeText) forControlEvents:UIControlEventTouchUpInside];
    [keyboardBtn setAlpha:0];
    [self addSubview:keyboardBtn];
    //图片
    imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageBtn setFrame:CGRectMake(42, 5, 32, 32)];
    [imageBtn setTitle:@"图" forState:UIControlStateNormal];
    [imageBtn.layer setCornerRadius:5];
    [imageBtn.layer setBorderColor:[[UIColor colorWithWhite:.6 alpha:1] CGColor]];
    [imageBtn.layer setBorderWidth:.5];
    [imageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(takeImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:imageBtn];
    
    //按下录音
    takeVoiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [takeVoiceBtn setFrame:CGRectMake(80, 5, 235, MKInputTextViewHeight)];
    [takeVoiceBtn.layer setCornerRadius:5];
    [takeVoiceBtn.layer setBorderColor:[[UIColor colorWithWhite:.6 alpha:1] CGColor]];
    [takeVoiceBtn.layer setBorderWidth:.5];
    [takeVoiceBtn setTitle:@"按下开始录音" forState:UIControlStateNormal];
    [takeVoiceBtn setTitle:@"松开结束录音" forState:UIControlStateHighlighted];
    [takeVoiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [takeVoiceBtn addTarget:self action:@selector(beginRecord) forControlEvents:UIControlEventTouchDown];
    [takeVoiceBtn addTarget:self action:@selector(endRecord) forControlEvents:UIControlEventTouchUpInside];
    [takeVoiceBtn setAlpha:0];
    [self addSubview:takeVoiceBtn];
}

#pragma mark - 按钮事件
- (void)takeText {
    
    [UIView animateWithDuration:.2 animations:^{
        [takeVoiceBtn setAlpha:0];
        [self.inputTextView setAlpha:1];
        [sendBtn setAlpha:1];
        [keyboardBtn setAlpha:0];
        [voiceBtn setAlpha:1];
    }];
    [self.inputTextView becomeFirstResponder];
}

- (void)takeVoice {
    
    [UIView animateWithDuration:.2 animations:^{
        [takeVoiceBtn setAlpha:1];
        [self.inputTextView setAlpha:0];
        [sendBtn setAlpha:0];
        [keyboardBtn setAlpha:1];
        [voiceBtn setAlpha:0];
    }];
    [self.inputTextView resignFirstResponder];
}

- (void)takeImage {
    
    [UIView animateWithDuration:.2 animations:^{
        [self.inputTextView resignFirstResponder];
    }];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"取自相册", nil];
    [actionSheet showInView:self];
}

- (void)beginRecord {
    
    voicePath = [self getVoicePath];
    
    session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [session setActive:YES error:nil];
    
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:voicePath] settings:recordSetting error:nil];
    if ([recorder prepareToRecord]) {
        [recorder record];
        NSLog(@"开始录音");
    }
}

- (NSString *)getVoicePath {
    
    NSString *groupPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"voices"];
    NSLog(@"groupPath = %@", groupPath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:groupPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:groupPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *voieName = [NSString stringWithFormat:@"%@.caf", [dateFormatter stringFromDate:[NSDate date]]];
    NSString *_voicePath = [NSString stringWithFormat:@"%@/%@", groupPath, voieName];
    NSLog(@"1.voicePath = %@", _voicePath);
    dateFormatter = nil;
    return _voicePath;
}

- (void)endRecord {
    
    NSLog(@"录音结束...");
    [recorder stop];
    recorder = nil;
    
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:voicePath] error:nil];
    if (player.duration < .4) {
        [self showAlertViewWithMessage:@"录音时间太短，请重新录制！"];
        voicePath = nil;
        return;
    }
    
    if ([MKInputBar lameCafFile:voicePath]) {
        
        voicePath = [voicePath stringByReplacingOccurrencesOfString:@"caf" withString:@"mp3"];
        [self.delegate inputBar:self didSendVoice:voicePath];
    }
}




#pragma mark - 录音格式转换 caf -> mp3
+ (BOOL)lameCafFile:(NSString *)cafFile{
    
    NSString *mp3File = [cafFile stringByReplacingOccurrencesOfString:@"caf" withString:@"mp3"];
    NSLog(@"cafFile = %@", cafFile);
    NSLog(@"mp3File = %@", mp3File);
    
    int read, write;
    
    FILE *pcm = fopen([cafFile cStringUsingEncoding:1], "rb");//被转换的文件
    fseek(pcm, 4*1024, SEEK_CUR);
    FILE *mp3 = fopen([mp3File cStringUsingEncoding:1], "wb");//转换后文件的存放位置
    
    const int PCM_SIZE = 8192;
    const int MP3_SIZE = 8192;
    short int pcm_buffer[PCM_SIZE*2];
    unsigned char mp3_buffer[MP3_SIZE];
    
    lame_t lame = lame_init();
    lame_set_in_samplerate(lame, 44100);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);
    
    do {
        read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
        if (read == 0)
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        else
            write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
        
        fwrite(mp3_buffer, write, 1, mp3);
        
    } while (read != 0);
    
    lame_close(lame);
    fclose(mp3);
    fclose(pcm);
    
    return YES;
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self.delegate inputBar:self didTakeImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            [self.delegate inputBar:self didTakeImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        default:
            break;
    }
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView {
    
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        return;
    }
    [sendBtn setEnabled:YES];
    [self adjustFrame];
}

- (void)adjustFrame {
    
    CGSize size = [inputTextView sizeThatFits:CGSizeMake(inputTextView.frame.size.width, 100)];

    size.height = size.height < MKInputTextViewHeight ? MKInputTextViewHeight : size.height;
    
    if (size.height < 100 && size.height != lastHeight) {
        
        float offHeight = size.height - lastHeight;
        [UIView animateWithDuration:.1 animations:^{
            [self.inputTextView setFrame:CGRectMake(80, 5, 180, size.height)];
            [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - offHeight, self.frame.size.width, self.frame.size.height + offHeight)];
        }];
        lastHeight = size.height;
    }
}

- (void)resetFrame {
    
    [UIView animateWithDuration:.1 animations:^{
        
        [inputTextView setFrame:CGRectMake(80, 5, 180, MKInputTextViewHeight)];
        [self setFrame:originalFrame];
    }];
}

#pragma mark - 发送文本
- (void)sendText {
    
    NSString *text = inputTextView.text;
    [self.delegate inputBar:self didSendText:text];
    inputTextView.text = @"";
    [sendBtn setEnabled:NO];
    
    float offHeight = MKInputTextViewHeight - lastHeight;
    [UIView animateWithDuration:.1 animations:^{
        [self.inputTextView setFrame:CGRectMake(80, 5, 180, MKInputTextViewHeight)];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - offHeight, self.frame.size.width, self.frame.size.height + offHeight)];
    }];
    
    lastHeight = MKInputTextViewHeight;
}

- (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
