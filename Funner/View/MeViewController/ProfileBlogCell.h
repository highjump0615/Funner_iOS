//
//  ProfileBlogCell.h
//  Funner
//
//  Created by highjump on 15-4-3.
//
//

#import <UIKit/UIKit.h>

@class CategoryData;

@interface ProfileBlogCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mLblFavorite;
@property (nonatomic, strong) UITableView *mTableView;

- (void)fillContent:(CategoryData *)cData;

@end
