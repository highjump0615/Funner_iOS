//
//  HobbyTableViewCell.m
//  Funner
//
//  Created by highjump on 15-3-27.
//
//

#import "HobbyTableViewCell.h"
#import "CategoryData.h"

@implementation HobbyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showCategoryInfo:(CategoryData *)cData {
    
    //    // show category icon
    //    NSString *strName = [NSString stringWithFormat:@"%@_icon.png", cData.name];
    //    UIImage *imgIcon = [UIImage imageNamed:strName];
    //
    //    if (imgIcon) {
    //        [self.mImageView setImage:imgIcon];
    //    }
    //    else {
    //        [self.mImageView sd_setImageWithURL:[NSURL URLWithString:cData.icon.url]
    //                           placeholderImage:[UIImage imageNamed:@"home_hobby_sample.png"]];
    //    }
    
    
    [self.mLblTitle setText:cData.name];
    [self.mLblDetail setText:@""];
    
    //    [self.mConstraintLineHeight setConstant:0.5];
    //    [self layoutIfNeeded];
    
    //    if (self.mViewRedDot) {
    //        double dRadius = self.mViewRedDot.frame.size.height / 2;
    //        [self.mViewRedDot.layer setMasksToBounds:YES];
    //        [self.mViewRedDot.layer setCornerRadius:dRadius];
    //
    //        [self.mViewRedDot setHidden:YES];
    //
    //        if (cData.mbGotLatest && cData.mbGotNetworkLatest) {
    //            if (!cData.mBlogLatest && cData.mBlogNetworkLatest) {
    //                [self.mViewRedDot setHidden:NO];
    //            }
    //            else if (cData.mBlogLatest && cData.mBlogNetworkLatest) {
    //                if ([cData.mBlogLatest.createdAt compare:cData.mBlogNetworkLatest.createdAt] == NSOrderedAscending) {
    //                    [self.mViewRedDot setHidden:NO];
    //                }
    //            }
    //        }
    //    }
}


@end
