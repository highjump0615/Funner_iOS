//
//  EditPasswordViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "EditPasswordViewController.h"
#import "MBProgressHUD.h"
#import "UserData.h"

@interface EditPasswordViewController ()

@property (weak, nonatomic) IBOutlet UIButton *mButOk;

@property (weak, nonatomic) IBOutlet UITextField *mTxtOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *mTxtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *mTxtConfirmPassword;

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewWarning;
@property (weak, nonatomic) IBOutlet UILabel *mLblWarning;

@end

@implementation EditPasswordViewController

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
    
    UIColor *colorWhite = [UIColor whiteColor];
    if ([self.mTxtOldPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtOldPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"旧密码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
    if ([self.mTxtNewPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtNewPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"新密码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
    if ([self.mTxtConfirmPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtConfirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"再次输入新密码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButOk:(id)sender {
    NSString* strOldPass = self.mTxtOldPassword.text;
    NSString* strNewPass = self.mTxtNewPassword.text;
    NSString* strRetypePass = self.mTxtConfirmPassword.text;
    
    if(strOldPass.length == 0 || strNewPass.length == 0 || strRetypePass.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入密码"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if([strNewPass isEqualToString:strRetypePass] == NO) {
        [self.mImgViewWarning setHidden:NO];
        [self.mLblWarning setHidden:NO];
        return;
    }
    
    [self.mImgViewWarning setHidden:YES];
    [self.mLblWarning setHidden:YES];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UserData *currentUser = [UserData currentUser];
    
    [UserData logInWithUsernameInBackground:currentUser.username password:strOldPass block:^(AVUser *user, NSError *error) {
        if (user) {
            currentUser.password = strNewPass;
            [currentUser saveInBackground];

            [[self navigationController] popViewControllerAnimated:YES];
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"旧密码输入错误"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
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


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.mTxtOldPassword) {
		[self.mTxtNewPassword becomeFirstResponder];
	}
	else if (textField == self.mTxtNewPassword) {
		[self.mTxtConfirmPassword becomeFirstResponder];
	}
    else if (textField == self.mTxtConfirmPassword) {
        [textField resignFirstResponder];
    }
    
	return YES;
}


@end
