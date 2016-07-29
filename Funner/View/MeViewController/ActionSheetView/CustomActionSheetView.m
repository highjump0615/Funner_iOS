//
//  CustomActionSheetView.m
//  Funner
//
//  Created by highjump on 14-11-19.
//
//

#import "CustomActionSheetView.h"

@interface CustomActionSheetView()

@property (nonatomic) BOOL mbRemoveOnCancel;

@end

@implementation CustomActionSheetView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
    self = [super init];
    
    return self;
}

+ (id)initView:(UIView *)parentView
  ButtonTitle1:(NSString *)strTitle1
  ButtonTitle2:(NSString *)strTitle2
  ButtonTitle3:(NSString *)strTitle3
removeOnCancel:(BOOL)bRemoveOnCancel
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomActionSheet" owner:nil options:nil];
    CustomActionSheetView *view = [[CustomActionSheetView alloc] init];
    view = (CustomActionSheetView *)[nib objectAtIndex:0];
    view.mbRemoveOnCancel = bRemoveOnCancel;
    
    [view setView:parentView ButtonTitle1:strTitle1 ButtonTitle2:strTitle2 ButtonTitle3:strTitle3];
    
    return view;
}

- (void)setView:(UIView *)parentView
   ButtonTitle1:(NSString *)strTitle1
   ButtonTitle2:(NSString *)strTitle2
   ButtonTitle3:(NSString *)strTitle3
{
    mbIsShowing = NO;
    
    // set View
    [self.mButFirst.layer setMasksToBounds:YES];
    [self.mButFirst.layer setCornerRadius:3];
    [self.mButFirst setTitle:strTitle1 forState:UIControlStateNormal];
    
    [self.mButSecond.layer setMasksToBounds:YES];
    [self.mButSecond.layer setCornerRadius:3];
    [self.mButSecond setTitle:strTitle2 forState:UIControlStateNormal];
    
    [self.mButThird.layer setMasksToBounds:YES];
    [self.mButThird.layer setCornerRadius:3];
    [self.mButThird setTitle:strTitle3 forState:UIControlStateNormal];
    
    [self.mButCancel.layer setMasksToBounds:YES];
    [self.mButCancel.layer setCornerRadius:3];

    
    CGRect rtFrame = self.frame;
    
    if ([strTitle2 length] == 0) {
        [self.mButFirst setHidden:YES];
        [self.mButSecond setHidden:YES];
        
        rtFrame.size.height = 155;
    }
    else if ([strTitle1 length] == 0) {
        [self.mButFirst setHidden:YES];
        
        rtFrame.size.height = 212;
    }

    rtFrame.size.width = parentView.frame.size.width;
    
    
//    // shadow on view
//    CGRect rtShadow = self.bounds;
//    rtShadow.size.height = 1;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rtShadow];
//    self.layer.masksToBounds = NO;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0.0f, -2.0f);
//    self.layer.shadowOpacity = 0.3f;
//    self.layer.shadowPath = shadowPath.CGPath;
    
    // add popup view
    mPopupView = [[UIView alloc] initWithFrame:parentView.frame];
    [mPopupView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    
    rtFrame.origin.y = parentView.frame.size.height;
    [self setFrame:rtFrame];
    
    [mPopupView setAlpha:0];
    [parentView addSubview:mPopupView];
    
    [parentView addSubview:self];
}

- (void)setFirstTitle:(NSString *)strTitle
{
    [self.mButFirst setTitle:strTitle forState:UIControlStateNormal];
}

- (void)setSecondTitle:(NSString *)strTitle
{
    [self.mButSecond setTitle:strTitle forState:UIControlStateNormal];
}

- (void)setThirdTitle:(NSString *)strTitle
{
    [self.mButThird setTitle:strTitle forState:UIControlStateNormal];
}


- (void)showView {
    
    if (mbIsShowing) {
        return;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rt = self.frame;
                         rt.origin.y -= self.frame.size.height;
                         self.frame = rt;
                         [mPopupView setAlpha:0.2];
                     }completion:^(BOOL finished) {
                         //						 self.view.userInteractionEnabled = YES;
                     }];
    
    mbIsShowing = YES;
}

- (IBAction)onButFirst:(id)sender {
    if (self.delegate) {
        [self.delegate onButFirst:self];
    }
    
    [self onButCancel:sender];
}

- (IBAction)onButSecond:(id)sender {
    if (self.delegate) {
        [self.delegate onButSecond:self];
    }
    
    [self onButCancel:sender];
}

- (IBAction)onButThird:(id)sender {
    if (self.delegate) {
        [self.delegate onButThird:self];
    }
    
    [self onButCancel:sender];
}


- (IBAction)onButCancel:(id)sender {
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rt = self.frame;
                         rt.origin.y += self.frame.size.height;
                         self.frame = rt;
                         [mPopupView setAlpha:0];
                     }completion:^(BOOL finished) {
                         if (self.mbRemoveOnCancel) {
                             [mPopupView removeFromSuperview];
                             [self removeFromSuperview];
                         }
                     }];
    
    mbIsShowing = NO;
}



@end
