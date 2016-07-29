//
//  NotificationData.m
//  Funner
//
//  Created by highjump on 14-12-3.
//
//

#import "NotificationData.h"
#import "BlogData.h"

@implementation NotificationData

@dynamic username;
@dynamic user;
@dynamic type;
@dynamic thumbnail;
@dynamic blog;
@dynamic isnew;
@dynamic comment;

+ (NSString *)parseClassName {
    return @"Notification";
}

- (id)init {
    self = [super init];
    
    return self;
}


@end
