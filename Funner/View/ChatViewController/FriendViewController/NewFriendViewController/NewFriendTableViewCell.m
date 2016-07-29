//
//  NewFriendTableViewCell.m
//  Funner
//
//  Created by highjump on 14-12-19.
//
//

#import "NewFriendTableViewCell.h"

@implementation NewFriendTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)fillContent:(UserData *)user {
    
    [super fillContent:user];
    
    [self.mButAccept.layer setMasksToBounds:YES];
    [self.mButAccept.layer setCornerRadius:3];
}


@end
