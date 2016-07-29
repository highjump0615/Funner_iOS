//
//  ProfileBlogGridCell.h
//  Funner
//
//  Created by highjump on 15-4-3.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@interface ProfileBlogGridCell : UITableViewCell

//@property (nonatomic, strong) UIImageView *mImgBlog;
//@property (nonatomic, strong) UIButton *mButton;

@property (nonatomic, weak) IBOutlet UIImageView *mImgBlog;
@property (nonatomic, weak) IBOutlet UIButton *mButton;

- (void)fillContent:(BlogData *)bData totalCount:(NSInteger)nTotalCount;

@end
