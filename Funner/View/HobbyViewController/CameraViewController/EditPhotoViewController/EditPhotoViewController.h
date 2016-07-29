//
//  EditPhotoViewController.h
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@protocol EditPhotoViewDelegate
- (void)addBlog:(BlogData *)blogData;
@end

@interface EditPhotoViewController : UIViewController

@property (nonatomic, retain) UIImage *mImgPhoto;
@property (nonatomic, retain) UIImage *mImgThumbPhoto;

@property (strong) id <EditPhotoViewDelegate> delegate;

@end
