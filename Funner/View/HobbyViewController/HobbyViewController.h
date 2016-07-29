//
//  HobbyViewController.h
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import <UIKit/UIKit.h>

@class CategoryData;
@class UserData;

@interface HobbyViewController : UIViewController

@property (strong) CategoryData *mCategory;
@property (strong) UserData *mUser;

- (void)reloadTable;
- (void)getBlogWithProgress;

@end
