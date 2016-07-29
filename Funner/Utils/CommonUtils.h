//
//  CommonUtils.h
//  Funner
//
//  Created by highjump on 14-11-4.
//
//

#import <Foundation/Foundation.h>

#define MAX_SHOW_LIKE_USER_NUM 5
#define MAX_SHOW_COMMENT_NUM 3

#define MAX_NEAR_DISTANCE 5.0     //调整附近可见距离

#define MAX_SHOW_FAVOURITE_NUM 2
#define MAX_SHOW_COMMON_FRIEND_NUM 2


@class CLLocation;
@class UserData;

@interface CommonUtils : NSObject

@property (nonatomic, retain) UIColor *mColorGray;
@property (nonatomic, retain) UIColor *mColorDarkGray;
@property (nonatomic, retain) UIColor *mColorTheme;

@property (nonatomic, retain) UITabBarController *mTabbarController;
@property (nonatomic, retain) NSMutableArray *maryCategory;
@property (retain, nonatomic) CLLocation* mLocationCurrent;

@property (nonatomic, retain) NSMutableArray *maryContact;

@property (nonatomic) CGFloat mfBlogPopularity;
@property (nonatomic) CGFloat mfBlogImgSize;

@property (nonatomic, retain) NSMutableArray *maryChatInfo;

// states
@property (nonatomic) BOOL mbContactReady;

+ (id)sharedObject;

+ (void)makeBlurToolbar:(UIView *)view color:(UIColor *)color;
+ (UIImage*)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;
+ (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;

+ (NSString *)getTimeString:(NSDate *)date;

+ (UserData *)getEmptyUser;

- (void)getContactInfoWithSucess:(void (^)())success;
- (void)addContactUserAsFriend:(NSArray *)contactArray success:(void (^)())success;

- (void)getLatestChatInfo;

@end
