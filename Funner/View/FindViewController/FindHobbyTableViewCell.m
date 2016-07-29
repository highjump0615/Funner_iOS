//
//  HobbyTableViewCell.m
//  Funner
//
//  Created by highjump on 14-11-25.
//
//

#import "FindHobbyTableViewCell.h"
#import "CategoryData.h"
#import "UIImageView+WebCache.h"
#import "BlogData.h"
#import "UserData.h"
#import "CommonUtils.h"
#import "ContactData.h"

@interface FindHobbyTableViewCell()

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintLineHeight;
@property (weak, nonatomic) IBOutlet UIView *mViewRedDot;
@property (weak, nonatomic) IBOutlet UILabel *mLblAdded;

@end

@implementation FindHobbyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showCategoryInfo:(CategoryData *)cData {
    
    [super showCategoryInfo:cData];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mButAdd.layer setMasksToBounds:YES];
    [self.mButAdd.layer setCornerRadius:5];
    
    [self.mButAdd.layer setBorderColor:utils.mColorGray.CGColor];
    
    //
    // friend count
    //
    UserData *currentUser = [UserData currentUser];
    if (!currentUser) {
        currentUser = [CommonUtils getEmptyUser];
    }
    
    if ([currentUser hasCategory:cData]) {
        [self.mButAdd setTitle:@"已添加" forState:UIControlStateNormal];
        [self.mButAdd setTitleColor:utils.mColorGray forState:UIControlStateNormal];
        [self.mButAdd.layer setBorderWidth:0.0f];

//        [self.mButAdd setHidden:YES];
//        [self.mLblAdded setHidden:NO];
    }
    else {
        [self.mButAdd setTitle:@"添加" forState:UIControlStateNormal];
        [self.mButAdd setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
        [self.mButAdd.layer setBorderWidth:1.0f];

//        [self.mButAdd setHidden:NO];
//        [self.mLblAdded setHidden:YES];
    }
    
    NSInteger nCount = 0;
    NSInteger i = 0;
    NSMutableString *strFriendTotal = [[NSMutableString alloc] init];
    NSString *strFriend;
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation == USERRELATION_FRIEND) {
            // check whether this friend has this category
            if ([uData hasCategory:cData]) {
                nCount++;
            
                if (i < MAX_SHOW_COMMON_FRIEND_NUM) {
                    if (i > 0) {
                        strFriend = [NSString stringWithFormat:@"、%@", [uData getUsernameToShow]];
                    }
                    else {
                        strFriend = [NSString stringWithString:[uData getUsernameToShow]];
                    }
                    
                    [strFriendTotal appendString:strFriend];
                }
                
                i++;
            }
        }
    }
    
    if (nCount > 0) {
        if (nCount > MAX_SHOW_COMMON_FRIEND_NUM) {
            strFriend = [NSString stringWithFormat:@"等%ld个朋友", nCount];
            [strFriendTotal appendString:strFriend];
        }
        
        [self.mLblDetail setText:strFriendTotal];
    }
    else {
        [self.mLblDetail setText:@"暂无朋友"];
    }
}



@end
