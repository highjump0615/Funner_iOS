//
//  MsgTextOutTableViewCell.m
//  Funner
//
//  Created by highjump on 15-1-4.
//
//

#import "MsgTextOutTableViewCell.h"
#import "UserData.h"

@interface MsgTextOutTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *mViewBubble;
@property (weak, nonatomic) IBOutlet UILabel *mLblText;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintTextWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintTextHeight;

@end


@implementation MsgTextOutTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)fillContent:(NSDictionary *)dictMsg user:(UserData *)userData showTime:(BOOL)bShowTime {
    
    [super fillContent:dictMsg user:userData showTime:bShowTime];

    NSString *strText = dictMsg[@"message"];
    [self.mLblText setText:strText];
    
    CGSize maximumLabelSize = CGSizeMake(150, 9999);
    CGSize expectSize = [self.mLblText sizeThatFits:maximumLabelSize];

    [self.mConstraintTextWidth setConstant:expectSize.width];
    [self.mConstraintTextHeight setConstant:expectSize.height];
    
    [self layoutIfNeeded];
    
    [self setBubbleImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.mLblText.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblText.frame);
}

- (void)setBubbleImage {
    //
    // set bubble view
    //
    // remove child image view first
    UIImageView *imgViewOld = (UIImageView *)[self.mViewBubble viewWithTag:101];
    [imgViewOld removeFromSuperview];
    
    UIImage* image = [UIImage imageNamed:@"bubble_out.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(14, 11, 10, 17);
    image = [image resizableImageWithCapInsets:insets];
    
    [self.mViewBubble setBackgroundColor:[UIColor clearColor]];
    CGRect rtFrame = self.mViewBubble.frame;
    rtFrame.origin = CGPointMake(0, 0);
    UIImageView *imgViewBubble = [[UIImageView alloc] initWithFrame:rtFrame];
    [imgViewBubble setImage:image];
    [imgViewBubble setTag:101];
    [self.mViewBubble insertSubview:imgViewBubble atIndex:0];

}


@end
