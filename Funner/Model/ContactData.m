//
//  ContactData.m
//  Funner
//
//  Created by highjump on 14-12-17.
//
//

#import "ContactData.h"

@implementation ContactData

- (id)init {
    self = [super init];
    
    self.maryPhone = [[NSMutableArray alloc] init];
    self.mbSentInvite = NO;
    
    return self;
}

@end
