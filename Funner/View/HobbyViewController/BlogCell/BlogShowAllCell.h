//
//  BlogShowAllCell.h
//  Funner
//
//  Created by highjump on 15-3-28.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@interface BlogShowAllCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButShowAll;

- (void)fillContent:(BlogData *)data type:(int)commentType;

@end
