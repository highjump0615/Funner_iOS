//
//  LoadingView.m
//  Funner
//
//  Created by highjump on 14-12-11.
//
//

#import "LoadingView.h"

@interface LoadingView()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mIndicator;

@end

@implementation LoadingView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [self.mIndicator startAnimating];
}

+ (id)loadingView {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:nil options:nil];
    LoadingView *view = [[LoadingView alloc] init];
    view = (LoadingView *)[nib objectAtIndex:0];
    
    return view;
}


@end
