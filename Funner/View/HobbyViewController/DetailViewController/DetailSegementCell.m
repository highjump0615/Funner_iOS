//
//  DetailSegementCell.m
//  Funner
//
//  Created by highjump on 15-3-29.
//
//

#import "DetailSegementCell.h"
#import "BlogData.h"
#import "CommonUtils.h"
#import "NotificationData.h"

@interface DetailSegementCell()


@end


@implementation DetailSegementCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(BlogData *)data type:(int)nCommentType {
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mButComment setTitleColor:utils.mColorDarkGray forState:UIControlStateNormal];
    [self.mButSuggest setTitleColor:utils.mColorDarkGray forState:UIControlStateNormal];
    
    [self.mButComment setTitle:[NSString stringWithFormat:@"欣赏(%lu)", (unsigned long)[data.maryCommentData count]] forState:UIControlStateNormal];
    [self.mButSuggest setTitle:[NSString stringWithFormat:@"建议(%lu)", (unsigned long)[data.marySuggestData count]] forState:UIControlStateNormal];
    
    if (nCommentType == NOTIFICATION_COMMENT) {
        [self.mButComment setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
    }
    else if (nCommentType == NOTIFICATION_SUGGEST) {
        [self.mButSuggest setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
    }
}

@end
