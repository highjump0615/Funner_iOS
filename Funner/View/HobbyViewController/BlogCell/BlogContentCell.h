//
//  BlogHeaderCell.h
//  Funner
//
//  Created by highjump on 14-12-3.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@protocol BlogContentDelegate
- (void)touchedTagView;
@end

@interface BlogContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButPhoto;
@property (weak, nonatomic) IBOutlet UIButton *mButName;

@property (strong) id <BlogContentDelegate> mContentDelegate;

- (void)fillContent:(BlogData *)data forHeight:(BOOL)bForHeight;
- (void)showHashTag:(BOOL)bAnimation;
- (void)splashHashTag;
- (void)showBlogImage:(BlogData *)data;

@end
