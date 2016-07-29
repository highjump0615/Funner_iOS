//
//  ForgetViewController.m
//  Funner
//
//  Created by highjump on 14-11-7.
//
//

#import "ForgetViewController.h"
#import "ResetViewController.h"

#import "UserData.h"

@interface ForgetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mTxtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *mButNext;

@end

@implementation ForgetViewController

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
    
    [self.mButNext.layer setMasksToBounds:YES];
    [self.mButNext.layer setCornerRadius:10];
    
    UIColor *colorWhite = [UIColor whiteColor];
    if ([self.mTxtPhoneNumber respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtPhoneNumber.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入手机号码" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Forget2Reset"]) {
        ResetViewController *viewController = [segue destinationViewController];
        viewController.mstrPhoneNumber = self.mTxtPhoneNumber.text;
    }
}



- (IBAction)onButNext:(id)sender {
    if ([self.mTxtPhoneNumber.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"请输入您的手机号"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [UserData requestPasswordResetWithPhoneNumber:self.mTxtPhoneNumber.text block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self performSegueWithIdentifier:@"Forget2Reset" sender:nil];
        }
        else {
            NSString *strMsg = error.localizedDescription;
            
            if (error.code == 213) {
                strMsg = @"指定手机号码的用户不存在";
            }
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:strMsg
                                                            message:@""
                                                           delegate:nil cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}


@end
