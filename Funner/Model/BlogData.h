//
//  BlogData.h
//  Funner
//
//  Created by highjump on 14-11-23.
//
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@class CategoryData;
@class UserData;

@interface BlogData : AVObject <AVSubclassing>

@property (retain) UserData *user;
@property (retain) NSString *username;
@property (retain) AVFile *image;
@property (retain) AVFile *thumbnail;
@property (retain) NSArray *hashtag;
@property (retain) CategoryData *category;
@property (retain) AVRelation *likeobject;
@property (retain) AVRelation *commentobject;
@property (retain) NSString *text;
@property (retain) NSNumber *visit;
@property (retain) NSNumber *likecomment;
@property (retain) NSNumber *popularity;

@property (retain) NSMutableArray *maryHashTag;

@property (nonatomic) BOOL mbShownTag;
@property (nonatomic) BOOL mbSplashingTag;

@property (nonatomic) BOOL mbGotLike;
@property (strong) NSMutableArray *maryLikeData;

@property (nonatomic) BOOL mbGotComment;

@property (strong) NSMutableArray *maryCommentData;
@property (strong) NSMutableArray *marySuggestData;

@property (nonatomic) BOOL mbIncreasedVisit;

- (BOOL)isLiked;
- (void)addCommentData;
- (void)fillBlogData:(BOOL)bFromCache afterSuccess:(void (^)())success;
- (void)fillData;
- (void)calculatePopularity;


@end
