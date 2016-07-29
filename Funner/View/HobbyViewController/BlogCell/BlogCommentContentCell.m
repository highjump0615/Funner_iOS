//
//  BlogCommentContentCell.m
//  Funner
//
//  Created by highjump on 15-1-24.
//
//

#import "BlogCommentContentCell.h"
#import "UserData.h"
#import "NotificationData.h"

#import "UIButton+WebCache.h"

@interface BlogCommentContentCell()

@end

@implementation BlogCommentContentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showUserPhoto:(UserData *)user {
    AVFile *filePhoto = user.photo;
    [self.mButPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                              forState:UIControlStateNormal
                      placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
}

- (void)fillContent:(NotificationData *)data {
    
    UserData *user = data.user;
    
    if (user.createdAt) {
        [self showUserPhoto:user];
    }
    else {
        [user fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            [self showUserPhoto:user];
        }];
    }
    
    double dRadius = self.mButPhoto.frame.size.height / 2;
    [self.mButPhoto.layer setMasksToBounds:YES];
    [self.mButPhoto.layer setCornerRadius:dRadius];
    
    [self.mLblComment setText:data.comment];
    
//    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
//    [self.contentView setNeedsLayout];
//    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.mLblComment.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblComment.frame);
}


@end
