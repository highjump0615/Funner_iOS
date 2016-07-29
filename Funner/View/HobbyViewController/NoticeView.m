//
//  NoticeView.m
//  Funner
//
//  Created by highjump on 15-4-4.
//
//

#import "NoticeView.h"

@interface NoticeView()

@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;

@end

@implementation NoticeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setMessage:(NSString *)strMsg {
    [self.mLblContent setText:strMsg];
}

@end
