//
//  ProfileInfoCell.m
//  Funner
//
//  Created by highjump on 15-4-3.
//
//

#import "ProfileInfoCell.h"

#import "UIImageView+WebCache.h"

#import "UserData.h"

@interface ProfileInfoCell()

@property (weak, nonatomic) IBOutlet UIImageView *mImgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblAbout;

@end


@implementation ProfileInfoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(UserData *)user {
    
    double dRadius = self.mImgPhoto.frame.size.height / 2;
    [self.mImgPhoto.layer setMasksToBounds:YES];
    [self.mImgPhoto.layer setCornerRadius:dRadius];
    
    AVFile *filePhoto = user.photo;
    [self.mImgPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                      placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
    
    // edit profile button
    [self.mButEdit.layer setMasksToBounds:YES];
    [self.mButEdit.layer setCornerRadius:8];
    
    UserData *currentUser = [UserData currentUser];
    
    if ([user isEqual:currentUser]) {
        [self.mButEdit setTitle:@"编辑个人主页" forState:UIControlStateNormal];
    }
    else {
        [self.mButEdit setTitle:@"加为朋友" forState:UIControlStateNormal];
        
        if (user.mnRelation == USERRELATION_FRIEND && [user.mUserParent.objectId isEqualToString:currentUser.objectId]) {
            [self.mButEdit setTitle:@"已经成为朋友" forState:UIControlStateNormal];
            [self.mButEdit setEnabled:NO];
        }
    }
    
    if (user.createdAt) { // fetched
        if ([user.about length] > 0) {
            [self.mLblAbout setText:user.about];
        }
    }
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
    self.mLblAbout.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblAbout.frame);
}


@end
