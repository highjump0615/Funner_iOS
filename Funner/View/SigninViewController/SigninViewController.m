//
//  SigninViewController.m
//  Funner
//
//  Created by highjump on 14-11-7.
//
//

#import "SigninViewController.h"
#import "CommonUtils.h"
#import "SignupViewController.h"

#import "MBProgressHUD.h"
#import "UserData.h"
#import "MainTabbarController.h"
#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>


@interface SigninViewController ()

@property (weak, nonatomic) IBOutlet UIButton *mButSignin;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPassword;

@end

@implementation SigninViewController

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
    
    [self.mButSignin.layer setMasksToBounds:YES];
    [self.mButSignin.layer setCornerRadius:10];
    
    UIColor *colorWhite = [UIColor whiteColor];
    if ([self.mTxtPhoneNumber respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtPhoneNumber.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
    
    if ([self.mTxtPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButSignin:(id)sender {
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
    
    [UserData logInWithUsernameInBackground:self.mTxtPhoneNumber.text password:self.mTxtPassword.text block:^(AVUser *user, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (user) {
            UserData *currentUser = [UserData currentUser];
            
            CommonUtils *utils = [CommonUtils sharedObject];
            if (utils.mLocationCurrent) {
                currentUser.location = [AVGeoPoint geoPointWithLatitude:utils.mLocationCurrent.coordinate.latitude
                                                              longitude:utils.mLocationCurrent.coordinate.longitude];
                [user saveInBackground];
            }
            
            // Associate the device with a user
            AVInstallation *installation = [AVInstallation currentInstallation];
            if (installation) {
                installation[@"user"] = currentUser;
                [installation saveInBackground];
            }
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate setRootView];
        }
        else {
            NSString *strMsg = error.localizedDescription;
            
            if (error.code == kAVErrorUserNotFound) {
                strMsg = @"找不到该用户";
            }
            else if (error.code == kAVErrorUsernamePasswordMismatch) {
                strMsg = @"用户名和密码不匹配";
            }
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:strMsg
                                                            message:@""
                                                           delegate:nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }

    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Signin2Signup"]) {
    }
//    else if ([[segue identifier] isEqualToString:@"Signin2Main"]) {
//        [self.navigationController setViewControllers:[[NSArray alloc] init]];
//    }
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mTxtPhoneNumber) {
		[self.mTxtPassword becomeFirstResponder];
	}
	else if (textField == self.mTxtPassword) {
		[textField resignFirstResponder];
	}
    
	return YES;
}


@end
