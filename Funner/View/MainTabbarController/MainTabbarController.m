//
//  MainTabbarController.m
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import "MainTabbarController.h"
#import "CommonUtils.h"
#import "CommonDefine.h"

#import "CategoryData.h"
#import "MBProgressHUD.h"

#import "FindViewController.h"
#import "MainViewController.h"
#import "ChatViewController.h"
#import "HobbyViewController.h"
#import "NotificationViewController.h"
#import "MainNavigationController.h"

#import "UserData.h"
#import "ContactData.h"
#import "FriendData.h"
#import "CDSessionManager.h"

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>


@interface MainTabbarController () <CLLocationManagerDelegate> {
    UserData *mCurrentUser;
    CLLocationManager *mLocationManager;
    
    NSArray *maryMessages;
    
    BOOL mbLoaded;
}

@end

@implementation MainTabbarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    //
    // init location object
    //
    mLocationManager = [[CLLocationManager alloc] init];
    mLocationManager.delegate = self;
    mLocationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    
    if ([mLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [mLocationManager requestAlwaysAuthorization];
    }
    
    //    mLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [mLocationManager startMonitoringSignificantLocationChanges];
    //    [mLocationManager startUpdatingLocation];
    
    
    CommonUtils *utils = [CommonUtils sharedObject];
    utils.mTabbarController = self;
    
    //
    // tab bar
    //
    [self.tabBar setTintColor:[UIColor whiteColor]];
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"nav_background.png"]];

    
    // set selected and unselected icons
    // main
//    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
////    item.selectedImage = [[UIImage imageNamed:@"tab_favourite_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.image = [[UIImage imageNamed:@"tab_favourite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, nil]
////                        forState:UIControlStateNormal];
//    
//    item = [self.tabBar.items objectAtIndex:1];
////    item.selectedImage = [[UIImage imageNamed:@"tab_find_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.image = [[UIImage imageNamed:@"tab_find.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, nil]
////                        forState:UIControlStateNormal];
//    
//    item = [self.tabBar.items objectAtIndex:2];
////    item.selectedImage = [[UIImage imageNamed:@"tab_chat_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.image = [[UIImage imageNamed:@"tab_chat.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, nil]
////                        forState:UIControlStateNormal];
//    
//    item = [self.tabBar.items objectAtIndex:3];
////    item.selectedImage = [[UIImage imageNamed:@"tab_me_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.image = [[UIImage imageNamed:@"tab_me.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], UITextAttributeFont, nil]
////                        forState:UIControlStateNormal];
    
    
//    // red dot
//    UILabel *badge=[[UILabel alloc]init];
//    badge.text = @"2";
//    badge.textAlignment=NSTextAlignmentCenter;
//    badge.frame=CGRectMake(15, 1, 20, 20);
//    badge.layer.cornerRadius=10;
//    badge.textColor=[UIColor whiteColor];
//    badge.backgroundColor=[UIColor greenColor];
//    [self.tabBar addSubview:badge];

    
//    UIViewController *viewController = self.selectedViewController;
//    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    [self getInitParam];
    [self getCategoryInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUpdated:) name:NOTIFICATION_MESSAGE_UPDATED object:nil];
    
    mbLoaded = NO;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self messageUpdated:nil];
}

- (void)getInitParam {
    // get category data
    AVQuery *query = [AVQuery queryWithClassName:@"Initparam"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        if (!error) {
            CommonUtils *utils = [CommonUtils sharedObject];
            utils.mfBlogPopularity = [[object objectForKey:@"blogpopularity"] floatValue];
            utils.mfBlogImgSize = [[object objectForKey:@"blogimagesize"] floatValue];
        }
    }];
}

- (void)getCategoryInfo {
    
    mCurrentUser = [UserData currentUser];
    
    if (!mCurrentUser) {
        mCurrentUser = [CommonUtils getEmptyUser];
        [self setSelectedIndex:1];
        [self.tabBar setHidden:YES];
    }
    else {
        [mCurrentUser initData];
        [self setSelectedIndex:0];
        [self.tabBar setHidden:NO];
    }
    
    // check whether contact user are all loaded
    CommonUtils *utils = [CommonUtils sharedObject];
    
    // get category data
    AVQuery *query = [CategoryData query];
    [query orderByAscending:@"parent"];
    [query orderByAscending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            [utils.maryCategory removeAllObjects];
            
            for (CategoryData *obj in objects) {
                [utils.maryCategory addObject:obj];
            }

            NSLog(@"%s", __PRETTY_FUNCTION__);
            
            [mCurrentUser getCategory];
            [self reloadTable];
            
            [self getFriendAndNear:YES];
        }
        else {
            if (error.code != kAVErrorCacheMiss) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
//            [MBProgressHUD hideHUDForView:self.selectedViewController.view animated:YES];
        }
    }];
}

- (void)updateFriendAndNear {
    if (mbLoaded) {
        [self getFriendAndNear:NO];
    }
}

- (void)getFriendAndNear:(BOOL)bNeedUpdate {
    
    CommonUtils *utils = [CommonUtils sharedObject];
    if (!utils.mbContactReady || !mCurrentUser.mbGotNear) {
        return;
    }
    
    [utils getContactInfoWithSucess:^{
        if (bNeedUpdate) {
            [self reloadTable];
            [self getBlog];
        }
    }];
    [mCurrentUser getNearUserWithSuccess:^{
        if (bNeedUpdate) {
            [self reloadTable];
            [self getBlog];
        }
    }];
    
    mbLoaded = YES;
}

- (void)messageUpdated:(NSNotification *)notification {
    
    UserData *currentUser = [UserData currentUser];
    
    if (!currentUser) {
        return;
    }
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSInteger nBadge = 0;
    
//    for (UserData *uData in currentUser.maryFriend) {
//        if (uData.mnRelation != USERRELATION_FRIEND) {
//            continue;
//        }
//
//        [uData getLatestMessage];
////        NSDictionary *dictMsg = [[CDSessionManager sharedInstance] getLatestMessageForPeerId:uData.username];
////        uData.mMsgLatest = dictMsg;
////        uData.mnUnreadCount = [[CDSessionManager sharedInstance] getUnreadCountForPeerId:uData.username];
//        
//        nBadge += uData.mnUnreadCount;
//    }
    
//    UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
//    if (nBadge > 0) {
//        [item setBadgeValue:[NSString stringWithFormat:@"%ld", (long)nBadge]];
//    }
//    else {
//        [item setBadgeValue:nil];
//    }
//    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = nBadge;
    [currentInstallation saveEventually];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = nBadge;

//
//    UIViewController *viewController = self.selectedViewController;
//    if ([viewController isKindOfClass:[ChatViewController class]]) {
//        ChatViewController *cvc = (ChatViewController *)viewController;
//        [cvc reloadTable];
//    }
    
    CommonUtils *utils = [CommonUtils sharedObject];
    [utils getLatestChatInfo];
    
//    UIViewController *viewController = self.selectedViewController;
//    if ([viewController isKindOfClass:[NotificationViewController class]]) {
//        NotificationViewController *nvc = (NotificationViewController *)viewController;
////        [nvc reloadTable];
//    }

}


- (void)reloadTable {
    UINavigationController *navigationController = (UINavigationController *)self.selectedViewController;
    UIViewController *viewController = [navigationController.viewControllers objectAtIndex:0];
    
    if ([viewController isKindOfClass:[HobbyViewController class]]) {

        CommonUtils *utils = [CommonUtils sharedObject];
        if (!utils.mbContactReady || !mCurrentUser.mbGotNear) {
            return;
        }

        HobbyViewController *hvc = (HobbyViewController *)viewController;
        [hvc reloadTable];
    }
    else if ([viewController isKindOfClass:[MainViewController class]]) {
        MainViewController *mvc = (MainViewController *)viewController;
        [mvc reloadTable];
    }
    
    [self messageUpdated:nil];
}

- (void)getBlog {
//    if ([UserData currentUser]) {
//        return;
//    }
    
    CommonUtils *utils = [CommonUtils sharedObject];
    if (!utils.mbContactReady || !mCurrentUser.mbGotNear) {
        return;
    }
    
    UINavigationController *navigationController = (UINavigationController *)self.selectedViewController;
    UIViewController *viewController = [navigationController.viewControllers objectAtIndex:0];
    
//    UIViewController *viewController = [self.viewControllers objectAtIndex:1];
//    MainNavigationController *navController = (MainNavigationController *)viewController;
//    viewController = [navController.viewControllers objectAtIndex:0];
    
    if ([viewController isKindOfClass:[HobbyViewController class]]) {
        HobbyViewController *hvc = (HobbyViewController *)viewController;
        [hvc getBlogWithProgress];
    }

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
    {
        //        NSLog(@"kCLAuthorizationStatusAuthorized");
        // Re-enable the post button if it was disabled before.
        //			self.navigationItem.rightBarButtonItem.enabled = YES;
        [mLocationManager startMonitoringSignificantLocationChanges];
    }
    else if (status == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Funner can’t access your current location.\n\nTo see the places at your current location, turn on access for Funner to your location in the Settings app under Location Services."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"kCLAuthorizationStatusNotDetermined");
    }
    else if (status == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"kCLAuthorizationStatusRestricted");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    //    UIAlertView *errorAlert = [[UIAlertView alloc]
    //                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    CommonUtils *utils = [CommonUtils sharedObject];
    if (newLocation) {
        utils.mLocationCurrent = newLocation;
        
        [mCurrentUser getNearUserWithSuccess:^{
        }];
    }
}


@end
