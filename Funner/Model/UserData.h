//
//  UserData.h
//  Funner
//
//  Created by highjump on 14-12-16.
//
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

typedef enum {
    USERRELATION_NONE = 0,
    USERRELATION_FRIEND,
    USERRELATION_SEC_FREIND,
    USERRELATION_FRIEND_SENT,
    USERRELATION_FRIEND_RECEIVED,
    USERRELATION_NEAR
} UserRelation;

@class CategoryData;
@class FriendData;

@interface UserData : AVUser <AVSubclassing>

@property (retain) AVRelation *latestblog;
@property (retain) NSString *about;
@property (retain) AVGeoPoint *location;
@property (retain) AVFile *photo;
@property (retain) NSString *nickname;

@property (retain) NSMutableArray *maryCategory;

@property (nonatomic) BOOL mbGotFriend;
@property (retain) NSMutableArray *maryFriend;

@property (nonatomic) BOOL mbGotNear;

@property (nonatomic) UserRelation mnRelation;

@property (retain) UserData *mUserParent;
@property (retain) FriendData *mFriendData;

@property (retain) NSDictionary *mMsgLatest;
@property (nonatomic) NSInteger mnUnreadCount;

- (void)initData;

- (void)getCategory;
- (void)setBlockUser;

- (void)getFriendWithSuccess:(void (^)())success;
- (void)getNearUserWithSuccess:(void (^)())success;

- (BOOL)hasCategory:(CategoryData *)category;

- (NSString *)getUsernameToShow;

- (NSString *)getCategoryString;
- (NSString *)getCommonFriendString;

- (CGFloat)getDistanceFromMe;

- (UserData *)getRelatedUserData:(UserData *)user friendOnly:(BOOL)friendOnly;

- (NSArray *)getFriendArray;
- (NSArray *)getRelatedUserArray;

- (void)checkDuplicate;

- (BOOL)isBlockUserToMe:(UserData *)uData;
- (void)addBlockUser:(UserData *)uData;
- (void)removeBlockUser:(UserData *)uData;


- (void)getLatestMessage;




@end
