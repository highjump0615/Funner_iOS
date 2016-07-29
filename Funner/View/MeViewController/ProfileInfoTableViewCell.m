//
//  ProfileInfoTableViewCell.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "ProfileInfoTableViewCell.h"
#import "UIButton+WebCache.h"
#import "UserData.h"

@interface ProfileInfoTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *mLblRelation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintSpace;

@end

@implementation ProfileInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
//    mbShowedPhoto = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(UserData *)user {
    
    double dRadius = self.mButPhoto.frame.size.height / 2;
    [self.mButPhoto.layer setMasksToBounds:YES];
    [self.mButPhoto.layer setCornerRadius:dRadius];
    
    [self.mLblRelation setText:@""];
    [self.mLblAbout setText:@""];
    
    AVFile *filePhoto = user.photo;
    [self.mButPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
    
    // edit profile button
    [self.mButEdit.layer setMasksToBounds:YES];
    [self.mButEdit.layer setCornerRadius:10];
//    [self.mButEdit.layer setBorderWidth:1.0f];
//    [self.mButEdit.layer setBorderColor:[UIColor colorWithRed:36/255.0 green:185/255.0 blue:191/255.0 alpha:1].CGColor];
    
    UserData *currentUser = [UserData currentUser];
    
    if ([user isEqual:currentUser]) {
        [self.mButEdit setTitle:@"编辑个人主页" forState:UIControlStateNormal];
    }
    else {
        [self.mButEdit setTitle:@"加为朋友" forState:UIControlStateNormal];
        
        if (user.mnRelation == USERRELATION_FRIEND && [user.mUserParent.objectId isEqualToString:currentUser.objectId]) {
            [self.mButEdit setTitle:@"发消息" forState:UIControlStateNormal];
        }
        else {
            if (user.mnRelation == USERRELATION_NEAR) {
                CGFloat fDistance = [user getDistanceFromMe];
                [self.mLblRelation setText:[NSString stringWithFormat:@"附近的人，离我%.1f公里", fDistance]];
            }
            else {
                NSString *strCommonFriend = [user getCommonFriendString];
                if ([strCommonFriend length] > 0) {
                    strCommonFriend = [NSString stringWithFormat:@"共同好友: %@", strCommonFriend];
                    [self.mLblRelation setText:strCommonFriend];
                }
            }
        }
    }
    
    if ([self.mLblRelation.text length] == 0) {
        [self.mConstraintSpace setConstant:0];
    }
    
    [self.mButGrid setImage:[UIImage imageNamed:@"profile_grid.png"] forState:UIControlStateNormal];
    [self.mButList setImage:[UIImage imageNamed:@"profile_list.png"] forState:UIControlStateNormal];
    [self.mButFavourite setImage:[UIImage imageNamed:@"profile_favourite.png"] forState:UIControlStateNormal];
    [self.mButFriend setImage:[UIImage imageNamed:@"profile_friend.png"] forState:UIControlStateNormal];

    if (user.createdAt) // fetched
    {
        [self.mLblAbout setText:user.about];
    }
    
    [self layoutIfNeeded];
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
    self.mLblRelation.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblRelation.frame);
}


@end
