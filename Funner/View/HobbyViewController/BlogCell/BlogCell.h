//
//  BlogRelationCell.h
//  Funner
//
//  Created by highjump on 14-12-3.
//
//

#import <UIKit/UIKit.h>
#import "BlogContentCell.h"

@class BlogData;

@protocol BlogCellDelegate
- (void)onLikeResult:(BOOL)bResult;
@end


@interface BlogCell : BlogContentCell

//@property (weak, nonatomic) IBOutlet UIButton *mButLike;
//@property (weak, nonatomic) IBOutlet UIButton *mButComment;
//@property (weak, nonatomic) IBOutlet UIButton *mButChat;

- (void)fillContent:(BlogData *)data forHeight:(BOOL)bForHeight;

@property (strong) id <BlogCellDelegate> delegate;

@end
