//
//  NewFriendViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "NewFriendViewController.h"
#import "UserData.h"
#import "NewFriendTableViewCell.h"
#import "FriendData.h"
#import "CommonUtils.h"

@interface NewFriendViewController () {
    UIRefreshControl *mRefreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation NewFriendViewController

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
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl setTintColor:[UIColor whiteColor]];
    [mRefreshControl addTarget:self action:@selector(getNewReceived:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:mRefreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getNewReceived:(UIRefreshControl *)sender {
    UserData *currentUser = [UserData currentUser];
    
    AVQuery *query = [FriendData query];
    [query whereKey:@"userto" equalTo:currentUser];
    [query whereKey:@"accepted" equalTo:[NSNumber numberWithBool:NO]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendobjects, NSError *error) {
        
        [mRefreshControl endRefreshing];
        
        if (!error) {
            for (FriendData *fData in friendobjects) {
                // check if it is already existing
                BOOL bExist = NO;
                UserData *uData = fData.userfrom;
                for (UserData *utData in currentUser.maryFriend) {
                    if (utData.mnRelation == USERRELATION_FRIEND_RECEIVED &&
                        [utData.objectId isEqualToString:uData.objectId]) {
                        bExist = YES;
                        break;
                    }
                }
                
                if (!bExist) {
                    uData.mnRelation = USERRELATION_FRIEND_RECEIVED;
                    [currentUser.maryFriend addObject:uData];
                }
            }
            
            [self.mTableView reloadData];
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
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

- (NSInteger)getNewFriendCount {
    UserData *currentUser = [UserData currentUser];
    NSInteger nCount = 0;
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation == USERRELATION_FRIEND ||
            uData.mnRelation == USERRELATION_FRIEND_RECEIVED) {
            
            if (uData.mnRelation == USERRELATION_FRIEND_RECEIVED &&
                ![uData.mFriendData.isread boolValue])
            {
                uData.mFriendData.isread = [NSNumber numberWithBool:YES];
                [uData.mFriendData saveInBackground];
            }
            
            if ([uData.mFriendData.mode intValue] == FRIEND_CONTACT) {
                continue;
            }
        
            nCount++;
        }
    }
    
    return nCount;
}

- (UserData *)getNewFriendWithIndex:(NSInteger)nIndex {
    UserData *currentUser = [UserData currentUser];
    NSInteger nCount = 0;
    UserData *uDataRes;
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation == USERRELATION_FRIEND ||
            uData.mnRelation == USERRELATION_FRIEND_RECEIVED) {
            
            if ([uData.mFriendData.mode intValue] == FRIEND_CONTACT) {
                continue;
            }
            
            if (nCount == nIndex) {
                uDataRes = uData;
                break;
            }
            nCount++;
        }
    }
    
    return uDataRes;
}



#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getNewFriendCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewFriendTableViewCell *cell = (NewFriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NewFriendCellID"];
    UserData *uData = [self getNewFriendWithIndex:indexPath.row];
    [cell fillContent:uData];
    
    //
    // button
    //
    if (uData.mnRelation == USERRELATION_FRIEND) {
        [cell.mButAccept setHidden:YES];
    }
    else if (uData.mnRelation == USERRELATION_FRIEND_RECEIVED) {
        [cell.mButAccept setHidden:NO];
    }
    [cell.mButAccept addTarget:self action:@selector(onButAccept:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)onButAccept:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.mTableView];
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    UserData *uData = [self getNewFriendWithIndex:indexPath.row];
    FriendData *fData = uData.mFriendData;
    
    fData.accepted = [NSNumber numberWithBool:YES];
    [fData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            uData.mnRelation = USERRELATION_FRIEND;
            [self.mTableView reloadData];
        }
    }];
    
//    UserData *currentUser = [UserData currentUser];
////    [currentUser addObject:uData forKey:@"friend"];
////    [currentUser saveInBackground];
//    
//    [AVCloud callFunctionInBackground:@"addMeAsFriendToUser" withParameters:@{@"userId":uData.objectId} block:^(id object, NSError *error) {
//        NSLog(@"%@", [error description]);
//    }];
//    
////    [uData addObject:currentUser forKey:@"friend"];
////    [uData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
////        
////    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
