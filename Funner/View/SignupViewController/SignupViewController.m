//
//  SignupViewController.m
//  Funner
//
//  Created by highjump on 14-11-7.
//
//

#import "SignupViewController.h"
#import "SigninViewController.h"
#import "CommonUtils.h"
#import "MBProgressHUD.h"
#import "PolicyViewController.h"
#import "EditProfileViewController.h"
#import "UserData.h"
#import "MainTabbarController.h"

#import <CoreLocation/CoreLocation.h>


@interface SignupViewController () {
    NSTimer* mSendVerifyTimer;
    NSInteger mnWaitTime;
}

@property (weak, nonatomic) IBOutlet UITextField *mTxtPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPassword;
@property (weak, nonatomic) IBOutlet UITextField *mTxtVerifyCode;

@property (weak, nonatomic) IBOutlet UIButton *mButSignup;
@property (weak, nonatomic) IBOutlet UIButton *mButVerifyCode;
@property (weak, nonatomic) IBOutlet UILabel *mLblVerifyCode;

@end

@implementation SignupViewController

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
    
    [self.mButSignup.layer setMasksToBounds:YES];
    [self.mButSignup.layer setCornerRadius:10];
    
    [self.mButVerifyCode.layer setMasksToBounds:YES];
    [self.mButVerifyCode.layer setCornerRadius:3];
    
    [self.mLblVerifyCode.layer setMasksToBounds:YES];
    [self.mLblVerifyCode.layer setCornerRadius:3];
    
    [self showVerifyCodeBut:YES];
    
    UIColor *colorWhite = [UIColor whiteColor];
    if ([self.mTxtPhoneNumber respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtPhoneNumber.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
    
    if ([self.mTxtPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
    
    if ([self.mTxtVerifyCode respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtVerifyCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButSignup:(id)sender {
    
    if ([self.mTxtPhoneNumber.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入您的手机号码"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([self.mTxtPassword.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入您的密码"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self.mTxtVerifyCode.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入验证吗"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
//    [AVOSCloud verifySmsCode:self.mTxtVerifyCode.text mobilePhoneNumber:self.mTxtPhoneNumber.text callback:^(BOOL succeeded, NSError *error) {
//    
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        
//        if (succeeded) {
    
            UserData *user = [UserData user];
            user.username = self.mTxtPhoneNumber.text;
            user.password = self.mTxtPassword.text;
            user.mobilePhoneNumber = self.mTxtPhoneNumber.text;
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];

                if (succeeded) {
                    CommonUtils *utils = [CommonUtils sharedObject];
                    if (utils.mLocationCurrent) {
                        user.location = [AVGeoPoint geoPointWithLatitude:utils.mLocationCurrent.coordinate.latitude
                                                               longitude:utils.mLocationCurrent.coordinate.longitude];
                        [user saveInBackground];
                    }
                    
                    AVInstallation *installation = [AVInstallation currentInstallation];
                    if (installation) {
                        installation[@"user"] = [UserData currentUser];
                        [installation saveInBackground];
                    }
                    
                    [self performSegueWithIdentifier:@"Signup2EditProfile" sender:nil];
                }
                else {
                    NSString *strMsg = error.localizedDescription;
                    
                    if (error.code == 214) {
                        strMsg = @"此手机号已经被注册";
                    }
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:strMsg
                                                                    message:@""
                                                                   delegate:nil cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }];

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        }
//        else {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
//                                                            message:error.localizedDescription
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        }
//    }];
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Signup2Policy"]) {
//        PolicyViewController *viewController = [segue destinationViewController];
//        viewController.mnType = CONTENT_POLICY;
    }
    else if ([[segue identifier] isEqualToString:@"Signup2EditProfile"]) {
        EditProfileViewController *viewController = [segue destinationViewController];
        viewController.mbFromSignup = YES;
    }
}


#pragma mark -
- (void)showVerifyCodeBut:(BOOL)bShow {
    [self.mLblVerifyCode setHidden:bShow];
    [self.mButVerifyCode setHidden:!bShow];
}

- (IBAction)onButVerifyCode:(id)sender {
    
    if ([self.mTxtPhoneNumber.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入您的手机号"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [AVOSCloud requestSmsCodeWithPhoneNumber:self.mTxtPhoneNumber.text
                                     appName:@"Funner"
                                   operation:@"注册"
                                  timeToLive:30
                                    callback:^(BOOL succeeded, NSError *error) {
                                        if (!succeeded) {
                                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                            message:error.localizedDescription
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil];
                                            [alert show];
                                        }
                                        else {
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
                                    }];
}

- (IBAction)onButPolicy:(id)sender {
    [self performSegueWithIdentifier:@"Signup2Policy" sender:nil];
}

- (void) waitThread:(NSTimer*)theTimer {

    if (mnWaitTime > 0) {
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

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mTxtPhoneNumber) {
		[self.mTxtPassword becomeFirstResponder];
	}
	else if (textField == self.mTxtPassword) {
		[self.mTxtVerifyCode becomeFirstResponder];
	}
    else if (textField == self.mTxtVerifyCode) {
        [textField resignFirstResponder];
    }
    
	return YES;
}


@end
