//
//  SettingViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "SettingViewController.h"
#import "CommonUtils.h"
#import "PolicyViewController.h"
#import "SDImageCache.h"
#import "UserData.h"
#import "CDSessionManager.h"
#import "MainTabbarController.h"
#import "AppDelegate.h"
#import "Appirater.h"

@interface SettingViewController () {
    NSInteger mnCacheSize;
    NSInteger mnCacheCount;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation SettingViewController

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
    
    [self getCacheData];
}

- (void)getCacheData {
    // get cache size
    NSString *cacheFolderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    mnCacheCount = mnCacheSize = 0;
    
    NSString *dir = [cacheFolderPath stringByAppendingPathComponent:@"AVPaasCache"];
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:dir error:&error]) {
        NSDictionary *dicAttribute = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", dir, file] error:&error];
        mnCacheSize += [dicAttribute[@"NSFileSize"] intValue];
        mnCacheCount++;
    }
    
    dir = [cacheFolderPath stringByAppendingPathComponent:@"AVPaasFiles"];
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:dir error:&error]) {
        NSDictionary *dicAttribute = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", dir, file] error:&error];
        mnCacheSize += [dicAttribute[@"NSFileSize"] intValue];
        mnCacheCount++;
    }
    
    dir = [cacheFolderPath stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:dir error:&error]) {
        NSDictionary *dicAttribute = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", dir, file] error:&error];
        mnCacheSize += [dicAttribute[@"NSFileSize"] intValue];
        mnCacheCount++;
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
    if ([[segue identifier] isEqualToString:@"Setting2Policy"]) {
//        PolicyViewController *viewController = [segue destinationViewController];
//        viewController.mnType = CONTENT_ABOUT;
    }
}


- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark - TableViewDeleage

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 3;
        case 2:
			return 1;
		default:
			break;
	}
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCellID"];;
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:100];
    
    UILabel *lblCache = (UILabel *)[cell viewWithTag:101];
    [lblCache setHidden:YES];
    
    double dRadius = lblCache.frame.size.height / 2;
    [lblCache.layer setMasksToBounds:YES];
    [lblCache.layer setCornerRadius:dRadius];
    
    if (indexPath.section == 0) {
        [lblTitle setText:@"邀请朋友"];
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [lblTitle setText:@"给我评分"];
                break;
                
            case 1:
                [lblTitle setText:@"关于我们"];
                break;
                
            case 2:
                [lblTitle setText:@"清除缓存"];
                
                [lblCache setText:[NSString stringWithFormat:@"  %.1fM  ", mnCacheSize / 1024.0 / 1024.0]];
                [lblCache setHidden:NO];
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section == 2) {
        [lblTitle setText:@"退出"];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"Setting2Invite" sender:nil];
    }
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [Appirater showPrompt];
                break;
                
            case 1:
                [self performSegueWithIdentifier:@"Setting2Policy" sender:nil];
                break;
                
            case 2: {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您确定要清除缓存吗？"
                                                               message:@""
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                     otherButtonTitles:@"确定",nil];
                [alert show];
                
                break;
            }
                
            default:
                break;
        }
    }
	if (indexPath.section == 2) {
        UserData *currentUser = [UserData currentUser];
        
        // unwatch friends
        for (UserData *uData in currentUser.maryFriend) {
            if (uData.mnRelation == USERRELATION_FRIEND) {
                [[CDSessionManager sharedInstance] unwatchPeerId:uData.username];
            }
        }
        
        // remove user from installation
        AVInstallation *installation = [AVInstallation currentInstallation];
        if (installation) {
//            installation[@"user"] = nil;
//            [installation saveInBackground];
            [installation removeObjectForKey:@"user"];
        }

        [UserData logOut];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setRootView];
        
        [[CDSessionManager sharedInstance] removeSession];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	}
}


#pragma mark - Alert Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [AVFile clearAllCachedFiles];
        [AVQuery clearAllCachedResults];
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];

        mnCacheSize = 0;
        [self.mTableView reloadData];
    }
}



@end
