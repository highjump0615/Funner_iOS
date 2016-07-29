//
//  EditNameViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "EditNameViewController.h"
#import "UserData.h"
#import "BlogData.h"
#import "NotificationData.h"

@interface EditNameViewController ()

@property (weak, nonatomic) IBOutlet UIButton *mButOk;
@property (weak, nonatomic) IBOutlet UITextField *mTxtNickname;

@end

@implementation EditNameViewController

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
    
    // get current nickname
    UserData *currentUser = [UserData currentUser];
    [self.mTxtNickname setText:currentUser.nickname];
    
    UIColor *colorWhite = [UIColor whiteColor];
    if ([self.mTxtNickname respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.mTxtNickname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入昵称" attributes:@{NSForegroundColorAttributeName:colorWhite}];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButOk:(id)sender {
    UserData *currentUser = [UserData currentUser];
    
    // update name in zapp, like, comments if changed
    if (![currentUser.nickname isEqualToString:self.mTxtNickname.text])
    {
        currentUser.nickname = self.mTxtNickname.text;
        
        // blogs
        AVQuery *query = [BlogData query];
        [query whereKey:@"user" equalTo:currentUser];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 for (BlogData *object in objects)
                 {
                     object.username = self.mTxtNickname.text;
                     [object saveInBackground];
                 }
             }
             else
             {
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
        
        // notification
        query = [NotificationData query];
        [query whereKey:@"user" equalTo:currentUser];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 for (NotificationData *object in objects)
                 {
                     object.username = self.mTxtNickname.text;
                     [object saveInBackground];
                 }
             }
             else
             {
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
        
        [currentUser saveInBackground];
    }
    
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
