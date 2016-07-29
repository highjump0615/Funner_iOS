//
//  FullImageView.h
//  Funner
//
//  Created by highjump on 15-1-11.
//
//

#import <UIKit/UIKit.h>

@interface FullImageView : UIView

+ (id)initView:(UIView *)parentView;
- (void)showView:(CGRect)frameFrom url:(NSString *)strUrl;

@end
