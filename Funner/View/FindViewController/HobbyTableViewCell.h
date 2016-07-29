//
//  HobbyTableViewCell.h
//  Funner
//
//  Created by highjump on 15-3-27.
//
//

#import <UIKit/UIKit.h>

@class CategoryData;

@interface HobbyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblDetail;

- (void)showCategoryInfo:(CategoryData *)cData;


@end
