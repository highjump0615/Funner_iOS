//
//  BlogCategoryCell.h
//  Funner
//
//  Created by highjump on 15-2-13.
//
//

#import <UIKit/UIKit.h>

@class CategoryData;

@interface BlogCategoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButCategory;

- (void)fillContent:(CategoryData *)cData;

@end
