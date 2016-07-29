//
//  FriendData.h
//  Funner
//
//  Created by highjump on 14-12-17.
//
//

#import <AVOSCloud/AVOSCloud.h>

@class UserData;

typedef enum {
    FRIEND_NORMAL = 0,
    FRIEND_CONTACT
} FriendMode;

@interface FriendData : AVObject <AVSubclassing>

@property (retain) UserData *userfrom;
@property (retain) UserData *userto;
@property (retain) NSNumber *accepted;
@property (retain) NSNumber *isread;
@property (retain) NSNumber *mode;

@end
