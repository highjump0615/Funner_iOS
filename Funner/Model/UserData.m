
//  UserData.m
//  Funner
//
//  Created by highjump on 14-12-16.
//
//

#import "UserData.h"

#import "CategoryData.h"
#import "CommonUtils.h"
#import "ContactData.h"
#import "FriendData.h"
#import "CDSessionManager.h"

#import <CoreLocation/CoreLocation.h>


@interface UserData() {
    NSMutableArray *maryBlockUser;
}


@end

@implementation UserData

@dynamic latestblog;
@dynamic about;
@dynamic location;
@dynamic photo;
@dynamic nickname;


+ (NSString *)parseClassName {
    return @"_User";
}

- (id)init {
    self = [super init];
    
    [self initData];
    
    return self;
}

- (void)initData {
    self.maryCategory = [[NSMutableArray alloc] init];
    
    self.mbGotFriend = NO;
    self.maryFriend = [[NSMutableArray alloc] init];
    self.mUserParent = nil;
    self.mnRelation = USERRELATION_NONE;
    
    self.mbGotNear = YES;
    self.mnUnreadCount = 0;
    
    maryBlockUser = [[NSMutableArray alloc] init];
}


- (void)getCategory {
    if (!self.objectId) {
        return;
    }
    
    //
    // get category info
    //
    CommonUtils *utils = [CommonUtils sharedObject];
    NSArray *aryCategory = [self objectForKey:@"category"];
    
    for (CategoryData *cObj in aryCategory) {
        for (CategoryData *cData in utils.maryCategory) {
            if ([cData.objectId isEqualToString:cObj.objectId]) {
                [self.maryCategory addObject:cData];
                break;
            }
        }
    }
}

- (void)setBlockUser {
    //
    // get block user info
    //
    [self fetchInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        NSArray *aryBlockUser = [self objectForKey:@"blockuser"];
        
        [maryBlockUser removeAllObjects];
        for (UserData *uObj in aryBlockUser) {
            [maryBlockUser addObject:uObj.objectId];
        }
    }];
}

- (void)getFriendWithSuccess:(void (^)())success {
    self.mbGotFriend = NO;
    
    AVQuery *queryFrom = [FriendData query];
    [queryFrom whereKey:@"userfrom" equalTo:self];
    [queryFrom whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
//    queryFrom.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    AVQuery *queryTo = [FriendData query];
    [queryTo whereKey:@"userto" equalTo:self];
    [queryTo whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
//    queryTo.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    AVQuery *queryFriend = [AVQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryFrom, queryTo, nil]];
    [queryFriend includeKey:@"userfrom"];
    [queryFriend includeKey:@"userto"];
    queryFriend.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [queryFriend findObjectsInBackgroundWithBlock:^(NSArray *friendobjects, NSError *error) {
        if (!error) {
            for (FriendData *fData in friendobjects) {
                UserData *uDataToAdd;
                
                if ([self.objectId isEqualToString:fData.userfrom.objectId]) {
                    uDataToAdd = fData.userto;
                    uDataToAdd.mUserParent = fData.userfrom;
                }
                else if ([self.objectId isEqualToString:fData.userto.objectId]) {
                    uDataToAdd = fData.userfrom;
                    uDataToAdd.mUserParent = fData.userto;
                }
                
                if (uDataToAdd) {
                    [uDataToAdd getCategory];
                    uDataToAdd.mnRelation = USERRELATION_FRIEND;
                    [self.maryFriend addObject:uDataToAdd];
                }
            }
            
            self.mbGotFriend = YES;
            success();
        }
    }];
}

- (void)getNearUserWithSuccess:(void (^)())success {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.mbGotNear = NO;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    AVGeoPoint *currentPoint;
    
    if (utils.mLocationCurrent) {
        CLLocationCoordinate2D currentCoordinate = utils.mLocationCurrent.coordinate;
        currentPoint = [AVGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                              longitude:currentCoordinate.longitude];
    }
    else {
        currentPoint = self.location;
    }
    
    if (!currentPoint) {
        self.mbGotNear = YES;
        success();
        return;
    }
    
    NSLog(@"location: %f, %f", currentPoint.latitude, currentPoint.longitude);

    AVQuery * query = [UserData query];
    [query whereKey:@"location" nearGeoPoint:currentPoint withinKilometers:MAX_NEAR_DISTANCE];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            UserData *uData;
            // remove the near user first
            for (int i = 0; i < [self.maryFriend count]; i++) {
                uData = [self.maryFriend objectAtIndex:i];
                if (uData.mnRelation == USERRELATION_NEAR) {
                    [self.maryFriend removeObjectAtIndex:i];
                    i--;
                }
            }
            
            for (UserData *uData in objects) {
                // if it is self, continue
                if ([UserData currentUser] &&
                    [uData.objectId isEqualToString:[UserData currentUser].objectId]) {
                    continue;
                }
                                
                [uData getCategory];
                uData.mnRelation = USERRELATION_NEAR;
                [self.maryFriend addObject:uData];
            }
        }

        self.mbGotNear = YES;
        success();
    }];

}

- (BOOL)hasCategory:(CategoryData *)category {
    BOOL bRet = NO;
    
    // check whether this friend has this category
    for (CategoryData *cData in self.maryCategory) {
        if ([cData.objectId isEqualToString:category.objectId]) {
            bRet = YES;
            break;
        }
    }
    
    return bRet;
}

- (NSString *)getUsernameToShow {
    
    NSString *strUsername = self.nickname;
    
    if (strUsername && strUsername.length > 0) {
        return strUsername;
    }
    else {
        return self.username;
    }
}


- (CGFloat)getDistanceFromMe {
    CommonUtils *utils = [CommonUtils sharedObject];
    AVGeoPoint *currentPoint;
    
    if (utils.mLocationCurrent) {
        CLLocationCoordinate2D currentCoordinate = utils.mLocationCurrent.coordinate;
        currentPoint = [AVGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                              longitude:currentCoordinate.longitude];
    }
    else {
        currentPoint = [UserData currentUser].location;
    }
    CGFloat fDistance = [currentPoint distanceInKilometersTo:self.location];
    
    return fDistance;
}

- (NSString *)getCategoryString {
    //
    // favourite
    //
    NSMutableString *strFavouriteTotal = [[NSMutableString alloc] init];
    NSString *strFavourite;
    
    int i;
    for (i = 0; i < MIN([self.maryCategory count], MAX_SHOW_FAVOURITE_NUM); i++) {
        CategoryData *cData = [self.maryCategory objectAtIndex:i];
        
        if (i == MIN([self.maryCategory count], MAX_SHOW_FAVOURITE_NUM) - 1) {
            strFavourite = [NSString stringWithString:cData.name];
        }
        else {
            strFavourite = [NSString stringWithFormat:@"%@、", cData.name];
        }
        
        [strFavouriteTotal appendString:strFavourite];
    }
    
    if (i > 0) {
        if ([self.maryCategory count] > MAX_SHOW_FAVOURITE_NUM) {
            strFavourite = [NSString stringWithFormat:@"等%ld个频道", (unsigned long)[self.maryCategory count]];
            [strFavouriteTotal appendString:strFavourite];
        }
    }
    else {
        [strFavouriteTotal appendString:@"无爱好"];
    }

    return strFavouriteTotal;
}

- (NSString *)getCommonFriendString {
    
    //
    // common friends
    //
    NSMutableString *strCommonTotal = [[NSMutableString alloc] init];
    NSString *strCommon;
    
    UserData *currentUser = [UserData currentUser];
    NSMutableArray *aryCommonUser = [[NSMutableArray alloc] init];
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation != USERRELATION_FRIEND) {
            continue;
        }
        
        for (UserData *ucData in uData.maryFriend) {
            if ([ucData.objectId isEqualToString:self.objectId]) {
                [aryCommonUser addObject:uData];
                break;
            }
        }
    }
    
    int i;
    for (i = 0; i < MIN([aryCommonUser count], MAX_SHOW_COMMENT_NUM); i++) {
        UserData *uData = [aryCommonUser objectAtIndex:i];
        
        if (i == MIN([aryCommonUser count], MAX_SHOW_COMMENT_NUM) - 1) {
            strCommon = [uData getUsernameToShow];
        }
        else {
            strCommon = [NSString stringWithFormat:@"%@, ", [uData getUsernameToShow]];
        }
        
        [strCommonTotal appendString:strCommon];
    }
    
    return strCommonTotal;
}

- (UserData *)getRelatedUserData:(UserData *)user friendOnly:(BOOL)friendOnly {
    UserData *uDataRes;
    NSArray *aryUser;
    
    UserData *currentUser = [UserData currentUser];
    if (currentUser) {
        if ([user.objectId isEqualToString:currentUser.objectId]) {
            return currentUser;
        }
    }
    
    if (friendOnly) {
        aryUser = [self getFriendArray];
    }
    else {
        aryUser = [self getRelatedUserArray];
    }
    
//    // friend is top most priority
//    for (UserData *uData in self.maryFriend) {
//        if ([uData.objectId isEqualToString:user.objectId]) {
//            if (uData.mnRelation == USERRELATION_FRIEND) {
//                uDataRes = uData;
//                break;
//            }
//        }
//    }
    
//    if (!uDataRes) {
        for (UserData *uData in aryUser) {
            if ([uData.objectId isEqualToString:user.objectId]) {
                uDataRes = uData;
                break;
            }
//
//            for (UserData *ucData in uData.maryFriend) {
//                if ([ucData.objectId isEqualToString:user.objectId]) {
//                    uDataRes = uData;
//                    break;
//                }
//            }
//            
//            if (uDataRes) {
//                break;
//            }
        }
        
        if (!uDataRes) {
            uDataRes = user;
        }
//    }
    
    return uDataRes;
}

- (BOOL)isExistingInArray:(NSArray *)aryData object:(UserData *)userData {
    // add if it is not existing
    BOOL bExisting = NO;
    
    for (UserData *tmpData in aryData) {
        if ([tmpData.objectId isEqualToString:userData.objectId]) {
            bExisting = YES;
            break;
        }
    }
    
    return bExisting;
}

- (NSArray *)getFriendArray {
    NSMutableArray *aryRes = [[NSMutableArray alloc] init];
    
    // add me first
    if (self.createdAt) {
        [aryRes addObject:self];
    }
    
    // add friend second
    for (UserData *uData in self.maryFriend) {
        if (uData.mnRelation != USERRELATION_FRIEND) {
            continue;
        }
        
        // check whether it is blocked user
        if ([self isBlockUserToMe:uData]) {
            continue;
        }
        
        if (![self isExistingInArray:aryRes object:uData]) {
            [aryRes addObject:uData];
            
//            NSLog(@"added friend : %@", [uData getUsernameToShow]);
        }
    }
    
    return aryRes;
}


- (NSArray *)getRelatedUserArray {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableArray *aryRes = [[NSMutableArray alloc] initWithArray:[self getFriendArray]];
    
    for (UserData *uData in self.maryFriend) {
        if (uData.mnRelation != USERRELATION_FRIEND &&
            uData.mnRelation != USERRELATION_NEAR) {
            
            NSLog(@"continue: %@", [uData getUsernameToShow]);
            
            continue;
        }
        
        // check whether it is blocked user
        if ([self isBlockUserToMe:uData]) {
            continue;
        }
        
        if (![self isExistingInArray:aryRes object:uData]) {
            [aryRes addObject:uData];
            
//            NSLog(@"added related : %@", [uData getUsernameToShow]);
        }
        
        for (UserData *ucData in uData.maryFriend) {
            if (ucData.mnRelation != USERRELATION_FRIEND) {
                continue;
            }
            
            // check whether it is blocked user
            if ([self isBlockUserToMe:ucData]) {
                continue;
            }
            
            if (![self isExistingInArray:aryRes object:ucData]) {
                [aryRes addObject:ucData];
                
//                NSLog(@"added related : %@", [ucData getUsernameToShow]);
            }
        }
    }
    
    return aryRes;
}

- (void)checkDuplicate {
    for (int i = 0; i < [self.maryFriend count]; i++) {
        UserData *uData = [self.maryFriend objectAtIndex:i];
        if (uData.mnRelation != USERRELATION_NEAR) {
            continue;
        }
        
        for (int j = 0; j < [self.maryFriend count]; j++) {
            UserData *utData = [self.maryFriend objectAtIndex:j];
            if (utData.mnRelation != USERRELATION_FRIEND) {
                continue;
            }

            if ([uData.objectId isEqualToString:utData.objectId]) {
                [self.maryFriend removeObjectAtIndex:i];
                i--;
                break;
            }
        }
    }
}

- (BOOL)isBlockUserToMe:(UserData *)uData {
    BOOL bRet = NO;
    
    for (NSString *strId in maryBlockUser) {
        if ([uData.objectId isEqualToString:strId]) {
            bRet = YES;
            break;
        }
    }
    
    return bRet;
}

- (void)addBlockUser:(UserData *)uData {
    [maryBlockUser addObject:uData.objectId];
}

- (void)removeBlockUser:(UserData *)uData {
    [maryBlockUser removeObject:uData.objectId];
}


- (void)getLatestMessage {
    if (self.mnRelation != USERRELATION_FRIEND) {
        return;
    }
    
    if (!self.createdAt) {
        return;
    }
    
    UserData *currentData = [UserData currentUser];
    if (!currentData.username) {
        return;
    }
    
    NSDictionary *dictMsg = [[CDSessionManager sharedInstance] getLatestMessageForPeerId:self.username];
    self.mMsgLatest = dictMsg;
    self.mnUnreadCount = [[CDSessionManager sharedInstance] getUnreadCountForPeerId:self.username];
}


@end
