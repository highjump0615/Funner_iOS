//
//  ChatData.h
//  Funner
//
//  Created by highjump on 15-4-2.
//
//

#import <Foundation/Foundation.h>

@class UserData;
@class BlogData;


@interface ChatData : NSObject

@property (nonatomic, retain) UserData *mUser;
@property (nonatomic, retain) NSString *mStrMsg;
@property (nonatomic, retain) NSDate *mDate;
@property (nonatomic, retain) BlogData *mBlog;


@end
