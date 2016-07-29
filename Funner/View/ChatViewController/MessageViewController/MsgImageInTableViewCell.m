//
//  MsgImageInTableViewCell.m
//  Funner
//
//  Created by highjump on 15-1-7.
//
//

#import "MsgImageInTableViewCell.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UIImageView+WebCache.h"


@interface MsgImageInTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *mViewBubble;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintImageHeight;


@end

@implementation MsgImageInTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setPhotoImage:(AVObject *)object {
    AVFile *file = [object objectForKey:@"image"];
    [self.mImgViewPhoto sd_setImageWithURL:[NSURL URLWithString:file.url]
                          placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
}

- (void)fillContent:(NSDictionary *)dictMsg user:(UserData *)userData object:(AVObject *)object showTime:(BOOL)bShowTime {
    
    [super fillContent:dictMsg user:userData showTime:bShowTime];
    
    double dWidth = [dictMsg[@"width"] doubleValue];
    double dHeight = [dictMsg[@"height"] doubleValue];
    
    if (object.createdAt) {
        [self setPhotoImage:object];
    }
    else {
        [object fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            [self setPhotoImage:object];
        }];
    }
    
    
    [self.mConstraintImageWidth setConstant:dWidth];
    [self.mConstraintImageHeight setConstant:dHeight];
    
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
}

- (void)setBubbleImage {
    //
    // set bubble view
    //
    // remove child image view first
    UIImageView *imgViewOld = (UIImageView *)[self.mViewBubble viewWithTag:101];
    [imgViewOld removeFromSuperview];
    
    UIImage* image = [UIImage imageNamed:@"bubble_in.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(14, 17, 10, 11);
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
