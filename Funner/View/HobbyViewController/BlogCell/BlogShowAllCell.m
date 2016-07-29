//
//  BlogShowAllCell.m
//  Funner
//
//  Created by highjump on 15-3-28.
//
//

#import "BlogShowAllCell.h"
#import "BlogData.h"
#import "NotificationData.h"

@interface BlogShowAllCell()

@end

@implementation BlogShowAllCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(BlogData *)data type:(int)commentType {
    
    NSString *strTitle = @"";
    
    if (commentType == NOTIFICATION_COMMENT) {
        strTitle = [NSString stringWithFormat:@"查看全部%lu条欣赏", (unsigned long)[data.maryCommentData count]];
    }
    else if (commentType == NOTIFICATION_SUGGEST) {
        strTitle = [NSString stringWithFormat:@"查看全部%lu条建议", (unsigned long)[data.marySuggestData count]];
    }
    
    [self.mButShowAll setTitle:strTitle forState:UIControlStateNormal];
}

@end
