//
//  EffectItemView.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "EffectItemView.h"

@implementation EffectItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (id)itemView {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EffectItem" owner:nil options:nil];
    EffectItemView *view = [[EffectItemView alloc] init];
    view = (EffectItemView *)[nib objectAtIndex:0];
    
    return view;
}

@end
