//
//  FriendViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "FriendViewController.h"

#import "MeViewController.h"
#import "CommonUtils.h"
#import "UserData.h"
#import "FriendTableViewCell.h"
#import "FriendData.h"

#import "BATableView.h"
#import "NoticeView.h"

@interface FriendViewController () <BATableViewDelegate, FriendCellDelegate> {
    NSMutableArray *maryFriendDic;
    UserData *mUserSelected;
    UIRefreshControl *mRefreshControl;
    
    BOOL mbBATReady;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet BATableView *mBaTableView;

@property (weak, nonatomic) IBOutlet NoticeView *mViewNotice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintNoticeTop;

@end

@implementation FriendViewController

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
    
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl setTintColor:[UIColor whiteColor]];
    [mRefreshControl addTarget:self action:@selector(getFriendInfo:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:mRefreshControl];
    
    UserData *currentUser = [UserData currentUser];
    [currentUser checkDuplicate];
    
//    [self getFriendInfo:nil];
    
    maryFriendDic = [[NSMutableArray alloc] init];
    mbBATReady = NO;
    
    [self.mViewNotice setAlpha:0];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (mbBATReady) {
        return;
    }
    
    self.mBaTableView.tableView = self.mTableView;
    self.mBaTableView.delegate = self;
    [self.mBaTableView prepare];

    mbBATReady = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self fillData];
    
    [self.mBaTableView reloadData];
    [self.mBaTableView reloadInputViews];
}

- (void)fillData {
    [maryFriendDic removeAllObjects];
    
    [maryFriendDic addObject:@{@"indexTitle": @"↑", @"data":@[]}];
    
    UserData *currentUser = [UserData currentUser];
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation == USERRELATION_FRIEND) {
            [self addToIndexDictionary:maryFriendDic text:uData];
        }
    }
}

- (void)addToIndexDictionary:(NSMutableArray *)aryDict text:(UserData *)user {
    
    NSMutableString *strPinyin = [[user getUsernameToShow] mutableCopy];
    
    CFStringTransform((__bridge CFMutableStringRef)strPinyin, 0, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)strPinyin, 0, kCFStringTransformStripDiacritics, NO);
    
    NSString *strIndex = [[strPinyin substringToIndex:1] uppercaseString];
    
    NSMutableDictionary *dictFriend;
    int i;
    
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([strIndex rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        // check whether # group is existing
        for (i = 0; i < [aryDict count]; i++) {
            dictFriend = [aryDict objectAtIndex:i];
            if ([dictFriend[@"indexTitle"] isEqualToString:@"#"]) {
//                [dictFriend[@"data"] addObject:user];
                break;
            }
        }
        
        if (i >= [aryDict count]) {
            dictFriend = [[NSMutableDictionary alloc] init];
            dictFriend[@"indexTitle"] = @"#";
            dictFriend[@"data"] = [[NSMutableArray alloc] init];
//            [dictFriend[@"data"] addObject:user];
            
            [aryDict insertObject:dictFriend atIndex:1];
        }
    }
    else {
        for (i = 0; i < [aryDict count]; i++) {
            dictFriend = [aryDict objectAtIndex:i];
            if ([dictFriend[@"indexTitle"] isEqualToString:strIndex]) {
                break;
            }
        }
        
        if (i >= [aryDict count]) {
            dictFriend = [[NSMutableDictionary alloc] init];
            dictFriend[@"indexTitle"] = strIndex;
            dictFriend[@"data"] = [[NSMutableArray alloc] init];
            
            // add with sorting
            NSInteger nLocation = 0;
            for (nLocation = 1; nLocation < [aryDict count]; nLocation++) {
                NSDictionary *dictTmp = [aryDict objectAtIndex:nLocation];
                NSString *strIndex = dictTmp[@"indexTitle"];
                NSString *strIndexToAdd = dictFriend[@"indexTitle"];
                
                if ([strIndex compare:strIndexToAdd] == NSOrderedDescending) {
                    break;
                }
            }
            [aryDict insertObject:dictFriend atIndex:nLocation];
        }
    }
    
    if (dictFriend) {
        // add with sorting
        NSInteger nLocation = 0;
        NSMutableArray *arydictFriend = dictFriend[@"data"];
        
        for (nLocation = 0; nLocation < [arydictFriend count]; nLocation++) {
            UserData *userTmp = [arydictFriend objectAtIndex:nLocation];
            NSString *strName = [userTmp getUsernameToShow];
            NSString *strNameToAdd = [user getUsernameToShow];
            
            if ([strName compare:strNameToAdd] == NSOrderedDescending) {
                break;
            }
        }
        
        [arydictFriend insertObject:user atIndex:nLocation];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFriendInfo:(UIRefreshControl *)sender {
    CommonUtils *utils = [CommonUtils sharedObject];
    UserData *currentUser = [UserData currentUser];
    
    [utils getContactInfoWithSucess:^{
        [self updateTable];
    }];
    
    [currentUser getNearUserWithSuccess:^{
        [self updateTable];
    }];
}

- (void)updateTable {
    CommonUtils *utils = [CommonUtils sharedObject];
    UserData *currentUser = [UserData currentUser];
    
    if (!utils.mbContactReady || !currentUser.mbGotNear) {
        return;
    }

    [self fillData];
    
    if ([mRefreshControl isRefreshing]) {
        [mRefreshControl endRefreshing];
    }
    
    [currentUser checkDuplicate];
    [self.mBaTableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Friend2Me"]) {
        MeViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
    }
    
}



#pragma mark - UITableViewDataSource

- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    NSMutableArray * indexTitles = [NSMutableArray array];
    for (NSDictionary * sectionDictionary in maryFriendDic) {
        [indexTitles addObject:sectionDictionary[@"indexTitle"]];
    }
    return indexTitles;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return maryFriendDic.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger nCount = 0;
    
    if (section > 0) {
        nCount = [maryFriendDic[section][@"data"] count];
    }
    else {
        nCount = 2;
    }
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section > 0) {
        FriendTableViewCell *friendCell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCellID"];
        NSDictionary *dict = [maryFriendDic objectAtIndex:indexPath.section];
        UserData *uData = [dict[@"data"] objectAtIndex:indexPath.row];
        
        [friendCell fillContent:uData];
        [friendCell setDelegate:self];
        
        cell = friendCell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FriendMenuCellID1"];
        
        UIImageView *imgMenu = (UIImageView *)[cell viewWithTag:101];
        UILabel *lblTitle = (UILabel *)[cell viewWithTag:102];
        UIView *viewRedDot = (UIView *)[cell viewWithTag:103];
        UILabel *lblDesc = (UILabel *)[cell viewWithTag:104];
        
        double dRadius = viewRedDot.frame.size.height / 2;
        [viewRedDot.layer setMasksToBounds:YES];
        [viewRedDot.layer setCornerRadius:dRadius];
        [viewRedDot setHidden:YES];
        
        switch (indexPath.row) {
            case 0:
                [imgMenu setImage:[UIImage imageNamed:@"friend_invite.png"]];
                [lblTitle setText:@"邀请"];
                [lblDesc setText:@"微信/QQ/通讯录中的朋友"];
                break;
                
            case 1: {
                [imgMenu setImage:[UIImage imageNamed:@"friend_new.png"]];
                [lblTitle setText:@"新的朋友"];
                [lblDesc setText:@"请求添加朋友的验证通知"];

                // checking new friend request
                BOOL bNew = NO;
                UserData *currentUser = [UserData currentUser];
                for (UserData *uData in currentUser.maryFriend) {
                    if (uData.mnRelation != USERRELATION_FRIEND_RECEIVED) {
                        continue;
                    }
                    
                    if (![uData.mFriendData.isread boolValue]) {
                        bNew = YES;
                        break;
                    }
                }
                
                if (bNew) {
                    [viewRedDot setHidden:NO];
                }
                
                break;
            }
                
//            case 2:
//                [imgMenu setImage:[UIImage imageNamed:@"friend_friend.png"]];
//                [lblTitle setText:@"朋友的朋友"];
//                break;
//                
//            case 3:
//                [imgMenu setImage:[UIImage imageNamed:@"friend_near.png"]];
//                [lblTitle setText:@"附近的人"];
//                break;
                
            default:
                break;
        }
    }

    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Remove seperator inset
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        UIEdgeInsets edgeInset = UIEdgeInsetsZero;
//        edgeInset.left = 54;
//        [cell setSeparatorInset:edgeInset];
//    }
//    
//    // Prevent the cell from inheriting the Table View's margin settings
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//    
//    // Explictly set your cell's layout margins
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        /* Create custom view to display section header... */
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, -2, tableView.frame.size.width, 18)];
        [label setFont:[UIFont systemFontOfSize:11]];
        [label setText:maryFriendDic[section][@"indexTitle"]];
        [label setTextColor:[UIColor whiteColor]];
        
        [view addSubview:label];
        
        return view;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section > 0) {
//        return 60;
//    }
//    else {
//        return 44;
//    }
    
    return 61;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    int nHeight = 0;
    
    if (section > 0) {
        nHeight = 15;
    }
    
    return nHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (indexPath.section > 0) {
        NSDictionary *dict = [maryFriendDic objectAtIndex:indexPath.section];
        mUserSelected = [dict[@"data"] objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:@"Friend2Me" sender:nil];
	}
    else {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"Friend2Invite" sender:nil];
                break;
                
            case 1:
                [self performSegueWithIdentifier:@"Friend2NewFriend" sender:nil];
                break;
                
            case 2:
                [self performSegueWithIdentifier:@"Friend2TwoFriend" sender:nil];
                break;
                
            case 3:
                [self performSegueWithIdentifier:@"Friend2Near" sender:nil];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - notice

- (void)showNotice {
    CGFloat fContsraint = -7;
    
    // show notice
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.mConstraintNoticeTop setConstant:fContsraint + self.mViewNotice.frame.size.height];
                         [self.mViewNotice setAlpha:1];
                         [self.view layoutIfNeeded];
                         
                     }completion:^(BOOL finished) {
                         [self performSelector:@selector(hideNotice) withObject:nil afterDelay:2.0];
                     }];
}

- (void)hideNotice {
    CGFloat fContsraint = -7;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.mConstraintNoticeTop setConstant:fContsraint];
                         [self.mViewNotice setAlpha:0];
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL finished) {
                     }];
}


#pragma mark - FriendCellDelegate

- (void)onShieldResult:(BOOL)bResult user:(UserData *)uData {
    
    NSString *strMsg = @"";
    
    if (bResult) {
        strMsg = [NSString stringWithFormat:@"已取消%@的屏蔽", [uData getUsernameToShow]];
    }
    else {
        strMsg = [NSString stringWithFormat:@"%@发布的内容已被过滤", [uData getUsernameToShow]];
    }
    
    [self.mViewNotice setMessage:strMsg];
    [self showNotice];
}



@end
