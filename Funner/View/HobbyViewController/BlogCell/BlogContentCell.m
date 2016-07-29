//
//  BlogHeaderCell.m
//  Funner
//
//  Created by highjump on 14-12-3.
//
//

#import "BlogContentCell.h"
#import "BlogData.h"
#import "CommonUtils.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "UserData.h"
#import "TagItemView.h"
#import "HashTagData.h"


@interface BlogContentCell() {
    BlogData *mBlogData;
    BlogData *mBlogDataShown;
    
    BOOL mbShowTag;
}

@property (weak, nonatomic) IBOutlet UILabel *mLblDate;
@property (weak, nonatomic) IBOutlet UILabel *mLblPopular;

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstImgViewPhotoHeight;

@property (weak, nonatomic) IBOutlet UIView *mViewHashTag;


@end


@implementation BlogContentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showUserPhoto:(AVFile *)filePhoto {
    [self.mButPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                              forState:UIControlStateNormal
                      placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
}

- (void)showUserInfo:(UserData *)user {
    [self showUserPhoto:user[@"photo"]];
    [self.mButName setTitle:[user getUsernameToShow] forState:UIControlStateNormal];
}

- (void)fillContent:(BlogData *)data forHeight:(BOOL)bForHeight {
    
    double dRadius = self.mButPhoto.frame.size.height / 2;
    [self.mButPhoto.layer setMasksToBounds:YES];
    [self.mButPhoto.layer setCornerRadius:dRadius];
    
    if (!data.user) {
        return;
    }

    //
    // user info
    //
    UserData *userInfo = data.user;
    
    if (userInfo.createdAt) {
        [self showUserInfo:userInfo];
    }
    else {
        [userInfo fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            [self showUserInfo:userInfo];
        }];
        
        [self.mButName setTitle:data.username forState:UIControlStateNormal];
    }

    //
    // date
    //
    NSString *strTime = [CommonUtils getTimeString:data.createdAt];
    [self.mLblDate setText:strTime];
    
    //
    // relation
    //
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mLblPopular setHidden:YES];
    
//    NSLog(@"popularity: %f", [data.popularity floatValue]);
    
    if ([data.popularity floatValue] > 0 && [data.popularity floatValue] <= utils.mfBlogPopularity) {
        [self.mLblPopular setHidden:NO];
    }
    
    //
    // blog image
    //
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    [self.mCstImgViewPhotoHeight setConstant:screenWidth];
    
    // add tap recognizer to show/hide tags
    if ([self.mViewHashTag.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(didRecognizeSingleTap:)];
        [singleTapRecognizer setNumberOfTapsRequired:1];
        [self.mViewHashTag addGestureRecognizer:singleTapRecognizer];
    }
    
    if (!bForHeight) {
        mBlogData = data;
    }
}

- (void)showBlogImage:(BlogData *)data {
    
    if (!data || !data.image) {
        return;
    }
    
    //
    // content image
    //
    if (![mBlogDataShown isEqual:data]) {
    
        [self.mImgViewPhoto sd_setImageWithURL:[NSURL URLWithString:data.image.url]
                              placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
        
        //
        // hash tags
        //
        mbShowTag = NO;
        
        // remove all subobjects
        for (UIView *subview in [self.mViewHashTag subviews]) {
            if ([subview isKindOfClass:[TagItemView class]]) {
                TagItemView *tagView = (TagItemView*)subview;
                for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                    [subview removeGestureRecognizer:gesture];
                }
                
                [tagView.mButTag removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
            }
            [subview removeFromSuperview];
        }
        
        // add tags
        for (HashTagData *tData in data.maryHashTag) {
            if (tData.mviewTag) {
                [tData.mviewTag removeFromSuperview];
            }
            
            TagItemView *tagitemView = [TagItemView itemView:tData.mptPos Tag:tData.mstrTag];
            [self.mViewHashTag addSubview:tagitemView];
            
            tData.mviewTag = tagitemView;
        }
        
        if (!mBlogData.mbSplashingTag) {
            [self showHashTag:NO];
        }
        
        [self splashHashTag];

        mBlogDataShown = data;
    }
    
    //    if (mbShowTag != bShow) {
    //        [UIView animateWithDuration:0.5
    //                         animations:^{
    //                             if (bShow) {
    //                                 [self setHashTagOpacity:1.0];
    //                             }
    //                             else {
    //                                 [self setHashTagOpacity:0.0];
    //                             }
    //
    //                             mbShowTag = bShow;
    //                         }completion:^(BOOL finished) {
    //                             //						 self.view.userInteractionEnabled = YES;
    //                         }];
    //    }
    //    else {
    //        if (!mbShowTag) {
    //            [self setHashTagOpacity:0.0];
    //        }
    //    }
    
}

- (void)didRecognizeSingleTap:(id)sender {
    mbShowTag = !mbShowTag;
    [self showHashTag:YES];
    
    if (self.mContentDelegate) {
        [self.mContentDelegate touchedTagView];
    }
}

- (void)showHashTag:(BOOL)bAnimation {
    if (!mBlogData) {
        return;
    }
    
    for (HashTagData *tData in mBlogData.maryHashTag) {
        
        if (bAnimation) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 if (mbShowTag) {
                                     [tData.mviewTag setAlpha:1.0];
                                 }
                                 else {
                                     [tData.mviewTag setAlpha:0.0];
                                 }

                             }completion:^(BOOL finished) {
                                 //						 self.view.userInteractionEnabled = YES;
                             }];
        }
        else {
            if (mbShowTag) {
                [tData.mviewTag setAlpha:1.0];
            }
            else {
                [tData.mviewTag setAlpha:0.0];
            }
        }
    }
}

- (void)splashHashTag {
    
    if (!mBlogData) {
        return;
    }
    
    if (!mBlogData.mbShownTag) {
        
        if (!mbShowTag) {
            
            mbShowTag = YES;
            [self showHashTag:YES];
            
            //            NSLog(@"%s", __PRETTY_FUNCTION__);
            
            [self performSelector:@selector(hideSplashHashTag) withObject:nil afterDelay:2];
            
            mBlogData.mbShownTag = YES;
            mBlogData.mbSplashingTag = YES;
        }
    }
}

- (void)hideSplashHashTag {
    mbShowTag = NO;
    mBlogData.mbSplashingTag = NO;
    
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self showHashTag:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // shadow on view
    CGRect rtShadow = self.mImgViewPhoto.bounds;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rtShadow];
    self.mImgViewPhoto.layer.masksToBounds = NO;
    self.mImgViewPhoto.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mImgViewPhoto.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.mImgViewPhoto.layer.shadowOpacity = 0.3f;
    self.mImgViewPhoto.layer.shadowPath = shadowPath.CGPath;
    
    [self showBlogImage:mBlogData];
}



@end
