//
//  DetailViewController.h
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import <UIKit/UIKit.h>

@class BlogData;
@class NotificationData;

@protocol DetailViewDelegate
- (void)deleteBlog:(BlogData *)blogData;
@end


@interface DetailViewController : UIViewController

@property (strong) BlogData *mBlogData;
@property (strong) NotificationData *mNotificationData;
@property (assign) int mnCommentType;

@property (strong) id <DetailViewDelegate> delegate;

@end
