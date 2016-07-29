//
//  NotificationCommentCell.h
//  Funner
//
//  Created by highjump on 15-4-2.
//
//

#import <UIKit/UIKit.h>

@class NotificationData;

@interface NotificationCommentCell : UITableViewCell

- (void)fillContent:(NotificationData *)data;

@end
