//
//  BlogOperationCell.m
//  Funner
//
//  Created by highjump on 15-3-29.
//
//

#import "BlogOperationCell.h"
#import "BlogData.h"
#import "UserData.h"

@interface BlogOperationCell()

@property (weak, nonatomic) IBOutlet UILabel *mLblRelation;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstButChatWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstSpacingCommentChat;

@end

@implementation BlogOperationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(BlogData *)data {
    
    UserData *currentUser = [UserData currentUser];
    
    [self.mLblRelation setText:@" "];
    
    if (data.user.mnRelation == USERRELATION_FRIEND) {
        if (!currentUser || [data.user.mUserParent.objectId isEqualToString:currentUser.objectId]) {
            [self.mLblRelation setText:@"朋友"];
        }
        else {
            [self.mLblRelation setText:@"朋友的朋友"];
        }
        
        [self updateButtons:YES];
    }
    else if (data.user.mnRelation == USERRELATION_NEAR) {
        [self.mLblRelation setText:@"附近的人"];
        
        [self updateButtons:YES];
    }
    else {
        [self updateButtons:NO];
    }
}

- (void)updateButtons:(BOOL)bShow {
    if (bShow) {
        [self.mCstButChatWidth setConstant:46];
        [self.mCstSpacingCommentChat setConstant:10];
        [self.mButChat setHidden:NO];
    }
    else {
        [self.mCstButChatWidth setConstant:0];
        [self.mCstSpacingCommentChat setConstant:0];
        [self.mButChat setHidden:YES];
    }
    
    [self layoutIfNeeded];
}

@end
