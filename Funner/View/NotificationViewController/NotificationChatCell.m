//
//  NotificationChatCell.m
//  Funner
//
//  Created by highjump on 15-4-2.
//
//

#import "NotificationChatCell.h"
#import "CommonUtils.h"

#import "ChatData.h"
#import "UserData.h"

#import "UIImageView+WebCache.h"


@interface NotificationChatCell()

@property (weak, nonatomic) IBOutlet UIImageView *mImgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblUser;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;
@property (weak, nonatomic) IBOutlet UILabel *mLblTime;

@end

@implementation NotificationChatCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(ChatData *)data {
    
    [self.mLblUser setText:[data.mUser getUsernameToShow]];
    [self.mLblTime setText:[CommonUtils getTimeString:data.mDate]];
    [self.mLblContent setText:data.mStrMsg];
    
    double dRadius = self.mImgPhoto.frame.size.height / 2;
    [self.mImgPhoto.layer setMasksToBounds:YES];
    [self.mImgPhoto.layer setCornerRadius:dRadius];
    
    [data.mUser fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
        AVFile *filePhoto = object[@"photo"];
        [self.mImgPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url] placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
        
        [self.mLblUser setText:[data.mUser getUsernameToShow]];
    }];
    
}

@end
