//
//  NotificationCommentCell.m
//  Funner
//
//  Created by highjump on 15-4-2.
//
//

#import "NotificationCommentCell.h"

#import "NotificationData.h"
#import "UserData.h"

#import "CommonUtils.h"
#import "UIImageView+WebCache.h"

@interface NotificationCommentCell()

@property (weak, nonatomic) IBOutlet UIImageView *mImgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblUser;
@property (weak, nonatomic) IBOutlet UIImageView *mImgIcon;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;
@property (weak, nonatomic) IBOutlet UILabel *mLblTime;
@property (weak, nonatomic) IBOutlet UIImageView *mImgBlog;

@end

@implementation NotificationCommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(NotificationData *)data {
    
    [self.mLblUser setText:data.username];
    [self.mLblTime setText:[CommonUtils getTimeString:data.createdAt]];
    
    [self.mLblContent setText:data.comment];
    
    double dRadius = self.mImgPhoto.frame.size.height / 2;
    [self.mImgPhoto.layer setMasksToBounds:YES];
    [self.mImgPhoto.layer setCornerRadius:dRadius];
    
    [self.mImgBlog sd_setImageWithURL:[NSURL URLWithString:data.thumbnail.url]
                     placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    
    [data.user fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        AVFile *filePhoto = object[@"photo"];
        [self.mImgPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url] placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
    }];
    
    if (data.type == NOTIFICATION_COMMENT) {
        [self.mImgIcon setImage:[UIImage imageNamed:@"home_like_gray.png"]];
    }
    else {
        [self.mImgIcon setImage:[UIImage imageNamed:@"home_comment_gray.png"]];
    }
}

@end
