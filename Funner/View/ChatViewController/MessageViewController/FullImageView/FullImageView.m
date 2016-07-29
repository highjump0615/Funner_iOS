//
//  FullImageView.m
//  Funner
//
//  Created by highjump on 15-1-11.
//
//

#import "FullImageView.h"
#import "UIImageView+WebCache.h"

@interface FullImageView() {
    CGRect rtFrameFrom;
}

@property (strong) UIView *mViewParent;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView;

@end

@implementation FullImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)initView:(UIView *)parentView
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FullImageView" owner:nil options:nil];
    FullImageView *view = [[FullImageView alloc] init];
    view = (FullImageView *)[nib objectAtIndex:0];
    view.mViewParent = parentView;
    
    return view;
}

- (void)showView:(CGRect)frameFrom url:(NSString *)strUrl {
    [self setFrame:frameFrom];
    [self layoutIfNeeded];
    
    [self.mImgView sd_setImageWithURL:[NSURL URLWithString:strUrl]
                     placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    
    // add tap guesture
    if ([self.mImgView.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(didRecognizeSingleTap:)];
        [singleTapRecognizer setNumberOfTapsRequired:1];
        [self.mImgView addGestureRecognizer:singleTapRecognizer];
    }
    
    [self.mViewParent addSubview:self];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setFrame:self.mViewParent.frame];
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         //						 self.view.userInteractionEnabled = YES;
                     }];
    
    rtFrameFrom = frameFrom;
}

- (void)didRecognizeSingleTap:(id)sender
{
    // close view
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setFrame:rtFrameFrom];
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}




@end
