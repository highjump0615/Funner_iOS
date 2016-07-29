//
//  CommonUtils.m
//  Funner
//
//  Created by highjump on 14-11-4.
//
//

#import "CommonUtils.h"
#import "BlogData.h"
#import "NotificationData.h"

#import "UserData.h"
#import "ContactData.h"
#import "FriendData.h"
#import "ChatData.h"

#import <AddressBook/AddressBook.h>

#import "CDSessionManager.h"


@interface CommonUtils()

@end

@implementation CommonUtils

+ (id)sharedObject {
    
	static CommonUtils* utils = nil;
	if (utils == nil) {
        utils = [[CommonUtils alloc] init];
        
        utils.mColorGray = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1.0];
        utils.mColorDarkGray = [UIColor colorWithRed:67/255.0 green:74/255.0 blue:84/255.0 alpha:1.0];
        utils.mColorTheme = [UIColor colorWithRed:0/255.0 green:89/255.0 blue:130/255.0 alpha:1.0];
        
        utils.maryCategory = [[NSMutableArray alloc] init];
        utils.maryContact = [[NSMutableArray alloc] init];
        utils.mfBlogPopularity = 0.05f;
        utils.mfBlogImgSize = 480;
        
        utils.maryChatInfo = [[NSMutableArray alloc] init];
        
        utils.mbContactReady = YES;
    }
    
    return utils;
}

+ (void)makeBlurToolbar:(UIView *)view color:(UIColor *)color {
    view.opaque = NO;
    view.backgroundColor = [UIColor clearColor];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:view.bounds];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (color) {
        toolbar.barTintColor = color;
    }
    [view insertSubview:toolbar atIndex:0];
}

+ (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    }
    else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width
{
//    float oldWidth = sourceImage.size.width;
//    float scaleFactor = i_width / oldWidth;
//    
//    float newHeight = sourceImage.size.height * scaleFactor;
//    float newWidth = oldWidth * scaleFactor;
//    
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
//    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
    
    if(sourceImage.size.width > i_width)
    {
        float fScale = sourceImage.size.width / i_width;
        
        UIGraphicsBeginImageContext(CGSizeMake(floor(i_width), floor(sourceImage.size.height / fScale)));
        [sourceImage drawInRect:CGRectMake(0, 0, floor(i_width), floor(sourceImage.size.height / fScale))];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return smallImage;
    }
    else
        return sourceImage;
}



+ (NSString *)getTimeString:(NSDate *)date {
    
    NSString *strTime = @"";
    
    NSTimeInterval time = -[date timeIntervalSinceNow];
    int min = (int)time / 60;
    int hour = min / 60;
    int day = hour / 24;
    int month = day / 30;
    int year = month / 12;
    
    if(min < 60) {
        strTime = [NSString stringWithFormat:@"%d分钟前", min];
    }
    else if(min >= 60 && min < 60 * 24) {
        if(hour < 24) {
            strTime = [NSString stringWithFormat:@"%d小时前", hour];
        }
    }
    else if (day < 31) {
        strTime = [NSString stringWithFormat:@"%d天前", day];
    }
    else if (month < 12) {
        strTime = [NSString stringWithFormat:@"%d个月前", month];
    }
    else {
        strTime = [NSString stringWithFormat:@"%d年前", year];
    }
    
    return strTime;
}


+ (UserData *)getEmptyUser {
    static UserData *uEmptyData = nil;
    
    if (!uEmptyData) {
        uEmptyData = [[UserData alloc] init];
        [uEmptyData initData];
    }
    
    return uEmptyData;
}

- (void)getContactInfoWithSucess:(void (^)())success {
    UserData *currentUser = [UserData currentUser];
    if (!currentUser) {
        currentUser = [CommonUtils getEmptyUser];
    }
    self.mbContactReady = NO;
    
    //
    // get contact number
    //
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool greanted, CFErrorRef error) {
        [self.maryContact removeAllObjects];

        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
        for (int i = 0; i < nPeople; i++)
        {
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
            ContactData *cData = [[ContactData alloc] init];
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonLastNameProperty));
            NSMutableString *strName = [[NSMutableString alloc] init];
            if (firstName) {
                [strName appendString:[NSString stringWithFormat:@"%@ ", firstName]];
            }
            if (lastName) {
                [strName appendString:lastName];
            }
            cData.mstrName = strName;
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            for (int j = 0; j < ABMultiValueGetCount(phoneNumbers); j++)
            {
                //获取电话Label
                NSString *strPhoneLabel = (__bridge NSString*)(ABMultiValueCopyLabelAtIndex(phoneNumbers, j));
                
                if ([strPhoneLabel isEqualToString:(NSString *)kABPersonPhoneIPhoneLabel] ||
                    [strPhoneLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                    
                    //获取該Label下的电话值
                    NSString *strPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                    NSString *strPhoneNumber = [[strPhone componentsSeparatedByCharactersInSet:
                                                 [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                                componentsJoinedByString:@""];
                    [cData.maryPhone addObject:strPhoneNumber];
                }
            }
            
            if ([cData.maryPhone count] > 0) {
                [self.maryContact addObject:cData];
            }
        }
        
        NSMutableArray *aryPhone = [[NSMutableArray alloc] init];
        for (ContactData *cData in self.maryContact) {
            for (NSString *strPhone in cData.maryPhone) {
                if (currentUser.createdAt) {
                    if ([strPhone isEqualToString:currentUser.username]) {
                        continue;
                    }
                }
                
                [aryPhone addObject:strPhone];
            }
        }

        AVQuery *query = [UserData query];
        [query whereKey:@"username" containedIn:aryPhone];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:[error localizedDescription]
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                [alertView show];
                
                [self addContactUserAsFriend:objects success:success];
                
                return;
            }
            
//            [currentUser.maryFriend removeAllObjects];

            // if current user, we get friend list first
            if (currentUser.createdAt) { // logged in user

                AVQuery *queryFrom = [FriendData query];
                [queryFrom whereKey:@"userfrom" equalTo:currentUser];
//                queryFrom.cachePolicy = kPFCachePolicyNetworkElseCache;
                
                AVQuery *queryTo = [FriendData query];
                [queryTo whereKey:@"userto" equalTo:currentUser];
//                queryTo.cachePolicy = kPFCachePolicyNetworkElseCache;
                
                AVQuery *queryFriend = [AVQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryFrom, queryTo, nil]];
                [queryFriend includeKey:@"userfrom"];
                [queryFriend includeKey:@"userto"];
                queryFriend.cachePolicy = kPFCachePolicyNetworkElseCache;
                
                [queryFriend findObjectsInBackgroundWithBlock:^(NSArray *friendobjects, NSError *error) {
                    if (!error) {
                        [currentUser.maryFriend removeAllObjects];
                        
                        for (FriendData *fData in friendobjects) {
                            UserData *uDataToAdd;
                            
                            if ([currentUser.objectId isEqualToString:fData.userfrom.objectId]) {
                                uDataToAdd = fData.userto;
                                
                                if ([fData.accepted boolValue]) {
                                    uDataToAdd.mnRelation = USERRELATION_FRIEND;
                                }
                                else {
                                    uDataToAdd.mnRelation = USERRELATION_FRIEND_SENT;
                                }
                            }
                            else {
                                uDataToAdd = fData.userfrom;
                                
                                if ([fData.accepted boolValue]) {
                                    uDataToAdd.mnRelation = USERRELATION_FRIEND;
                                }
                                else {
                                    uDataToAdd.mnRelation = USERRELATION_FRIEND_RECEIVED;
                                }
                            }
                            
                            if (uDataToAdd) {
                                [uDataToAdd getCategory];
                                uDataToAdd.mUserParent = currentUser;
                                uDataToAdd.mFriendData = fData;
                                [currentUser.maryFriend addObject:uDataToAdd];
                                
                                if (uDataToAdd.mnRelation == USERRELATION_FRIEND) {
                                    // add session
                                    [[CDSessionManager sharedInstance] addChatWithPeerId:uDataToAdd.username];
                                    [uDataToAdd getLatestMessage];
                                }
                            }
                        }
                        
                        [self addContactUserAsFriend:objects success:success];
                    }
                }];
            }
            else {
                [self addContactUserAsFriend:objects success:success];
            }
        }];
    });
}

- (void)addContactUserAsFriend:(NSArray *)contactArray success:(void (^)())success {
    UserData *uData, *utData;
    UserData *currentUser = [UserData currentUser];
    if (!currentUser) {
        currentUser = [CommonUtils getEmptyUser];
    }
    
    for (uData in contactArray) {
        // check if it is duplicating
        BOOL bExist = NO;
        
        for (utData in currentUser.maryFriend) {
            if (utData.mnRelation != USERRELATION_FRIEND) {
                continue;
            }
            
            if ([utData.objectId isEqualToString:uData.objectId]) {
                bExist = YES;
                break;
            }
        }
        
        if (!bExist) {
            if (currentUser.createdAt) { // logged in user
                // save to friend table
                FriendData *fData = [FriendData object];
                fData.userfrom = currentUser;
                fData.userto = uData;
                fData.accepted = [NSNumber numberWithBool:YES];
                fData.mode = [NSNumber numberWithInt:FRIEND_CONTACT];
                [fData saveInBackground];
                
                // save to each user record
//                [currentUser addObject:uData forKey:@"friend"];
//                [currentUser saveInBackground];
//                [AVCloud callFunctionInBackground:@"addMeAsFriendToUser" withParameters:@{@"userId":uData.objectId} block:^(id object, NSError *error) {
//                }];
                
                // add session
                [[CDSessionManager sharedInstance] addChatWithPeerId:uData.username];
            }
            
            [uData getCategory];
            uData.mnRelation = USERRELATION_FRIEND;
            [currentUser.maryFriend addObject:uData];
            [uData getLatestMessage];
        }
    }
    
    //
    // get 2nd friend
    //
    if (currentUser.createdAt) { // logged in user
        
        currentUser.mbGotFriend = YES;
        
        NSMutableArray *aryMutalFriend = [[NSMutableArray alloc] init];
        for (uData in currentUser.maryFriend) {
            if (uData.mnRelation == USERRELATION_FRIEND) {
                uData.mbGotFriend = NO;
                [aryMutalFriend addObject:uData];
            }
        }
        
        AVQuery *queryFrom = [FriendData query];
        [queryFrom whereKey:@"userfrom" containedIn:aryMutalFriend];
        [queryFrom whereKey:@"userto" notEqualTo:currentUser];
        [queryFrom whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
//        queryFrom.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        AVQuery *queryTo = [FriendData query];
        [queryTo whereKey:@"userto" containedIn:aryMutalFriend];
        [queryTo whereKey:@"userfrom" notEqualTo:currentUser];
        [queryTo whereKey:@"accepted" equalTo:[NSNumber numberWithBool:YES]];
//        queryTo.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        AVQuery *queryFriend = [AVQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryFrom, queryTo, nil]];
        [queryFriend includeKey:@"userfrom"];
        [queryFriend includeKey:@"userto"];
        queryFriend.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        [queryFriend findObjectsInBackgroundWithBlock:^(NSArray *friendobjects, NSError *error) {
            if (!error) {
                for (FriendData *fData in friendobjects) {
                    UserData *uDataToAdd;
                    UserData *uftData;
                    
                    for (uftData in aryMutalFriend) {
                        uDataToAdd = nil;
                        
                        if ([uftData.objectId isEqualToString:fData.userfrom.objectId]) {
                            uDataToAdd = fData.userto;
                            uDataToAdd.mUserParent = [currentUser getRelatedUserData:fData.userfrom friendOnly:YES];
                        }
                        else if ([uftData.objectId isEqualToString:fData.userto.objectId]) {
                            uDataToAdd = fData.userfrom;
                            uDataToAdd.mUserParent = [currentUser getRelatedUserData:fData.userto friendOnly:YES];
                        }
                        
                        if (uDataToAdd) {
                            [uDataToAdd getCategory];
                            uDataToAdd.mnRelation = USERRELATION_FRIEND;
                            [uftData.maryFriend addObject:uDataToAdd];
                            [uDataToAdd getLatestMessage];
                        }
                    }
                }
                
            }
            
            self.mbContactReady = YES;
            success();
            
            for (UserData *utData in currentUser.maryFriend) {
                if (utData.mnRelation == USERRELATION_FRIEND) {
                    utData.mbGotFriend = YES;
                }
            }
        }];
    }
    else {
        self.mbContactReady = YES;
        currentUser.mbGotFriend = YES;
        success();
    }
}

- (void)getLatestChatInfo {
    UserData *currentUser = [UserData currentUser];
    if (!currentUser) {
        return;
    }

    NSArray *aryChatInfo = [[CDSessionManager sharedInstance] getLatestMessagesForPeerId];
    [self.maryChatInfo removeAllObjects];

    for (NSDictionary *dict in aryChatInfo) {

        ChatData *chatData = [[ChatData alloc] init];

        //
        // set user
        //
        NSString *strFromId = [dict objectForKey:@"fromid"];
        NSString *strToId = [dict objectForKey:@"toid"];
        NSString *strUserId;
        
        if ([strFromId isEqualToString:currentUser.objectId]) {
            strUserId = strToId;
        }
        else {
            strUserId = strFromId;
        }
        
        UserData *uData = [UserData objectWithoutDataWithObjectId:strUserId];
        chatData.mUser = [currentUser getRelatedUserData:uData friendOnly:NO];
        
        //
        // set blog
        //
        NSString *strBlog = [dict objectForKey:@"blog"];
        BlogData *bData = [BlogData objectWithoutDataWithObjectId:strBlog];
        chatData.mBlog = bData;
        
        //
        // set message & time
        //
        chatData.mStrMsg = [dict objectForKey:@"message"];
        chatData.mDate = [dict objectForKey:@"time"];
        
        [self.maryChatInfo addObject:chatData];
    }
    
}



@end
