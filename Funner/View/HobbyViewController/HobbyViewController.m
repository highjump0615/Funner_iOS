//
//  HobbyViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "HobbyViewController.h"
#import "CommonUtils.h"
#import "BlogData.h"
#import "MBProgressHUD.h"
#import "CategoryData.h"
#import "CameraViewController.h"

#import "BlogCategoryCell.h"
#import "BlogCell.h"
#import "BlogCommentCell1.h"
#import "BlogTextCell.h"
#import "BlogOperationCell.h"
#import "BlogShowAllCell.h"

#import "NotificationData.h"
#import "DetailViewController.h"
#import "TTTAttributedLabel.h"
#import "MeViewController.h"
#import "UserData.h"

#import "CustomActionSheetView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "LoadingView.h"
#import "EditPhotoViewController.h"
#import "NotificationViewController.h"
#import "InputCommentView.h"
#import "NoticeView.h"

#import "MessageViewController.h"
#import "MainTabbarController.h"

@interface HobbyViewController () <EditPhotoViewDelegate, BlogCellDelegate, CustomActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DetailViewDelegate, BlogContentDelegate, InputCommentViewDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate> {
    NSMutableArray *maryBlog;
    
    UserData *mUserSelected;
    BlogData *mBlogSelected;
    NotificationType mnNotifyTypeSelected;
    
    CustomActionSheetView *mActionsheetView;
    UIImagePickerController *mImagePicker;
    
    UIRefreshControl *mRefreshControl;
    
    NSInteger mnCountOnce;
    NSInteger mnCurrentCount;

    BOOL mbFromLocal;
    BOOL mbNeedMore;
    
    BOOL mbMine;
    
    BOOL mbGotBlog;
    
    NSMutableArray *maryNotifyData;
    
    BOOL mbShownViewComment;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIView *mViewSignup;

@property (weak, nonatomic) IBOutlet NoticeView *mViewNotice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintNoticeTop;

@property (weak, nonatomic) IBOutlet InputCommentView *mViewComment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstInputCommentBottom;

@end

@implementation HobbyViewController

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
    
    // init
    mnCurrentCount = 0;
    mnCountOnce = 5;
    mbNeedMore = NO;
    mbFromLocal = YES;
    mbMine = NO;
    mbGotBlog = NO;
    maryNotifyData = [[NSMutableArray alloc] init];
    
    [self.mViewSignup setHidden:YES];
    
    
    UIEdgeInsets edgeTable = self.mTableView.contentInset;
    edgeTable.top = 64;
    
    NSString *strTitle;
    if (self.mUser) {
        strTitle = [NSString stringWithFormat:@"%@ - %@", [self.mUser getUsernameToShow], self.mCategory.name];

        edgeTable.bottom = 0;
    }
    else {
        if ([UserData currentUser]) {
            if (self.mCategory) {
                strTitle = self.mCategory.name;
            }
            else {
                strTitle = @"朋友";
            }
            
            if (self.mCategory) {
                for (CategoryData *cData in [UserData currentUser].maryCategory) {
                    if ([cData.objectId isEqualToString:self.mCategory.objectId]) {
                        mbMine = YES;
                        break;
                    }
                }
            }
            else {
                CommonUtils *utils = [CommonUtils sharedObject];
                edgeTable.bottom = utils.mTabbarController.tabBar.frame.size.height;;
            }
        }
        else {
            strTitle = @"朋友";
            
            edgeTable.bottom = self.mViewSignup.frame.size.height;
        }
    }
    [self.navigationItem setTitle:strTitle];
    
    [self.mTableView setContentInset:edgeTable];
    
    maryBlog = [[NSMutableArray alloc] init];
    
    //
    // init tableview
    //
//    self.mTableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl setTintColor:[UIColor whiteColor]];
    [mRefreshControl addTarget:self action:@selector(getBlog:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:mRefreshControl];

    
    // blur tool bar
    [self.mViewNotice setAlpha:0];
    
    [self showPostButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideCommentView:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.mViewComment setDelegate:self];
    mbShownViewComment = NO;
    
    UserData *currentUser = [UserData currentUser];
    if (currentUser) {
        [currentUser setBlockUser];
        [self getBlogWithProgress];
    }
}


- (void)reloadTable {
    [self.mTableView reloadData];
    
//    // notification badge
//    NSInteger nCount = 0;
//    for (NotificationData *notifyData in maryNotifyData) {
//        if ([notifyData.isnew boolValue]) {
//            nCount++;
//        }
//    }
//    
//    UserData *currentUser = [UserData currentUser];
//    if (!currentUser) {
//        return;
//    }
//    
//    NSString *strButName = @"消息";
//    if (nCount > 0) {
//        strButName = [NSString stringWithFormat:@"消息(%ld)", (long)nCount];
//    }
//    
//    [self.navigationItem.rightBarButtonItem setTitle:strButName];
}


- (void)getBlogWithProgress {
    
//    if (mbGotBlog) {
//        return;
//    }
    
    if (![mRefreshControl isRefreshing]) {
        [mRefreshControl beginRefreshing];
    }
    
    UserData *currentUser = [UserData currentUser];
    CommonUtils *utils = [CommonUtils sharedObject];
    if (!currentUser) {
        currentUser = [CommonUtils getEmptyUser];
    }
    
    if (!utils.mbContactReady || !currentUser.mbGotNear) {
        return;
    }
    
    [currentUser setBlockUser];
    
    [self getBlog:nil];
    
    mbGotBlog = YES;
}

- (void)viewWillAppear:(BOOL)animated {
//    [self.mTableView reloadData];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    MainTabbarController *tabbarController = (MainTabbarController *)utils.mTabbarController;
    if (!self.mCategory) {
        [tabbarController updateFriendAndNear];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    
    if ([UserData currentUser]) {
        
        if (!self.mCategory) {
            [self.tabBarController.tabBar setHidden:NO];
            [self.mViewSignup setHidden:YES];
        }
        
        if (!self.mCategory) {
//            // load notification data
//            AVQuery *query = [NotificationData query];
//            [query whereKey:@"targetuser" equalTo:[UserData currentUser]];
//            [query whereKey:@"isread" equalTo:[NSNumber numberWithBool:NO]];
//            [query whereKey:@"user" notEqualTo:[UserData currentUser]];
//            [query orderByDescending:@"createdAt"];
//            //    [query orderByAscending:@"isnew"];
//            //    [query addDescendingOrder:@"createdAt"];
//            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//            
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                
//                [maryNotifyData removeAllObjects];
//                
//                if (!error) {
//                    UserData *currentUser = [UserData currentUser];
//                    
//                    for (NotificationData *obj in objects) {
//                        obj.user = [currentUser getRelatedUserData:obj.user friendOnly:NO];
//                        [maryNotifyData addObject:obj];
//                    }
//                    
//                    [self reloadTable];
//                }
//            }];
        }
    }
    else {
        [self.tabBarController.tabBar setHidden:YES];
        [self.mViewSignup setHidden:NO];
    }
}

- (void)showPostButton {
    
    UIBarButtonItem *rightButton = nil;
    
    UserData *currentUser = [UserData currentUser];
    if (currentUser) {
        
        // check if the current category is mine
        if (mbMine) {
            rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                          target:self
                                                          action:@selector(onButRightItem:)];
        }
        else {
//            if (!self.mUser && self.mCategory) {
//                rightButton = [[UIBarButtonItem alloc] initWithTitle:@"添加爱好"
//                                                               style:UIBarButtonItemStyleBordered
//                                                              target:self
//                                                              action:@selector(onButRightItem:)];
//            }
            if (!self.mUser && !self.mCategory) {
                rightButton = [[UIBarButtonItem alloc] initWithTitle:@"朋友列表"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(onButRightItem:)];
            }
        }
    }
    
    [self.navigationItem setRightBarButtonItem:rightButton];
}

- (void)showTableView:(BOOL)bShow {
    if (bShow) {
        CommonUtils *utils = [CommonUtils sharedObject];
        [self.mTableView setBackgroundColor:utils.mColorTheme];
    }
    else {
        [self.mTableView setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)getBlog:(UIRefreshControl *)sender {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UserData *currentUser = [UserData currentUser];
    if (!currentUser) {
        currentUser = [CommonUtils getEmptyUser];
    }
    else {
//        [currentUser fetch];
    }
    
    if (sender) { // refreshing
        
        [currentUser setBlockUser];
        
//        [maryBlog removeAllObjects];
        mnCurrentCount = 0;
    }
    
    // get blog data
    AVQuery *queryUser = [BlogData query];
    if (self.mCategory) {
        [queryUser whereKey:@"category" equalTo:self.mCategory];
    }
    
    if (self.mUser) {
        [queryUser whereKey:@"user" equalTo:self.mUser];
    }
    else {
        if (self.mCategory) {
            [queryUser whereKey:@"user" containedIn:[currentUser getRelatedUserArray]];
        }
        else {
            [queryUser whereKey:@"user" containedIn:[currentUser getFriendArray]];
        }
    }
    
////    [queryUser orderByDescending:@"popularity"];
////    [queryUser addDescendingOrder:@"createdAt"];
//    
////    [queryPopular orderByDescending:@"popularity"];
////    [queryPopular addDescendingOrder:@"createdAt"];
//    
//    AVQuery *query = [AVQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryUser, queryPopular, nil]];
//
//    [query includeKey:@"user"];
////    [query orderByDescending:@"popularity"];
//    [query addDescendingOrder:@"createdAt"];
    
    AVQuery *query;
    
    if (!self.mCategory) {
        query = queryUser;
    }
    else {
        AVQuery *queryPopular = [BlogData query];
        CommonUtils *utils = [CommonUtils sharedObject];
        
        [queryPopular whereKey:@"popularity" lessThanOrEqualTo:[NSNumber numberWithFloat:utils.mfBlogPopularity]];
        [queryPopular whereKey:@"popularity" greaterThan:[NSNumber numberWithFloat:0]];
        
        if (self.mCategory) {
            [queryPopular whereKey:@"category" equalTo:self.mCategory];
        }
        if (self.mUser) {
            [queryPopular whereKey:@"user" equalTo:self.mUser];
        }
        
        NSArray *aryBlockUser = [currentUser objectForKey:@"blockuser"];
        if (aryBlockUser) {
            [queryPopular whereKey:@"user" notContainedIn:aryBlockUser];
        }
        
        query = [AVQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryUser, queryPopular, nil]];
    }
    
    [query includeKey:@"user"];
    [query addDescendingOrder:@"createdAt"];
    
    if (mbFromLocal) {
        query.cachePolicy = kPFCachePolicyCacheOnly;
    }
    else {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }

    query.skip = mnCurrentCount;
    query.limit = mnCountOnce;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            if ([objects count] > 0) {
                [self showTableView:YES];

                mbNeedMore = ([objects count] == mnCountOnce);
                
//                if (mnCurrentCount == 0) {
//                    [maryBlog removeAllObjects];
//                }
                
                if (sender) { // refreshing
                    [maryBlog removeAllObjects];
                }
                
                NSInteger i;
                
                for (BlogData *bData in objects) {
                    BlogData *blogData = nil;
                    
                    // check whether this blog is existing
                    for (BlogData *btData in maryBlog) {
                        if ([btData.objectId isEqualToString:bData.objectId]) {
                            blogData = btData;
                            
                            // set username
                            blogData.username = bData.username;
                        }
                    }
                    
                    if (!blogData) {
                        [bData fillData];
                        bData.user = [currentUser getRelatedUserData:bData.user friendOnly:!self.mCategory];
                        
                        if ([maryBlog count] == 0) {
                            [maryBlog addObject:bData];
                        }
                        else {
                            //
                            // add according to popularity & created time
                            //
                            for (i = [maryBlog count] - 1; i >= 0; i--) {
                                BlogData *btData = [maryBlog objectAtIndex:i];
                                
//                                if ([bData.popularity floatValue] < [btData.popularity floatValue]) {
//                                    [maryBlog insertObject:bData atIndex:i+1];
//                                    break;
//                                }
                                
                                if ([bData.createdAt compare:btData.createdAt] == NSOrderedAscending) {
                                    [maryBlog insertObject:bData atIndex:i+1];
                                    break;
                                }
                                
                                if (i == 0) {
                                    [maryBlog insertObject:bData atIndex:0];
                                }
                            }
                        }

                        blogData = bData;
                    }
                    
                    [blogData fillBlogData:mbFromLocal afterSuccess:^() {
                        [self updateTableView];
                    }];
                }
//                
//                // swapping popular blog according to created time
//                for (i = 0; i < [maryBlog count] - 1; i++) {
//                    BlogData *btData1 = [maryBlog objectAtIndex:i];
//                    BlogData *btData2 = [maryBlog objectAtIndex:i + 1];
//                    
//                    if ([btData1.popularity floatValue] >= utils.mfBlogPopularity &&
//                        [btData2.popularity floatValue] >= utils.mfBlogPopularity) {
//                        // swap
//                        BlogData *btData = btData2;
//                        [maryBlog setObject:btData1 atIndexedSubscript:i + 1];
//                        [maryBlog setObject:btData atIndexedSubscript:i];
//                    }
//                }
            }
            else {
                [self updateTableView];
                [self hideTableView];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error localizedDescription]);
            if (error.code == kAVErrorCacheMiss) {
                [self updateTableView];
            }
            else {
                [self hideTableView];
            }
        }
    }];
}

- (void)updateTableView {
    NSInteger i = 0;
    for (BlogData *blogData in maryBlog) {
        if (blogData.mbGotLike && blogData.mbGotComment) {
            i++;
        }
        
        // increase visit count
        if (!mbFromLocal && !blogData.mbIncreasedVisit) {
            [blogData incrementKey:@"visit"];
            [blogData calculatePopularity];
            
            [blogData saveInBackground];
            
            blogData.mbIncreasedVisit = YES;
        }
    }
    
    if (i < [maryBlog count]) {
        return;
    }
    
    if (mbFromLocal) {
        mbFromLocal = NO;
        [self getBlog:nil];
    }
    else {
        if ([mRefreshControl isRefreshing]) {
            [mRefreshControl endRefreshing];
        }
        
//        if (self.mCategory) {
//            // save the latest one
//            if (mnCurrentCount == 0) {
//                if (mbMine) {
//                    if ([maryBlog count] > 0) {
//                        self.mCategory.mBlogLatest = maryBlog[0];
//                    }
//                    else {
//                        self.mCategory.mBlogLatest = nil;
//                    }
//                    
//                    // update to avos
//                    [self saveLatestBlog];
//                }
//            }
//        }
        
        mnCurrentCount = [maryBlog count];
    }
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.mTableView reloadData];
}

- (void)saveLatestBlog {
    UserData *currentUser = [UserData currentUser];
    
    if (!currentUser) {
        return;
    }
    
    AVQuery *query = [currentUser.latestblog query];
    [query whereKey:@"category" equalTo:self.mCategory];
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (object) {
            [currentUser.latestblog removeObject:object];
        }
        
        if (self.mCategory.mBlogLatest) {
            [currentUser.latestblog addObject:self.mCategory.mBlogLatest];
        }
        
        [currentUser saveInBackground];
    }];
}

- (void)hideTableView {
    if ([maryBlog count] == 0) {
        [self showTableView:NO];
    }
    else {
        mbNeedMore = NO;
        [self.mTableView reloadData];
    }
    
    if ([mRefreshControl isRefreshing]) {
        [mRefreshControl endRefreshing];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButSignin:(id)sender {
    [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
}

- (IBAction)onButRightItem:(id)sender {
    
    if (mbMine) {
        [self onButTakePhoto];
    }
    else {
//        if (!self.mUser && self.mCategory) {
//            [self onButAddHobby];
//        }
        if (!self.mUser && !self.mCategory) {
            [self performSegueWithIdentifier:@"Hobby2Friend" sender:nil];
        }
    }
}

//- (void)onButAddHobby {
//    // add to db
//    UserData *currentUser = [UserData currentUser];
//    [currentUser addObject:self.mCategory forKey:@"category"];
//    [currentUser.maryCategory addObject:self.mCategory];
//    
//    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            mbMine = YES;
//            
//            [self.mLblNoticeDesc setText:@"添加成功，请返回并查阅你感兴趣的频道列表"];
//            
//            [self showNotice];
//            
//            [self showPostButton];
//        }
//    }];
//}

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Hobby2Camera"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CameraViewController *viewController = [navigationController.viewControllers objectAtIndex:0];
        viewController.mAddBlogDelegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"Hobby2Detail"]) {
        DetailViewController *viewController =  [segue destinationViewController];
        viewController.mBlogData = mBlogSelected;
        viewController.mnCommentType = mnNotifyTypeSelected;
        viewController.delegate = self;
    }
    else if ([[segue identifier] isEqualToString:@"Hobby2Me"]) {
        MeViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
    }
    else if ([[segue identifier] isEqualToString:@"Hobby2Notification"]) {
//        NotificationViewController *viewController =  [segue destinationViewController];
//        viewController.maryNotification = maryNotifyData;
    }
    else if ([[segue identifier] isEqualToString:@"Hobby2Message"]) {
        MessageViewController *viewController =  [segue destinationViewController];
        viewController.mBlog = mBlogSelected;
        viewController.mUser = mBlogSelected.user;
    }
}

#pragma mark - 
- (NSInteger)getBlogCount {
//    UserData *currentUser = [UserData currentUser];
//    NSInteger nCount = 0;
//    
//    for (BlogData *bData in maryBlog) {
////        if (![currentUser isBlockUserToMe:bData.user]) {
//            nCount++;
////        }
//    }
//    
//    return nCount;
    
    return [maryBlog count];
}

- (BlogData *)getBlogAtIndex:(NSInteger)nIndex {
//    UserData *currentUser = [UserData currentUser];
//    NSInteger nCount = 0;
    BlogData *bDataRes;
//
//    for (BlogData *bData in maryBlog) {
////        if (![currentUser isBlockUserToMe:bData.user]) {
//            if (nCount == nIndex) {
//                bDataRes = bData;
//                break;
//            }
//            nCount++;
////        }
//    }
//    
//    return bDataRes;
    
    if ([maryBlog count] > 0) {
        bDataRes = [maryBlog objectAtIndex:nIndex];
    }
    
    return bDataRes;
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self getBlogCount];
//    return MIN(1, [self getBlogCount]);
}

- (NSInteger)getCommentShowCount:(BlogData *)blog {
    NSInteger nCount = 0;
    
    if ([blog.maryCommentData count] > MAX_SHOW_COMMENT_NUM) {
        nCount = MAX_SHOW_COMMENT_NUM + 1;
    }
    else {
        nCount += [blog.maryCommentData count];
    }
    
    return nCount;
}

- (NSInteger)getSuggestShowCount:(BlogData *)blog {
    NSInteger nCount = 0;
    
    if ([blog.marySuggestData count] > MAX_SHOW_COMMENT_NUM) {
        nCount = MAX_SHOW_COMMENT_NUM + 1;
    }
    else {
        nCount += [blog.marySuggestData count];
    }
    
    return nCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger nCount = 2;
    
    BlogData *blog = [self getBlogAtIndex:section];
    
    if (!self.mCategory) {
        nCount++;
    }
    
    if ([blog.text length] > 0) {
        nCount++;
    }
    
//    if ([blog.maryLikeData count] > 0) {
//        nCount++;
//    }
    
    nCount += [self getCommentShowCount:blog];
    nCount += [self getSuggestShowCount:blog];
    
    return nCount;
}

- (UITableViewCell *)configureCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forHeight:(BOOL)bForHeight {
    UITableViewCell *cell;
    
    BlogData *blog = [self getBlogAtIndex:indexPath.section];
    NSInteger nIndex = indexPath.row;
    
    if (!self.mCategory) {
        nIndex--;
    }
    
    switch (nIndex) {
        case -1: {
            BlogCategoryCell *categoryCell = (BlogCategoryCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCategoryCellID"];
            [categoryCell fillContent:blog.category];
            [categoryCell.mButCategory addTarget:self action:@selector(onButCategory:) forControlEvents:UIControlEventTouchUpInside];
            categoryCell.mButCategory.tag = indexPath.section;
            
            cell = categoryCell;
            break;
        }
            
        case 0: {
            BlogCell *blogCell = (BlogCell *)[tableView dequeueReusableCellWithIdentifier:@"BlogCellID"];
            [blogCell fillContent:blog forHeight:bForHeight];

            if (!bForHeight) {
//                [blogCell showBlogImage:blog];
                
                [blogCell.mButPhoto addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
                blogCell.mButPhoto.tag = indexPath.section;
                [blogCell.mButName addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
                blogCell.mButName.tag = indexPath.section;
                
                blogCell.mContentDelegate = self;

//                blogCell.delegate = self;
//                [blogCell.mButLike addTarget:self action:@selector(onButLike:) forControlEvents:UIControlEventTouchUpInside];
//                [blogCell.mButComment addTarget:self action:@selector(onButComment:) forControlEvents:UIControlEventTouchUpInside];
//                blogCell.mButComment.tag = indexPath.section;
//                [blogCell.mButMore addTarget:self action:@selector(onButComment:) forControlEvents:UIControlEventTouchUpInside];
//                blogCell.mButMore.tag = indexPath.section;
                
//                [blogCell showHashTag:NO];
//                [blogCell splashHashTag];
            }

            cell = blogCell;
            break;
        }
            
        case 1: {
            if ([blog.text length] > 0) {
                BlogTextCell *textCell = (BlogTextCell *)[tableView dequeueReusableCellWithIdentifier:@"BlogTextCellID"];
                [textCell fillContent:blog forHeight:bForHeight];
                cell = textCell;
            }
            else {
                cell = [self configureOperationCell:tableView cellForRowAtIndexPath:indexPath];
            }
            break;
        }

        case 2: {
            if ([blog.text length] > 0) {
                cell = [self configureOperationCell:tableView cellForRowAtIndexPath:indexPath];
            }
            else {
                cell = [self configureCommentCell:tableView cellForRowAtIndexPath:indexPath forHeight:bForHeight];
            }
            break;
        }
            
        default:
            cell = [self configureCommentCell:tableView cellForRowAtIndexPath:indexPath forHeight:bForHeight];
            
            break;
    }
    
    return cell;
}

- (BlogOperationCell *)configureOperationCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlogOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlogOperationCellID"];
    BlogData *blog = [self getBlogAtIndex:indexPath.section];

    [cell fillContent:blog];
    
    [cell.mButComment addTarget:self action:@selector(onButComment:) forControlEvents:UIControlEventTouchUpInside];
    cell.mButComment.tag = indexPath.section;
    
    [cell.mButSuggest addTarget:self action:@selector(onButSuggest:) forControlEvents:UIControlEventTouchUpInside];
    cell.mButSuggest.tag = indexPath.section;
    
    [cell.mButChat addTarget:self action:@selector(onButChat:) forControlEvents:UIControlEventTouchUpInside];
    cell.mButChat.tag = indexPath.section;
    
    return cell;
}


//- (BlogCommentCell *)configureCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    BlogCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BlogCommentCellID"];
//    BlogData *blog = [self getBlogAtIndex:indexPath.section];
//    
//    [cell fillContent:blog];
//    
//    [cell.mButShowAll addTarget:self action:@selector(onButComment:) forControlEvents:UIControlEventTouchUpInside];
//    cell.mButShowAll.tag = indexPath.section;
//    
//    return cell;
//}

- (UITableViewCell *)configureCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forHeight:(BOOL)bForHeight {
    UITableViewCell *cell;
    BlogData *blog = [self getBlogAtIndex:indexPath.section];
    
    NSInteger nIndex = indexPath.row - 2;
    if ([blog.text length] > 0) {
        nIndex--;
    }
    if (!self.mCategory) {
        nIndex--;
    }
    
    NSInteger nCommentCount = [self getCommentShowCount:blog];
    if (nCommentCount > MAX_SHOW_COMMENT_NUM) {
        if (nIndex == MAX_SHOW_COMMENT_NUM) {
            BlogShowAllCell *showAllCell = (BlogShowAllCell *)[tableView dequeueReusableCellWithIdentifier:@"BlogShowAllCellID"];
            [showAllCell fillContent:blog type:NOTIFICATION_COMMENT];
            [showAllCell.mButShowAll addTarget:self action:@selector(onButShowAll:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = showAllCell;
        }
    }
    
    NSInteger nSuggestCount = [self getSuggestShowCount:blog];
    if (nSuggestCount > MAX_SHOW_COMMENT_NUM) {
        if (nIndex == nCommentCount + MAX_SHOW_COMMENT_NUM) {
            BlogShowAllCell *showAllCell = (BlogShowAllCell *)[tableView dequeueReusableCellWithIdentifier:@"BlogShowAllCellID"];
            [showAllCell fillContent:blog type:NOTIFICATION_SUGGEST];
            [showAllCell.mButShowAll addTarget:self action:@selector(onButShowAll:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = showAllCell;
        }
    }
    
    if (!cell) {
        BlogCommentCell1 *commentCell = (BlogCommentCell1 *)[tableView dequeueReusableCellWithIdentifier:@"BlogCommentCellID"];
        [commentCell.mLblContent setDelegate:self];
        
        if (nIndex < nCommentCount) {
            [commentCell fillContent:blog indexShow:nIndex type:NOTIFICATION_COMMENT forHeight:bForHeight];
        }
        else {
            [commentCell fillContent:blog indexShow:nIndex - nCommentCount type:NOTIFICATION_SUGGEST forHeight:bForHeight];
        }
        
        cell = commentCell;
    }
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UITableViewCell *cell;
    
    cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UITableViewCell *cell = nil;
    
    CGFloat height = 0;
    NSInteger nIndex = indexPath.row;
    
    BlogData *blog = [self getBlogAtIndex:indexPath.section];
    if (!self.mCategory) {
        nIndex--;
    }
    
    switch (nIndex) {
        case -1: {
            height = 46;
            break;
        }

        case 0: {
            // BlogHeaderCellID
//            height = 418;
            
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            height = screenWidth + 56;
            
            break;
        }
            
        case 1: {
            if ([blog.text length] == 0) {
                height = 38;    // operation cell
            }
            break;
        }
            
        case 2: {
            if ([blog.text length] > 0) {
                height = 38;    // operation cell
            }
            break;
        }
    }

    if (height == 0) {
        cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:YES];
        
        if ([cell isKindOfClass:[BlogTextCell class]]) {
            BlogTextCell *textCell = (BlogTextCell *)cell;
            height = textCell.mfHeight;
        }
        else if ([cell isKindOfClass:[BlogCommentCell1 class]]) {
            BlogCommentCell1 *commentCell = (BlogCommentCell1 *)cell;
            height = commentCell.mfHeight;
        }
        else if ([cell isKindOfClass:[BlogShowAllCell class]]) {
            height = 35;
        }
        
//        else {
//            height = 30;
//        }
//        if (cell) {
//            height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        }
        
//        height = 30;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat fHeight = 0;
    
    if (mbNeedMore) {
        if (section == [self getBlogCount] - 1) {
            fHeight = 50;
        }
    }
    
    return fHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view;

    if (mbNeedMore) {
        if (section == [self getBlogCount] - 1) {
            view = [LoadingView loadingView];
            
            [self getBlog:nil];
        }
    }

    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hideCommentView:nil];
}


#pragma mark - UIScrollViewDelegate

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    CGPoint offset = scrollView.contentOffset;
//    NSArray *cells = self.mTableView.visibleCells;
//
//    for (UITableViewCell *cell in cells) {
//        if (![cell isKindOfClass:[BlogPhotoCell class]]) {
//            continue;
//        }
//        
//        CGRect rtScroll = scrollView.frame;
//        rtScroll.origin = offset;
//        
//        if (CGRectIntersectsRect(rtScroll, cell.frame)) {
//            NSIndexPath *path = [self.mTableView indexPathForCell:cell];
//            BlogData *blog = [maryBlog objectAtIndex:path.section];
//            
//            BlogPhotoCell *photoCell = (BlogPhotoCell *)cell;
//            [photoCell fillContent:blog];
//        }
//    }
//}

#pragma mark - BlogContentDelegate
- (void)touchedTagView {
    [self hideCommentView:nil];
}


#pragma mark -

- (void)gotoMeView {
    if ([mUserSelected.objectId isEqualToString:[UserData currentUser].objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Hobby2Me" sender:nil];
}

- (void)onButUser:(id)sender {
    if ([UserData currentUser]) {
        BlogData *bData = [self getBlogAtIndex:(int)((UIButton*)sender).tag];
        mUserSelected = bData.user;
        [self gotoMeView];
    }
    else {
        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
    }
}


//- (void)onButLike:(id)sender {
//    if (![UserData currentUser]) {
//        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
//    }
//}

- (void)showCommentView {
    CGFloat fContsraint = self.mCstInputCommentBottom.constant;
    
    if (mbShownViewComment) {
        return;
    }
    
    [self.mViewComment.mTxtComment setText:@""];
    
    [UIView animateWithDuration:0.2
                     animations:^{
//                         if (self.mCategory) {
                             [self.mCstInputCommentBottom setConstant:fContsraint + self.mViewComment.frame.size.height];
//                         }
//                         else {
//                             CommonUtils *utils = [CommonUtils sharedObject];
//                             [self.mCstInputCommentBottom setConstant:fContsraint + self.mViewComment.frame.size.height + utils.mTabbarController.tabBar.frame.size.height];
//                         }
                         
                         [self.view layoutIfNeeded];
                         
                     }completion:^(BOOL finished) {
                         [self.mViewComment.mTxtComment becomeFirstResponder];
                     }];
    
    mbShownViewComment = YES;
}

- (void)hideCommentView:(UITapGestureRecognizer *) sender {
    if (!mbShownViewComment) {
        return;
    }
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.mCstInputCommentBottom setConstant:-self.mViewComment.frame.size.height];
                         
                         [self.view layoutIfNeeded];
                         
                     }completion:^(BOOL finished) {
                     }];
    
    [self.view endEditing:YES];
    
    mbShownViewComment = NO;
}

- (void)onButComment:(id)sender {
    if ([UserData currentUser]) {
        mBlogSelected = [self getBlogAtIndex:(int)((UIButton*)sender).tag];
        self.mViewComment.mnCommentType = NOTIFICATION_COMMENT;
        self.mViewComment.mBlogData = mBlogSelected;
        [self showCommentView];
    }
    else {
        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
    }
}

- (void)onButSuggest:(id)sender {
    if ([UserData currentUser]) {
        mBlogSelected = [self getBlogAtIndex:(int)((UIButton*)sender).tag];
        self.mViewComment.mnCommentType = NOTIFICATION_SUGGEST;
        self.mViewComment.mBlogData = mBlogSelected;
        [self showCommentView];
    }
    else {
        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
    }
}

- (void)onButChat:(id)sender {
    if ([UserData currentUser]) {
        mBlogSelected = [self getBlogAtIndex:(int)((UIButton*)sender).tag];
        if ([mBlogSelected.user.objectId isEqualToString:[UserData currentUser].objectId]) {
            return;
        }
        
        [self performSegueWithIdentifier:@"Hobby2Message" sender:nil];
    }
    else {
        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
    }
}



- (void)onButShowAll:(id)sender {

    if ([UserData currentUser]) {
        CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.mTableView];
        NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:buttonOriginInTableView];
        
        BlogData *blog = [self getBlogAtIndex:indexPath.section];
        
        NSInteger nIndex = indexPath.row - 2;
        if ([blog.text length] > 0) {
            nIndex--;
        }
        if (!self.mCategory) {
            nIndex--;
        }
        
        NSInteger nCommentCount = [self getCommentShowCount:blog];
        if (nCommentCount > MAX_SHOW_COMMENT_NUM) {
            if (nIndex == MAX_SHOW_COMMENT_NUM) {
                mnNotifyTypeSelected = NOTIFICATION_COMMENT;
            }
        }
        
        NSInteger nSuggestCount = [self getSuggestShowCount:blog];
        if (nSuggestCount > MAX_SHOW_COMMENT_NUM) {
            if (nIndex == nCommentCount + MAX_SHOW_COMMENT_NUM) {
                mnNotifyTypeSelected = NOTIFICATION_SUGGEST;
            }
        }
        
        mBlogSelected = blog;
        [self performSegueWithIdentifier:@"Hobby2Detail" sender:nil];
    }
    else {
        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
    }
}


- (void)onButCategory:(id)sender {
    if ([UserData currentUser]) {
        BlogData *blogSelected = [self getBlogAtIndex:(int)((UIButton*)sender).tag];
        
        HobbyViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HobbyViewController"];
        viewController.mCategory = blogSelected.category;
        [self.navigationController pushViewController:viewController animated:true];
    }
    else {
        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
    }
}


//- (void)onButCommentUser:(id)sender {
//    if ([UserData currentUser]) {
//        CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.mTableView];
//        NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:buttonOriginInTableView];
//
//        BlogData *bData = [self getBlogAtIndex:indexPath.section];
//        NotificationData *notifyData = [bData.maryCommentData objectAtIndex:(int)((UIButton*)sender).tag];
//        mUserSelected = notifyData.user;
//        
//        [self gotoMeView];
//    }
//    else {
//        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
//    }
//}

- (void)onButTakePhoto {
    // init take photo button
    mActionsheetView = (CustomActionSheetView *)[CustomActionSheetView initView:self.view
                                                                   ButtonTitle1:@""
                                                                   ButtonTitle2:@"拍照"
                                                                   ButtonTitle3:@"从手机相册选择"
                                                                 removeOnCancel:YES];
    mActionsheetView.delegate = self;
    
    [mActionsheetView showView];
}

#pragma mark - EditPhotoViewDelegate

- (void)addBlog:(BlogData *)blogData {
    [maryBlog insertObject:blogData atIndex:0];
    [self showTableView:YES];
    [self.mTableView reloadData];
    
    [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                           atScrollPosition:UITableViewScrollPositionTop
                                   animated:YES];
    
    [self.mViewNotice setMessage:@"上传成功！"];
    
    self.mCategory.mBlogLatest = blogData;
    
    // update to avos
    [self saveLatestBlog];
}

#pragma mark - BlogRelationCellDelegate
- (void)onLikeResult:(BOOL)bResult {
    if (bResult) {
        [self.mTableView reloadData];
    }
    else {
        [self.mViewNotice setMessage:@"网络无法链接！"];
        
        [self showNotice];
    }
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components {

    if ([UserData currentUser]) {
        if (components[@"blog"]) {
            mBlogSelected = components[@"blog"];
            [self performSegueWithIdentifier:@"Hobby2Detail" sender:nil];
        }
        else {
            mUserSelected = components[@"user"];
            [self gotoMeView];
        }
    }
    else {
        [self performSegueWithIdentifier:@"Hobby2Signin" sender:nil];
    }
}

#pragma mark - CustomActionSheetDelegate

- (void)onButSecond:(UIView *)view {
    [self shouldStartCameraController];
}

- (void)onButThird:(UIView *)view {
    [self shouldStartPhotoLibraryPickerController];
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.showsCameraControls = YES;
    mImagePicker.delegate = self;
    
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.delegate = self;
  
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *imageThumb = [CommonUtils imageWithImage:image scaledToSize:CGSizeMake(57, 57)];
    
    [mImagePicker setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    
    EditPhotoViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPhotoViewController"];
    viewController.mImgPhoto = image;
    viewController.mImgThumbPhoto = imageThumb;
    viewController.delegate = self;
    [mImagePicker pushViewController:viewController animated:true];

}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    if (mImagePicker) {
        mImagePicker.navigationBar.barStyle = UIBarStyleBlack;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - DetailViewDelegate
- (void)deleteBlog:(BlogData *)blogData {
//    [maryBlog removeObject:blogData];
    
//    [self.mTableView reloadData];
//    if ([maryBlog count] == 0) {
//        [self.mTableView setHidden:YES];
//    }
    
    // refresh view
    [mRefreshControl beginRefreshing];
    [self getBlog:mRefreshControl];
}

- (void)animationView:(CGFloat)yPos {
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
    { //phone
        
        CGSize sz = [[UIScreen mainScreen] bounds].size;
        if(yPos == sz.height - self.view.frame.size.height)
            return;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rt = self.view.frame;
                             rt.size.height = sz.height - yPos;
                             self.view.frame = rt;
                             
//                             if (!self.mCategory) {
//                                 CGFloat fContsraint = [self.mCstInputCommentBottom constant];
//                                 CommonUtils *utils = [CommonUtils sharedObject];
//                                 
//                                 if (yPos > 0) {
//                                     [self.mCstInputCommentBottom setConstant:fContsraint - utils.mTabbarController.tabBar.frame.size.height];
//                                 }
//                             }
                             
                             [self.view layoutIfNeeded];
                         }completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - KeyBoard notifications

- (void)keyboardWillShow:(NSNotification*)notify {
    CGRect rtKeyBoard = [(NSValue*)[notify.userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [self animationView:rtKeyBoard.size.width];
    }
    else {
        [self animationView:rtKeyBoard.size.height];
    }
}

- (void)keyboardWillHide:(NSNotification*)notify {
    [self animationView:0];
}


#pragma mark - InputCommentViewDelegate

- (void)onSentComment:(BOOL)bSucceed {
    if (bSucceed) {
        [self.mTableView reloadData];
    }
    else {
        [self.mViewNotice setMessage:@"网络无法链接！"];
        [self showNotice];
    }
    
    [self hideCommentView:nil];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[TTTAttributedLabel class]])
    {
        [self hideCommentView:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
