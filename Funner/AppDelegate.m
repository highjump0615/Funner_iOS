//
//  AppDelegate.m
//  Funner
//
//  Created by highjump on 14-11-4.
//
//

#import "AppDelegate.h"
#import "CommonUtils.h"


#import <AVOSCloud/AVOSCloud.h>
#import "AdData.h"
#import "CategoryData.h"
#import "UserData.h"
#import "BlogData.h"
#import "NotificationData.h"
#import "WXApi.h"
#import "FriendData.h"
#import "CommonDefine.h"
#import "MainNavigationController.h"
#import "MainTabbarController.h"

#import <TencentOpenAPI/TencentOAuth.h>

#import "Appirater.h"


@interface AppDelegate() <WXApiDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog(@"%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    
    //
    // other
    //
    [AdData registerSubclass];
    [CategoryData registerSubclass];
    [UserData registerSubclass];
    [BlogData registerSubclass];
    [NotificationData registerSubclass];
    [FriendData registerSubclass];
    
    [AVOSCloud setApplicationId:@"u2usgtzl5t8w9t2qpf8bbc88rvg85g5tgjtja3jpq0gfoilc"
                      clientKey:@"dspdy8ip356aahviafq216hszwb0gp908vov9b4cck7nrywu"];
    
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // weixin register
    [WXApi registerApp:@"wx82020a952558f8eb"];
    
    if (SYSTEM_VERSION < 8.0) {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                | UIUserNotificationTypeBadge
                                                | UIUserNotificationTypeSound
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    // status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([UserData currentUser]) {
        [self setRootView];
    }
    else {
        // load tag array from user default
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([userDefaults objectForKey:kUserDefaultTourPassed] != nil) {
            BOOL bPassed = [[userDefaults objectForKey:kUserDefaultTourPassed] boolValue];
            
            if (bPassed) {
                [self setRootView];
            }
        }
    }
    
    [Appirater setAppId:@"970836065"];
    
    return YES;
}

- (void)setRootView {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabbarController *viewController = (MainTabbarController *)[storyboard instantiateViewControllerWithIdentifier:@"MainTabbar"];
    [self.window makeKeyAndVisible];
//        [self.window.rootViewController presentViewController:viewController
//                                                     animated:YES
//                                                   completion:nil];
    
    [self.window setRootViewController:viewController];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //聊天接收推送消息必需
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self showErrorWithTitle:@"Installation保存失败" error:error];
        }
    }];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"Error:%@",str);
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //可选 通过统计功能追踪通过提醒打开应用的行为
    [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    
    [AVPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateActive) {
//        // app was already in the foreground
//        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//        if (currentInstallation.badge > 0) {
//            currentInstallation.badge = 0;
//            [currentInstallation saveEventually];
//            
//            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//        }
    }
    else {
        // app was just brought from background to foreground
        CommonUtils *utils = [CommonUtils sharedObject];
        [utils.mTabbarController setSelectedIndex:2];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [TencentOAuth HandleOpenURL:url];
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [TencentOAuth HandleOpenURL:url];
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)showErrorWithTitle:(NSString *)title error:(NSError *)error {
    NSString *content = [NSString stringWithFormat:@"%@", error];
    NSLog(@"%@\n%@", title, content);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                   message:content
                                                  delegate:nil
                                         cancelButtonTitle:@"知道了"
                                         otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.highjmp.test" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Funner" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Funner.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - WXAPI

-(void) onReq:(BaseReq*)req {
}

-(void) onResp:(BaseResp*)resp {
}

@end
