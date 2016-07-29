//
//  FriendData.m
//  Funner
//
//  Created by highjump on 14-12-17.
//
//

#import "FriendData.h"

@implementation FriendData

@dynamic userfrom;
@dynamic userto;
@dynamic accepted;
@dynamic isread;
@dynamic mode;

+ (NSString *)parseClassName {
    return @"Friend";
}


@end
