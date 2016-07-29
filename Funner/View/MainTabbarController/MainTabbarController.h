//
//  MainTabbarController.h
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import <UIKit/UIKit.h>

@interface MainTabbarController : UITabBarController

- (void)getCategoryInfo;
- (void)messageUpdated:(NSNotification *)notification;
- (void)updateFriendAndNear;

@end
