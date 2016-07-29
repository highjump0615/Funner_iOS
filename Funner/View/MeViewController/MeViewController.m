//
//  MeViewController.m
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import "MeViewController.h"
#import "CategoryCellView.h"

#import "CommonUtils.h"
#import "CustomActionSheetView.h"

#import "BlogData.h"
#import "CategoryData.h"
#import "NotificationData.h"
#import "UserData.h"
#import "FriendData.h"

#import "DetailViewController.h"
#import "HobbyViewController.h"
#import "EditProfileViewController.h"
#import "MessageViewController.h"


#import "FriendTableViewCell.h"
#import "ProfileInfoCell.h"
#import "ProfileBlogCell.h"
#import "ProfileBlogGridCell.h"

#import "UIImageView+WebCache.h"

#define kGridTab            0
#define kListTab            1
#define kFavouriteTab       2
#define kFriendTab          3

#define MAX_SHOW_BLOG_NUM   4


@interface MeViewController () <CustomActionSheetDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSInteger mnSelectedTab;
    
    CustomActionSheetView *mActionsheetView;
    
    NSMutableArray *maryBlog;
    NSArray *maryCategory;
    
    BlogData *mBlogSelected;
    UserData *mUserSelected;
    CategoryData *mCategorySelected;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation MeViewController

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
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    
    mnSelectedTab = 0;
    
    UIEdgeInsets edgeTable = self.mTableView.contentInset;
    edgeTable.top = 64;
    
    if (self.mUser) {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"me_other.png"]];
        
        [self.mUser setBlockUser];
        
        UserData *currentUser = [UserData currentUser];
        NSString *strTitle1 = @"不看他发布的内容";
        NSString *strTitle2 = @"不让他看我发布的内容";
        
        if ([currentUser isBlockUserToMe:self.mUser]) {
            strTitle1 = @"看他发布的内容";
        }
        if ([self.mUser isBlockUserToMe:currentUser]) {
            strTitle2 = @"让他看我发布的内容";
        }
        
        mActionsheetView = (CustomActionSheetView *)[CustomActionSheetView initView:self.view
                                                                       ButtonTitle1:@""
                                                                       ButtonTitle2:strTitle2
                                                                       ButtonTitle3:@"举报该用户"
                                                                     removeOnCancel:NO];
        mActionsheetView.delegate = self;
        
        edgeTable.bottom = 0;
    }
    else {
        self.mUser = [UserData currentUser];
        
        CommonUtils *utils = [CommonUtils sharedObject];
        edgeTable.bottom = utils.mTabbarController.tabBar.frame.size.height;
    }
    
    self.mTableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    [self.mTableView setContentInset:edgeTable];
    
    // init data
    maryBlog = [[NSMutableArray alloc] init];

    // get friend
    if (!self.mUser.mbGotFriend) {
        [self.mUser getFriendWithSuccess:^{
            [self.mTableView reloadData];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {

    if (self.mUser.createdAt) { // fetched
        [self.navigationItem setTitle:[self.mUser getUsernameToShow]];
        [self.mTableView reloadData];
    }
    
    UserData *currentUser = [UserData currentUser];
    
    //
    // get blog data
    //
    AVQuery *query = [BlogData query];
    [query whereKey:@"user" equalTo:self.mUser];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [maryBlog removeAllObjects];
            
            for (BlogData *bData in objects) {
                [bData fillData];
                bData.user = [currentUser getRelatedUserData:bData.user friendOnly:NO];
                
                [maryBlog addObject:bData];
            }
            
            // title
            maryCategory = [NSArray arrayWithArray:[self getCategory]];
            
            [self.mTableView reloadData];
        }
    }];
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
    if ([[segue identifier] isEqualToString:@"Me2Detail"]) {
        DetailViewController *viewController =  [segue destinationViewController];
        viewController.mBlogData = mBlogSelected;
        viewController.mnCommentType = NOTIFICATION_COMMENT;
    }
    else if ([[segue identifier] isEqualToString:@"Me2Hobby"]) {
        HobbyViewController *viewController =  [segue destinationViewController];
        viewController.mCategory = mCategorySelected;
        viewController.mUser = self.mUser;
    }
    else if ([[segue identifier] isEqualToString:@"Me2EditProfile"]) {
        EditProfileViewController *viewController = [segue destinationViewController];
        viewController.mbFromSignup = NO;
    }
    else if ([[segue identifier] isEqualToString:@"Me2Message"]) {
        MessageViewController *viewController = [segue destinationViewController];
        viewController.mUser = self.mUser;
    }
}


- (void)onButGrid:(id)sender {
    mnSelectedTab = kGridTab;
    [self.mTableView reloadData];
}

- (IBAction)onButOther:(id)sender {
    UserData *currentUser = [UserData currentUser];
    
    if ([self.mUser.objectId isEqualToString:currentUser.objectId]) {
        [self performSegueWithIdentifier:@"Me2Setting" sender:nil];
    }

    [mActionsheetView showView];
}


- (void)onButList:(id)sender {
    mnSelectedTab = kListTab;
    [self.mTableView reloadData];
}

- (void)onButFavourite:(id)sender {
    mnSelectedTab = kFavouriteTab;
    [self.mTableView reloadData];
}

- (void)onButFriend:(id)sender {
    mnSelectedTab = kFriendTab;
    [self.mTableView reloadData];
}

- (void)onButEdit:(id)sender {
    UserData *currentUser = [UserData currentUser];
    
    if ([self.mUser isEqual:currentUser]) {
        [self performSegueWithIdentifier:@"Me2EditProfile" sender:nil];
    }
    else {
        if (self.mUser.mnRelation == USERRELATION_FRIEND &&
            [self.mUser.mUserParent.objectId isEqualToString:currentUser.objectId]) {
            
            // send chat
            [self performSegueWithIdentifier:@"Me2Message" sender:nil];
        }
        else {
            for (UserData *uData in currentUser.maryFriend) {
                if (uData.mnRelation == USERRELATION_FRIEND_RECEIVED ||
                    uData.mnRelation == USERRELATION_FRIEND_SENT) {
                    
                    if ([uData.objectId isEqualToString:self.mUser.objectId]) {
                        NSString *strMsg = @"您已经发了朋友请求";
                        
                        if (uData.mnRelation == USERRELATION_FRIEND_RECEIVED) {
                            strMsg = @"您已经收到他的朋友请求";
                        }
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strMsg
                                                                            message:@""
                                                                           delegate:self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"OK", nil];
                        [alertView show];
                        
                        return;
                    }
                }
            }
            
            
            // check whether already existing or not
            AVQuery *queryFrom = [FriendData query];
            [queryFrom whereKey:@"userfrom" equalTo:currentUser];
            [queryFrom whereKey:@"userto" equalTo:self.mUser];
            
            AVQuery *queryTo = [FriendData query];
            [queryTo whereKey:@"userfrom" equalTo:self.mUser];
            [queryTo whereKey:@"userto" equalTo:currentUser];
            
            AVQuery *queryFriend = [AVQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryFrom, queryTo, nil]];
            [queryFriend findObjectsInBackgroundWithBlock:^(NSArray *friendobjects, NSError *error) {
                if (!error) {
                    for (FriendData *fData in friendobjects) {
                        NSString *strMsg = @"";
                        
                        self.mUser.mFriendData = fData;
                        
                        if ([fData.accepted boolValue]) {
                            strMsg = @"您已经成为他的朋友了";
                            self.mUser.mnRelation = USERRELATION_FRIEND;
                        }
                        else {
                            if ([fData.userfrom.objectId isEqualToString:currentUser.objectId]) {
                                strMsg = @"您已经发了朋友请求";
                                self.mUser.mnRelation = USERRELATION_FRIEND_SENT;
                            }
                            else {
                                strMsg = @"您已经收到他的朋友请求";
                                self.mUser.mnRelation = USERRELATION_FRIEND_RECEIVED;
                            }
                        }
                        
                        [currentUser.maryFriend addObject:self.mUser];
                        [self.mUser getLatestMessage];
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strMsg
                                                                            message:@""
                                                                           delegate:self
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"OK", nil];
                        [alertView show];
                    }
                    
                    if ([friendobjects count] == 0) {
                        [self sendFriendRequest];
                    }
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                        message:[error localizedDescription]
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                    [alertView show];
                }
            }];
        }
    }
}

- (void)sendFriendRequest {
    UserData *currentUser = [UserData currentUser];
    FriendData *friendObj = [FriendData object];
    friendObj.userfrom = currentUser;
    friendObj.userto = self.mUser;
    friendObj.isread = [NSNumber numberWithBool:NO];
    
    [friendObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // add to friend list of the current user
            self.mUser.mFriendData = friendObj;
            self.mUser.mnRelation = USERRELATION_FRIEND_SENT;
            [currentUser.maryFriend addObject:self.mUser];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发送请求成功"
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发送请求失败"
                                                                message:@""
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }];
}

- (NSInteger)getFriendCount {
    // get friend count
    NSInteger nCount = 0;
    for (UserData *uData in self.mUser.maryFriend) {
        if (uData.mnRelation != USERRELATION_FRIEND) {
            continue;
        }
        
        BOOL bCommon = NO;
        
        // check this friend has at least one common category
        for (CategoryData *cData in uData.maryCategory) {
            for (CategoryData *ctData in self.mUser.maryCategory) {
                if ([cData.objectId isEqualToString:ctData.objectId]) {
                    bCommon = YES;
                    break;
                }
            }
            
            if (bCommon) {
                break;
            }
        }
        
        if (bCommon) {
            nCount++;
        }
    }
    
    return nCount;
}

- (UserData *)getFriendWithIndex:(NSInteger)nIndex {
    // get friend count
    NSInteger nCount = 0;
    UserData *uDataRes;
    for (UserData *uData in self.mUser.maryFriend) {
        if (uData.mnRelation != USERRELATION_FRIEND) {
            continue;
        }
        
        BOOL bCommon = NO;
        
        // check this friend has at least one common category
        for (CategoryData *cData in uData.maryCategory) {
            for (CategoryData *ctData in self.mUser.maryCategory) {
                if ([cData.objectId isEqualToString:ctData.objectId]) {
                    bCommon = YES;
                    break;
                }
            }
            
            if (bCommon) {
                break;
            }
        }
        
        if (bCommon) {
            if (nCount == nIndex) {
                uDataRes = uData;
                break;
            }
            nCount++;
        }
    }
    
    return uDataRes;
}


#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.mTableView) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger nCount = 0;
    
    if (tableView == self.mTableView) {
        switch (section) {
            case 0:
                nCount = 1;
                break;
                
            case 1:
    //            if (mnSelectedTab == kGridTab) {
    //                nCount = ceil([maryBlog count] / 3.0);
    //            }
    //            else if (mnSelectedTab == kListTab) {
    //                nCount = [maryBlog count];
    //            }
    //            else if (mnSelectedTab == kFavouriteTab) {
    //                nCount = ceil([maryCategory count] / 2.0);
    //            }
    //            else if (mnSelectedTab == kFriendTab) {
    //                nCount = [self getFriendCount];
    //            }
                
                nCount = [maryCategory count];
//                nCount = 1;
                
                break;
                
            default:
                break;
        }
    }
    else {
        CategoryData *cData = [maryCategory objectAtIndex:tableView.tag];
        NSArray *aryBlog = [self getCategoryBlog:cData];

        if (cData.mbShowedAll) {
            nCount = [aryBlog count];
        }
        else {
            nCount = MIN(MAX_SHOW_BLOG_NUM, [aryBlog count]);
        }
    }
    
	return nCount;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;

    if (tableView == self.mTableView) {
        if (indexPath.section == 0) {
            ProfileInfoCell *profileInfoCell = (ProfileInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileInfoCellID1"];
            [profileInfoCell fillContent:self.mUser];
            
    //        [profileInfoCell.mButGrid addTarget:self action:@selector(onButGrid:) forControlEvents:UIControlEventTouchUpInside];
    //        [profileInfoCell.mButList addTarget:self action:@selector(onButList:) forControlEvents:UIControlEventTouchUpInside];
    //        [profileInfoCell.mButFavourite addTarget:self action:@selector(onButFavourite:) forControlEvents:UIControlEventTouchUpInside];
    //        [profileInfoCell.mButFriend addTarget:self action:@selector(onButFriend:) forControlEvents:UIControlEventTouchUpInside];
            
            [profileInfoCell.mButEdit addTarget:self action:@selector(onButEdit:) forControlEvents:UIControlEventTouchUpInside];
            
    //        if (mnSelectedTab == kGridTab) {
    //            [profileInfoCell.mButGrid setImage:[UIImage imageNamed:@"profile_grid_selected.png"] forState:UIControlStateNormal];
    //        }
    //        else if (mnSelectedTab == kListTab) {
    //            [profileInfoCell.mButList setImage:[UIImage imageNamed:@"profile_list_selected.png"] forState:UIControlStateNormal];
    //        }
    //        else if (mnSelectedTab == kFavouriteTab) {
    //            [profileInfoCell.mButFavourite setImage:[UIImage imageNamed:@"profile_favourite_selected.png"] forState:UIControlStateNormal];
    //        }
    //        else if (mnSelectedTab == kFriendTab) {
    //            [profileInfoCell.mButFriend setImage:[UIImage imageNamed:@"profile_friend_selected.png"] forState:UIControlStateNormal];
    //        }
            
            // update count label
            [profileInfoCell.mLblPostNum setText:[NSString stringWithFormat:@"%lu", (unsigned long)[maryBlog count]]];
            [profileInfoCell.mLblChannelNum setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.mUser.maryCategory count]]];
    //        [profileInfoCell.mLblFriendNum setText:[NSString stringWithFormat:@"%lu", (long)[self getFriendCount]]];

            cell = profileInfoCell;
        }
        else {
    //        if (mnSelectedTab == kGridTab) {
    //            cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileGridCellID"];
    //            
    //            for (int i = 0; i < 3; i++) {
    //                UIImageView *imgviewBlog = (UIImageView *)[cell viewWithTag:100 + i];
    //                UIButton *butBlog = (UIButton *)[cell viewWithTag:200 + i];
    //                [imgviewBlog setHidden:YES];
    //                
    //                NSInteger nIndex = indexPath.row * 3 + i;
    //
    //                if (nIndex < [maryBlog count]) {
    //                    BlogData *bData = [maryBlog objectAtIndex:nIndex];
    //
    //                    [imgviewBlog sd_setImageWithURL:[NSURL URLWithString:bData.thumbnail.url]
    //                                   placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    //                    
    //                    [imgviewBlog setHidden:NO];
    //
    //                    [imgviewBlog.layer setMasksToBounds:YES];
    //                    [imgviewBlog.layer setCornerRadius:4];
    //
    //                    [butBlog addTarget:self action:@selector(didGridSingleTap:)
    //                      forControlEvents:UIControlEventTouchUpInside];
    //                }
    //            }
    //        }
    //        else if (mnSelectedTab == kListTab) {
    //            cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileListCellID"];
    //            
    //            BlogData *bData = [maryBlog objectAtIndex:indexPath.row];
    //            
    //            // image
    //            UIImageView *imgviewBlog = (UIImageView *)[cell viewWithTag:100];
    //            [imgviewBlog sd_setImageWithURL:[NSURL URLWithString:bData.image.url] placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    //            
    //            // date
    //            UILabel *lblDate = (UILabel *)[cell viewWithTag:101];
    //            
    //            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //            NSString *strDate = [dateFormatter stringFromDate:bData.createdAt];
    //            
    //            [lblDate setText:strDate];
    //        }
    //        else if (mnSelectedTab == kFavouriteTab) {
    //            cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileFavouriteCellID"];
    //            
    //            for (int i = 0; i < 2; i++) {
    //                CategoryCellView *cateCell = (CategoryCellView *)[cell viewWithTag:100 + i];
    //                [cateCell setHidden:YES];
    //                [cateCell initView];
    //                
    //                NSInteger nIndex = indexPath.row * 2 + i;
    //                
    //                if (nIndex < [maryCategory count]) {
    //                    CategoryData *cData = [maryCategory objectAtIndex:nIndex];
    //                    
    //                    // title
    //                    [cateCell.mLblTitle setText:cData.name];
    //                    
    //                    // count
    //                    NSArray *aryBlog = [self getCategoryBlog:cData];
    //                    [cateCell.mLblCount setText:[NSString stringWithFormat:@"共%lu张", (unsigned long)[aryBlog count]]];
    //                    
    //                    BlogData *bData;
    //                    if ([aryBlog count] > 0) {
    //                        [cateCell.mImgView1 setHidden:NO];
    //                        bData = [aryBlog objectAtIndex:0];
    //                        [cateCell.mImgView1 sd_setImageWithURL:[NSURL URLWithString:bData.thumbnail.url]
    //                                              placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    //                    }
    //                    if ([aryBlog count] > 1) {
    //                        [cateCell.mImgView2 setHidden:NO];
    //                        bData = [aryBlog objectAtIndex:1];
    //                        [cateCell.mImgView2 sd_setImageWithURL:[NSURL URLWithString:bData.thumbnail.url]
    //                                              placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    //                    }
    //                    if ([aryBlog count] > 2) {
    //                        [cateCell.mImgView3 setHidden:NO];
    //                        bData = [aryBlog objectAtIndex:2];
    //                        [cateCell.mImgView3 sd_setImageWithURL:[NSURL URLWithString:bData.thumbnail.url]
    //                                              placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    //                    }
    //                    if ([aryBlog count] > 3) {
    //                        [cateCell.mImgView4 setHidden:NO];
    //                        bData = [aryBlog objectAtIndex:3];
    //                        [cateCell.mImgView4 sd_setImageWithURL:[NSURL URLWithString:bData.thumbnail.url]
    //                                              placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    //                    }
    //                    
    //                    [cateCell setHidden:NO];
    //                    
    //                    // add tap recognizer to show/hide tags
    //                    if ([cateCell.gestureRecognizers count] == 0) {
    //                        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
    //                                                                       initWithTarget:self action:@selector(didCategorySingleTap:)];
    //                        [singleTapRecognizer setNumberOfTapsRequired:1];
    //                        [cateCell addGestureRecognizer:singleTapRecognizer];
    //                    }
    //                }
    //            }
    //        }
    //        else if (mnSelectedTab == kFriendTab) {
    //            FriendTableViewCell *friendCell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileFriendCellID"];
    //            UserData *uData = [self getFriendWithIndex:indexPath.row];
    //            
    //            [friendCell fillContent:uData];
    //            
    //            cell = friendCell;
    //        }
            
            ProfileBlogCell *profileBlogCell = (ProfileBlogCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileGridCellID1"];
            
            CategoryData *cData = [maryCategory objectAtIndex:indexPath.row];
            
            [profileBlogCell fillContent:cData];
            [profileBlogCell.mTableView setDataSource:self];
            [profileBlogCell.mTableView setDelegate:self];
            [profileBlogCell.mTableView setTag:indexPath.row];
            
            [profileBlogCell.mTableView reloadData];
            
            CGFloat fWidth, fHeight;
            
            fWidth = tableView.frame.size.width - 15 * 2;
            fHeight = fWidth / 4.0f - 5;
            
    //        [profileBlogCell.mTableView setFrame:CGRectMake(0, fHeight, fHeight, fWidth)];
    //        
    //        [profileBlogCell.mTableView.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    //        [profileBlogCell.mTableView setTransform:CGAffineTransformMakeRotation(M_PI/-2)];
    //        
    //        [profileBlogCell.mTableView setFrame:CGRectMake(15, 40, fWidth, fHeight)];
            
            cell = profileBlogCell;
        }
    }
    else {
        NSString *strCellIdentifier = @"ProfileBlogGridCellID";
        
        ProfileBlogGridCell *profileBlogGridCell = (ProfileBlogGridCell *)[self.mTableView dequeueReusableCellWithIdentifier:strCellIdentifier];
        
//        if (!profileBlogGridCell) {
//            profileBlogGridCell = [[ProfileBlogGridCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                                             reuseIdentifier:strCellIdentifier];
//            profileBlogGridCell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
        
        CategoryData *cData = [maryCategory objectAtIndex:tableView.tag];
        NSInteger nTotalNum = 0;
        
        NSArray *aryBlog = [self getCategoryBlog:cData];
        BlogData *bData = [aryBlog objectAtIndex:indexPath.row];
        
//        NSLog(@"index: %d, blog: %@", indexPath.row, bData.objectId);
        
        if (!cData.mbShowedAll) {
            if ([aryBlog count] > MAX_SHOW_BLOG_NUM && indexPath.row == MAX_SHOW_BLOG_NUM - 1) {
                nTotalNum = [aryBlog count];
            }
        }
        
        [profileBlogGridCell fillContent:bData totalCount:nTotalNum];
        [profileBlogGridCell.mButton addTarget:self action:@selector(onButBlog:) forControlEvents:UIControlEventTouchUpInside];
        [profileBlogGridCell.mButton setTag:indexPath.row];
        [profileBlogGridCell.contentView setTag:tableView.tag];
        
        cell = profileBlogGridCell;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (mnSelectedTab == kListTab) {
            mBlogSelected = [maryBlog objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"Me2Detail" sender:nil];
        }
        else if (mnSelectedTab == kFriendTab) {
            MeViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MeViewController"];
            viewController.mUser = [self getFriendWithIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:true];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger nHeight = 0;

    if (tableView == self.mTableView) {
        if (indexPath.section == 0) {
            ProfileInfoCell *profileInfoCell = (ProfileInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileInfoCellID1"];
            [profileInfoCell fillContent:self.mUser];
            
            nHeight = [profileInfoCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        }
        else {
            CGFloat fWidth, fHeight;
            
            fWidth = tableView.frame.size.width - 15 * 2;
            fHeight = fWidth / 4.0f - 5;
            
            nHeight = fHeight + 53;
            
    //
    //        if (mnSelectedTab == kGridTab) {
    //            fWidth = (tableView.frame.size.width - 11 * 2 - 12 - 13) / 3.0f + 9;
    //            nHeight = fWidth;
    //        }
    //        else if (mnSelectedTab == kListTab) {
    //            nHeight = 385;
    //        }
    //        else if (mnSelectedTab == kFavouriteTab) {
    //            fWidth = tableView.frame.size.width / 2.0f + 18 + 7;
    //            nHeight = fWidth;
    //        }
    //        else if (mnSelectedTab == kFriendTab) {
    //            nHeight = 60;
    //        }
        }
    }
    else {
        CGFloat fWidth, fHeight;
        
        fWidth = self.mTableView.frame.size.width - 15 * 2;
        fHeight = fWidth / 4.0f;
        
        nHeight = fHeight;
    }
    
    return nHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat fHeight = 0.1f;
    
//    if (section > 1) {
//        nHeight = 15;
//    }
    
    return fHeight;
}


#pragma mark -

- (IBAction)onButBlog:(id)sender {
    
    // get table view
    UIButton *button = (UIButton *)sender;
    NSInteger nBlogIndex = button.tag;
    NSInteger nCategoryIndex = button.superview.tag;
    
    CategoryData *cData = [maryCategory objectAtIndex:nCategoryIndex];
    
    NSArray *aryBlog = [self getCategoryBlog:cData];
    BlogData *bData = [aryBlog objectAtIndex:nBlogIndex];
    
    if (!cData.mbShowedAll) {
        if ([aryBlog count] > MAX_SHOW_BLOG_NUM && nBlogIndex == MAX_SHOW_BLOG_NUM - 1) {
            cData.mbShowedAll = YES;
            
            [self.mTableView reloadData];
            return;
        }
    }
    
    mBlogSelected = bData;
    [self performSegueWithIdentifier:@"Me2Detail" sender:nil];
}


- (void)didGridSingleTap:(id)sender {
    int nIndex = (int)((UIButton*)sender).tag - 200;
    
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.mTableView];
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    mBlogSelected = [maryBlog objectAtIndex:indexPath.row * 3 + nIndex];
    [self performSegueWithIdentifier:@"Me2Detail" sender:nil];
}

- (void)didCategorySingleTap:(id)sender {
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer*)sender;
    CategoryCellView *cateCell = (CategoryCellView *)gestureRecognizer.view;
    int nIndex = (int)cateCell.tag - 100;
    
    CGPoint buttonOriginInTableView = [cateCell convertPoint:CGPointZero toView:self.mTableView];
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    mCategorySelected = [maryCategory objectAtIndex:indexPath.row * 2 + nIndex];
    [self performSegueWithIdentifier:@"Me2Hobby" sender:nil];
}

#pragma mark - CustomActionSheetDelegate
- (void)onButFirst:(UIView *)view {
    UserData *currentUser = [UserData currentUser];
    
    if ([currentUser isBlockUserToMe:self.mUser]) {
        [currentUser removeObject:self.mUser forKey:@"blockuser"];
        [currentUser removeBlockUser:self.mUser];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [mActionsheetView setFirstTitle:@"不看他发布的内容"];
                [self showAlert:@"操作成功"];
            }
        }];
    }
    else {
        [currentUser addObject:self.mUser forKey:@"blockuser"];
        [currentUser addBlockUser:self.mUser];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [mActionsheetView setFirstTitle:@"看他发布的内容"];
                [self showAlert:@"操作成功"];
            }
        }];
    }
}

- (void)showAlert:(NSString *)strMsg {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strMsg
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)onButSecond:(UIView *)view {
    UserData *currentUser = [UserData currentUser];
    
    if ([self.mUser isBlockUserToMe:currentUser]) {
        [self.mUser removeObject:currentUser forKey:@"blockuser"];
        [self.mUser removeBlockUser:currentUser];
        
        [AVCloud callFunctionInBackground:@"removeMeFromBlockUser"
                           withParameters:@{@"userId":self.mUser.objectId}
                                    block:^(id object, NSError *error)
         {
             if (!error) {
                 [mActionsheetView setSecondTitle:@"不让他看我发布的内容"];
                 [self showAlert:@"操作成功"];
             }
             else {
                 NSLog(@"%@", error);
             }
         }];
    }
    else {
        [self.mUser addObject:currentUser forKey:@"blockuser"];
        [self.mUser addBlockUser:currentUser];
        
        [AVCloud callFunctionInBackground:@"addMeAsBlockUser"
                           withParameters:@{@"userId":self.mUser.objectId}
                                    block:^(id object, NSError *error)
        {
            if (!error) {
                [mActionsheetView setSecondTitle:@"让他看我发布的内容"];
                [self showAlert:@"操作成功"];
            }
            else {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void)onButThird:(UIView *)view {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"举报成功"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

#pragma mark -
- (NSArray *)getCategory {
    NSMutableArray *aryCat = [[NSMutableArray alloc] init];
    for (BlogData *bData in maryBlog) {
        // check if its category is counted
        BOOL bFound = NO;
        for (CategoryData *cData in aryCat) {
            if ([cData.objectId isEqualToString:bData.category.objectId]) {
                bFound = YES;
                break;
            }
        }
        
        if (!bFound && bData.category) {
            bData.category.mbShowedAll = NO;
            [aryCat addObject:bData.category];
        }
    }
    
    return aryCat;
}

- (NSArray *)getCategoryBlog:(CategoryData *)cData {
    NSMutableArray *aryBlog = [[NSMutableArray alloc] init];
    for (BlogData *bData in maryBlog) {
        if ([bData.category.objectId isEqualToString:cData.objectId]) {
            [aryBlog addObject:bData];
        }
    }
    
    return aryBlog;
}

@end
