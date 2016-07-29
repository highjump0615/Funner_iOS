//
//  HashTagData.m
//  Funner
//
//  Created by highjump on 14-11-27.
//
//

#import "HashTagData.h"

@implementation HashTagData

- (void)convertPos {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGFloat x = ceil(self.mptPos.x / screenWidth * 320.0);
    CGFloat y = ceil(self.mptPos.y / screenWidth * 320.0);
    
    self.mptPos = CGPointMake(x, y);
}

- (void)revertPos {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    if (self.mptPos.x <= 320 || self.mptPos.y <= 320) {
        CGFloat x = ceil(self.mptPos.x / 320.0 * screenWidth);
        CGFloat y = ceil(self.mptPos.y / 320.0 * screenWidth);
        
        self.mptPos = CGPointMake(x, y);
    }
}

@end
