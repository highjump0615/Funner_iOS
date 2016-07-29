//
//  NotificationTableViewCell.m
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import "NotificationTableViewCell.h"
#import "NotificationData.h"
#import "CommonUtils.h"
#import "UIImageView+WebCache.h"
#import "UserData.h"

@interface NotificationTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *mViewContent;

@end

@implementation NotificationTableViewCell

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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor *backgroundColor = self.mViewContent.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.mViewContent.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *backgroundColor = self.mViewContent.backgroundColor;
    [super setSelected:selected animated:animated];
    self.mViewContent.backgroundColor = backgroundColor;
}

- (void)fillContent:(NotificationData *)data {
    
    [self.mLblUsername setText:data.username];
    [self.mLblTime setText:[CommonUtils getTimeString:data.createdAt]];
    
    if (data.type == NOTIFICATION_LIKE) {
        [self.mLblDesc setText:@"赞过"];
        [self.mLblDesc setHidden:YES];
        [self.mImgLike setHidden:NO];
    }
    else {
        [self.mLblDesc setText:data.comment];
        [self.mLblDesc setHidden:NO];
        [self.mImgLike setHidden:YES];
    }
    
    double dRadius = self.mImgPhoto.frame.size.height / 2;
    [self.mImgPhoto.layer setMasksToBounds:YES];
    [self.mImgPhoto.layer setCornerRadius:dRadius];
    
//    [self.mImgThumb.layer setMasksToBounds:YES];
//    [self.mImgThumb.layer setCornerRadius:5];
//    
    [self.mImgThumb sd_setImageWithURL:[NSURL URLWithString:data.thumbnail.url]
                      placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    
    [data.user fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        AVFile *filePhoto = object[@"photo"];
        [self.mImgPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url] placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
    }];

}

@end
