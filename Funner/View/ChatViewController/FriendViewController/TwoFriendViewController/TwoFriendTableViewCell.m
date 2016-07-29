//
//  TwoFriendTableViewCell.m
//  Funner
//
//  Created by highjump on 14-12-19.
//
//

#import "TwoFriendTableViewCell.h"
#import "UserData.h"

@interface TwoFriendTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *mLblCommonFriend;

@end

@implementation TwoFriendTableViewCell


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)fillContent:(UserData *)user {
    [super fillContent:user];
    
    // common users
    NSString *strCommon = [NSString stringWithFormat:@"共同好友: %@", [user getCommonFriendString]];
    [self.mLblCommonFriend setText:strCommon];
}


@end
