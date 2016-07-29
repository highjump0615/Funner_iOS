//
//  BlogCategoryCell.m
//  Funner
//
//  Created by highjump on 15-2-13.
//
//

#import "BlogCategoryCell.h"
#import "CategoryData.h"
#import "UserData.h"
#import "CommonUtils.h"

@interface BlogCategoryCell()


@property (weak, nonatomic) IBOutlet UILabel *mLblFriendNum;

@end

@implementation BlogCategoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(CategoryData *)cData {
    
    [self.mButCategory.layer setMasksToBounds:YES];
    [self.mButCategory.layer setCornerRadius:5];
    
    [self.mButCategory.layer setBorderWidth:1.0f];
    [self.mButCategory.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self.mButCategory setTitle:[NSString stringWithFormat:@"  %@  ", cData.name] forState:UIControlStateNormal];
    
//    //
//    // friend count
//    //
//    UserData *currentUser = [UserData currentUser];
//    if (!currentUser) {
//        currentUser = [CommonUtils getEmptyUser];
//    }
//    
//    NSInteger nCount = 0;
//    
//    for (UserData *uData in currentUser.maryFriend) {
//        if (uData.mnRelation == USERRELATION_FRIEND) {
//            // check whether this friend has this category
//            if ([uData hasCategory:cData]) {
//                nCount++;
//            }
//        }
//    }
//
//    if (nCount > 0) {
//        [self.mLblFriendNum setText:[NSString stringWithFormat:@"%ld位朋友在玩", (long)nCount]];
//    }
//    else {
//        [self.mLblFriendNum setText:@""];
//    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
