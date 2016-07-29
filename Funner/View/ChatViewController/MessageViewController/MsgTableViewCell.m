//
//  MsgTableViewCell.m
//  Funner
//
//  Created by highjump on 15-1-3.
//
//

#import "MsgTableViewCell.h"
#import "UserData.h"
#import "UIButton+WebCache.h"
#import "CommonUtils.h"

@interface MsgTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *mLblTime;
@property (weak, nonatomic) IBOutlet UIButton *mButUser;

@end

@implementation MsgTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(NSDictionary *)dictMsg user:(UserData *)userData showTime:(BOOL)bShowTime {
    AVFile *filePhoto = userData[@"photo"];
    
    [self.mButUser sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                             forState:UIControlStateNormal
                     placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
    
    double dRadius = self.mButUser.frame.size.height / 2;
    [self.mButUser.layer setMasksToBounds:YES];
    [self.mButUser.layer setCornerRadius:dRadius];
    
    if (bShowTime) {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSString *strDate = [dateFormatter stringFromDate:dictMsg[@"time"]];
//        
//        [self.mLblTime setText:strDate];
        [self.mLblTime setText:[CommonUtils getTimeString:dictMsg[@"time"]]];
    }
    else {
        [self.mLblTime setText:@""];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//
//    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
//    // need to use to set the preferredMaxLayoutWidth below.
//    [self.contentView setNeedsLayout];
//    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.mLblTime.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblTime.frame);
    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end
