//
//  ChatTableViewCell.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "ChatTableViewCell.h"
#import "UserData.h"
#import "UIButton+WebCache.h"
#import "CommonUtils.h"

@implementation ChatTableViewCell

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showUserInfo:(UserData *)user {
    AVFile *filePhoto = user[@"photo"];
    
    [self.mButPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                              forState:UIControlStateNormal
                      placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
    
    [self.mLblUsername setText:[user getUsernameToShow]];
}

- (void)fillContent:(UserData *)data {
    
    double dRadius = self.mButPhoto.frame.size.height / 2;
    [self.mButPhoto.layer setMasksToBounds:YES];
    [self.mButPhoto.layer setCornerRadius:dRadius];
    
    dRadius = self.mLblBadge.frame.size.height / 2;
    [self.mLblBadge.layer setMasksToBounds:YES];
    [self.mLblBadge.layer setCornerRadius:dRadius];
    
    // user info
    if (data.createdAt) {
        [self showUserInfo:data];
    }
    else {
        [data fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            [self showUserInfo:data];
        }];
    }

    // message
    NSString *strMsgType = data.mMsgLatest[@"type"];
    
    if ([strMsgType isEqualToString:@"text"]) {
        NSString *strText = data.mMsgLatest[@"message"];
        [self.mLblDesc setText:strText];
    }
    else if ([strMsgType isEqualToString:@"image"]) {
        [self.mLblDesc setText:@"[图片]"];
    }
    
    // badge
    if (data.mnUnreadCount > 0) {
        [self.mLblBadge setText:[NSString stringWithFormat:@" %ld ", (long)data.mnUnreadCount]];
        [self.mLblBadge setHidden:NO];
    }
    else {
        [self.mLblBadge setHidden:YES];
    }
    
    // time
    [self.mLblTime setText:[CommonUtils getTimeString:data.mMsgLatest[@"time"]]];
}

@end
