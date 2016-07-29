//
//  InputCommentView.h
//  Funner
//
//  Created by highjump on 15-3-31.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@protocol InputCommentViewDelegate
- (void)onSentComment:(BOOL)bSucceed;
@end


@interface InputCommentView : UIView

@property (strong) BlogData *mBlogData;
@property (nonatomic) int mnCommentType;
@property (weak, nonatomic) IBOutlet UITextField *mTxtComment;

@property (strong) id <InputCommentViewDelegate> delegate;

@end
