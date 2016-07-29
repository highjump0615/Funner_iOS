//
//  NotificationData.h
//  Funner
//
//  Created by highjump on 14-12-3.
//
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>


typedef enum {
    NOTIFICATION_LIKE = 0,
    NOTIFICATION_COMMENT,
    NOTIFICATION_SUGGEST
} NotificationType;

@class BlogData;
@class UserData;

@interface NotificationData : AVObject <AVSubclassing>

@property (retain) NSString *username;
@property (retain) UserData *user;
@property (nonatomic) NotificationType type;
@property (retain) AVFile *thumbnail;
@property (retain) BlogData *blog;
@property (retain) NSNumber *isnew;
@property (retain) NSString *comment;

@end
