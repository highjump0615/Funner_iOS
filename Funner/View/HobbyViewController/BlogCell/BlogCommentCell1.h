//
//  BlogCommentCell1.h
//  Funner
//
//  Created by highjump on 15-3-28.
//
//

#import <UIKit/UIKit.h>

@class BlogData;
@class TTTAttributedLabel;

@interface BlogCommentCell1 : UITableViewCell

@property (nonatomic) CGFloat mfHeight;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *mLblContent;

- (void)fillContent:(BlogData *)data indexShow:(NSInteger)nIndexShow type:(int)commentType forHeight:(BOOL)bForHeight;

@end
