//
//  CustomActionSheetView.h
//  Funner
//
//  Created by highjump on 14-11-19.
//
//

#import <UIKit/UIKit.h>

@protocol CustomActionSheetDelegate <NSObject>
@optional
- (void)onButFirst:(UIView *)view;
- (void)onButSecond:(UIView *)view;
- (void)onButThird:(UIView *)view;
@end

@interface CustomActionSheetView : UIView {
    UIView *mPopupView;
    BOOL mbIsShowing;
}

@property (weak, nonatomic) IBOutlet UIButton *mButFirst;
@property (weak, nonatomic) IBOutlet UIButton *mButSecond;
@property (weak, nonatomic) IBOutlet UIButton *mButThird;
@property (weak, nonatomic) IBOutlet UIButton *mButCancel;

@property (strong) id <CustomActionSheetDelegate> delegate;

+ (id)initView:(UIView *)parentView
  ButtonTitle1:(NSString *)strTitle1
  ButtonTitle2:(NSString *)strTitle2
  ButtonTitle3:(NSString *)strTitle3
removeOnCancel:(BOOL)bRemoveOnCancel;

- (void)showView;

- (void)setFirstTitle:(NSString *)strTitle;
- (void)setSecondTitle:(NSString *)strTitle;
- (void)setThirdTitle:(NSString *)strTitle;


@end
