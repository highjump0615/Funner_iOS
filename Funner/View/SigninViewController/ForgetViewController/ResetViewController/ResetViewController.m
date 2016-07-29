//
//  ResetViewController.m
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import "ResetViewController.h"
#import "UserData.h"

@interface ResetViewController () {
    NSTimer* mSendVerifyTimer;
    NSInteger mnWaitTime;
}

@property (weak, nonatomic) IBOutlet UIButton *mButOk;

@property (weak, nonatomic) IBOutlet UIButton *mButVerifyCode;
@property (weak, nonatomic) IBOutlet UILabel *mLblVerifyCode;

@property (weak, nonatomic) IBOutlet UITextField *mTxtVerifyCode;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPassword;

@end

@implementation ResetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mButOk.layer setMasksToBounds:YES];
    [self.mButOk.layer setCornerRadius:10];
    
    [self.mButVerifyCode.layer setMasksToBounds:YES];
    [self.mButVerifyCode.layer setCornerRadius:3];
    
    [self.mLblVerifyCode.layer setMasksToBounds:YES];
    [self.mLblVerifyCode.layer setCornerRadius:3];
    
    UIColor *colorWhite = [UIColor whiteColor];
    if ([self.mTxtPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"新密码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
    
    if ([self.mTxtVerifyCode respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtVerifyCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
    
    [self showVerifyCodeBut:YES];
    
    [self startTimer];
}

#pragma mark -
- (void)showVerifyCodeBut:(BOOL)bShow {
    [self.mLblVerifyCode setHidden:bShow];
    [self.mButVerifyCode setHidden:!bShow];
}


- (void)startTimer {
    if (!mSendVerifyTimer) {
        mnWaitTime = 60;
        mSendVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(waitThread:)
                                                          userInfo:nil
                                                           repeats:YES];
        [self showVerifyCodeBut:NO];
    }
}

- (void) waitThread:(NSTimer*)theTimer {
    
    if (mnWaitTime > 1) {
        mnWaitTime--;
        
        NSString *strText = [NSString stringWithFormat:@"重新发送(%d)", (int)mnWaitTime];
        [self.mLblVerifyCode setText:strText];
    }
    else {
        [self showVerifyCodeBut:YES];
        
        [mSendVerifyTimer invalidate];
        mSendVerifyTimer = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onButResend:(id)sender {
    [UserData requestPasswordResetWithPhoneNumber:self.mstrPhoneNumber block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self startTimer];
        } else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (IBAction)onReset:(id)sender {
    if ([self.mTxtVerifyCode.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入验证吗"
                                                        message:@""
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([self.mTxtPassword.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入密码"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [UserData resetPasswordWithSmsCode:self.mTxtVerifyCode.text newPassword:self.mTxtPassword.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // pop to login view controller
            NSArray *array = [self.navigationController viewControllers];
            [[self navigationController] popToViewController:array[array.count-3] animated:YES];
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}


@end
