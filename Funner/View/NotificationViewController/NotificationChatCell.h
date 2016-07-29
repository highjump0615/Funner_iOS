//
//  NotificationChatCell.h
//  Funner
//
//  Created by highjump on 15-4-2.
//
//

#import <UIKit/UIKit.h>

@class ChatData;

@interface NotificationChatCell : UITableViewCell

- (void)fillContent:(ChatData *)data;

@end
