//
//  MainViewController.h
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

- (void)reloadTable;
- (void)checkLatestBlog;

@end
