//
//  DetailSegementCell.h
//  Funner
//
//  Created by highjump on 15-3-29.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@interface DetailSegementCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButComment;
@property (weak, nonatomic) IBOutlet UIButton *mButSuggest;


- (void)fillContent:(BlogData *)data type:(int)nCommentType;

@end
