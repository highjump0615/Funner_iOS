//
//  CommentTableViewCell.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "CommentTableViewCell.h"
#import "NotificationData.h"
#import "CommonUtils.h"
#import "UserData.h"

#import "UIButton+WebCache.h"

@interface CommentTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *mViewLine;
@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;
@property (weak, nonatomic) IBOutlet UILabel *mLblDate;

@end


@implementation CommentTableViewCell

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

- (void)fillContent:(NotificationData *)data forHeight:(BOOL)bForHeight {
    
    if (!data) {
        return;
    }
    
    if (bForHeight) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat fLabelWidth = screenWidth - 89;
        
        CGSize constrainedSize = CGSizeMake(fLabelWidth, 9999);
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:data.comment attributes:attributesDictionary];
        
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        self.mfHeight = 0;
        self.mfHeight += ceil(requiredHeight.size.height) + 49;
    }
    else {
        [super fillContent:data];
        
        //    if (nIndex == 0) {
        //        [self.mViewLine setHidden:YES];
        //    }
        //    else {
        //        [self.mViewLine setHidden:NO];
        //    }
        
        [self.mLblUsername setText:data.username];
        
        if (data.createdAt) {
            // date
            [self.mLblDate setText:[CommonUtils getTimeString:data.createdAt]];
        }
        else {
            [self.mLblDate setText:[CommonUtils getTimeString:data.createdAt]];
        }
//        
//        [self layoutIfNeeded];
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
//    self.mLblComment.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblComment.frame);
}


@end
