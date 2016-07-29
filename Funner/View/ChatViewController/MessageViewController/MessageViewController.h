//
//  MessageViewController.h
//  Funner
//
//  Created by highjump on 14-11-11.
//
//

#import <UIKit/UIKit.h>

@class UserData;
@class BlogData;

@interface MessageViewController : UIViewController

@property (strong) UserData *mUser;
@property (strong) BlogData *mBlog;

@end
