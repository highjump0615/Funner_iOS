//
//  EditAboutMeViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "EditAboutMeViewController.h"
#import "PlaceholderTextView.h"
#import "UserData.h"
#import "CommonUtils.h"

@interface EditAboutMeViewController ()

@property (weak, nonatomic) IBOutlet PlaceholderTextView *mTextView;
@property (weak, nonatomic) IBOutlet UIButton *mButOk;


@end

@implementation EditAboutMeViewController

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
    
    [self.mTextView setPlaceholder:@"输入内容"];
    
    [self.mButOk.layer setMasksToBounds:YES];
    [self.mButOk.layer setCornerRadius:10];
    
    // get current nickname
    UserData *currentUser = [UserData currentUser];
    [self.mTextView setText:currentUser.about];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButOk:(id)sender {
    UserData *currentUser = [UserData currentUser];
    currentUser.about = self.mTextView.text;
    
    [currentUser saveInBackground];
    
    [[self navigationController] popViewControllerAnimated:YES];
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

@end
