    //
//  BlogData.m
//  Funner
//
//  Created by highjump on 14-11-23.
//
//

#import "BlogData.h"
#import "HashTagData.h"
#import "NotificationData.h"
#import "CommonUtils.h"
#import "CategoryData.h"
#import "UserData.h"

@implementation BlogData

@dynamic user;
@dynamic username;
@dynamic image;
@dynamic thumbnail;
@dynamic hashtag;
@dynamic category;
@dynamic likeobject;
@dynamic commentobject;
@dynamic text;
@dynamic visit;
@dynamic likecomment;
@dynamic popularity;


+ (NSString *)parseClassName {
    return @"Blog";
}

- (id)init {
    self = [super init];
    
    self.maryHashTag = [[NSMutableArray alloc] init];
    self.maryLikeData = [[NSMutableArray alloc] init];
    
    self.maryCommentData = [[NSMutableArray alloc] init];
    self.marySuggestData = [[NSMutableArray alloc] init];
    
    self.mbShownTag = NO;
    self.mbSplashingTag = NO;
    
    self.mbGotLike = NO;
    self.mbGotComment = NO;
    
    self.mbIncreasedVisit = NO;
    
    return self;
}

- (void)fillData {
    if (self.createdAt) {
        //
        // hash tag
        //
        if (self.hashtag && [self.hashtag count] > 0) {
            for (NSDictionary *hashTag in self.hashtag) {
                // add to current tag list
                HashTagData *tagData = [[HashTagData alloc] init];
                
                NSNumber *posX = [hashTag objectForKey:@"posX"];
                NSNumber *posY = [hashTag objectForKey:@"posY"];
                tagData.mptPos = CGPointMake([posX doubleValue], [posY doubleValue]);
                tagData.mstrTag = [hashTag objectForKey:@"string"];
                
                [tagData revertPos];
                
                [self.maryHashTag addObject:tagData];
            }
        }
        
        CommonUtils *utils = [CommonUtils sharedObject];
        if ([utils.maryCategory count] > 0) {
            for (CategoryData *cData in utils.maryCategory) {
                if ([cData.objectId isEqualToString:self.category.objectId]) {
                    self.category = cData;
                    break;
                }
            }
        }
        
        //
        // like data & comment data
        //
//        [self addCommentData];
    }
}


- (void)addCommentData {
    if ([self.text length] > 0) {
        NotificationData *notifyData = [NotificationData object];
        notifyData.username = self.username;
        notifyData.user = self.user;
        notifyData.type = NOTIFICATION_SUGGEST;
        notifyData.thumbnail = self.image;
        notifyData.blog = self;
        notifyData.comment = self.text;
        
        [self.marySuggestData addObject:notifyData];
    }
}

- (BOOL)isLiked {
    BOOL bResult = NO;
    
    for (NotificationData *notifyData in self.maryLikeData) {
        // check if liked or not
        if ([notifyData.user.objectId isEqualToString:[UserData currentUser].objectId]) {
            bResult = YES;
            break;
        }
    }
    
    return bResult;
}

- (void)fillBlogData:(BOOL)bFromCache afterSuccess:(void (^)())success {
    
    AVRelation *relation;
    UserData *currentUser = [UserData currentUser];
    if (!currentUser) {
        currentUser = [CommonUtils getEmptyUser];
    }
    
    //
    // get like info
    //
//    self.mbGotLike = NO;
//    
//    relation = self.likeobject;
//    AVQuery *likeQuery = [relation query];
//    
//    
//    [likeQuery whereKey:@"user" containedIn:[currentUser getRelatedUserArray]];
//    
//    if (bFromCache) {
//        likeQuery.cachePolicy = kPFCachePolicyCacheOnly;
//    }
//    else {
//        likeQuery.cachePolicy = kPFCachePolicyNetworkOnly;
//    }
//    
//    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            [self.maryLikeData removeAllObjects];
//            
//            for (NotificationData *notifyData in objects) {
//                notifyData.user = [currentUser getRelatedUserData:notifyData.user friendOnly:NO];
//                [self.maryLikeData addObject:notifyData];
//            }
//        }
//        
//        self.mbGotLike = YES;
//        success();
//    }];
    
    self.mbGotLike = YES;
    
    //
    // get comment info
    //
    self.mbGotComment = NO;
    
    relation = self.commentobject;
    AVQuery *commentQuery = [relation query];
    
    [commentQuery whereKey:@"user" containedIn:[currentUser getRelatedUserArray]];
    
    if (bFromCache) {
        commentQuery.cachePolicy = kPFCachePolicyCacheOnly;
    }
    else {
        commentQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.maryCommentData removeAllObjects];
            [self.marySuggestData removeAllObjects];
            
//            [self addCommentData];
            
            for (NotificationData *notifyData in objects) {
                notifyData.user = [currentUser getRelatedUserData:notifyData.user friendOnly:NO];
                
                if (notifyData.type == NOTIFICATION_COMMENT) {
                    [self.maryCommentData addObject:notifyData];
                }
                else if (notifyData.type == NOTIFICATION_SUGGEST) {
                    [self.marySuggestData addObject:notifyData];
                }
            }
        }
        
        self.mbGotComment = YES;
        success();
    }];
}

- (void)calculatePopularity {
    if ([self.likecomment isEqualToNumber:[NSNumber numberWithInt:0]]) {
        self.popularity = [NSNumber numberWithFloat:0];
    }
    else {
        CGFloat fPopularity = ([self.visit floatValue] + 100) / [self.likecomment floatValue];
        
//        NSLog(@"visit: %f, likecomment: %f, popularity: %f", [self.visit floatValue], [self.likecomment floatValue], fPopularity);
        
        self.popularity = [NSNumber numberWithFloat:fPopularity];
    }
}


@end
