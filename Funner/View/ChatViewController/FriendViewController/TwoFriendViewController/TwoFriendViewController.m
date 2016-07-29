//
//  TwoFriendViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "TwoFriendViewController.h"
#import "UserData.h"
#import "TwoFriendTableViewCell.h"
#import "MeViewController.h"

@interface TwoFriendViewController () {
    NSMutableArray *maryTwoFriend;
    UserData *mUserSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation TwoFriendViewController

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
    
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    maryTwoFriend = [[NSMutableArray alloc] init];
    
    UserData *currentUser = [UserData currentUser];
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation == USERRELATION_FRIEND) {
            for (UserData *usecData in uData.maryFriend) {
                if (usecData.mnRelation == USERRELATION_FRIEND) {
                    BOOL bExist = NO;
                    
                    // if he is my friend, skip it
                    for (UserData *utData in currentUser.maryFriend) {
                        if ([usecData.objectId isEqualToString:utData.objectId] &&
                            utData.mnRelation == USERRELATION_FRIEND) {
                            bExist = YES;
                            break;
                        }
                    }
                    
                    if (bExist) {
                        continue;
                    }
                    
                    // check it is already existing
                    bExist = NO;
                    
                    for (UserData *utwoData in maryTwoFriend) {
                        if ([utwoData.objectId isEqualToString:usecData.objectId]) {
                            bExist = YES;
                            break;
                        }
                    }
                    
                    if (bExist) {
                        continue;
                    }
                    
                    [maryTwoFriend addObject:usecData];
                }
            }
        }
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
    
    if ([[segue identifier] isEqualToString:@"TwoFriend2Me"]) {
        MeViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
    }
}



#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [maryTwoFriend count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TwoFriendTableViewCell *cell = (TwoFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TwoFriendCellID"];
    
    UserData *uData = [maryTwoFriend objectAtIndex:indexPath.row];
    [cell fillContent:uData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    mUserSelected = [maryTwoFriend objectAtIndex:indexPath.row];
    if ([mUserSelected.objectId isEqualToString:[UserData currentUser].objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"TwoFriend2Me" sender:nil];
}

@end
