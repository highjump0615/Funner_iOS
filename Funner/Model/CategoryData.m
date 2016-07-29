//
//  CategoryData.m
//  Funner
//
//  Created by highjump on 14-11-22.
//
//

#import "CategoryData.h"

@implementation CategoryData

@dynamic icon;
@dynamic name;
@dynamic parent;
@dynamic desc;
@dynamic imgBackground;


+ (NSString *)parseClassName {
    return @"Category";
}

- (id)init {
    self = [super init];
    
    self.mbGotLatest = NO;
    self.mbGotNetworkLatest = NO;
    
    self.mbShowedAll = NO;
    
    return self;
}

@end
