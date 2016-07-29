//
//  ProfileBlogCell.m
//  Funner
//
//  Created by highjump on 15-4-3.
//
//

#import "ProfileBlogCell.h"

#import "CommonUtils.h"

#import "CategoryData.h"

@interface ProfileBlogCell()


@end

@implementation ProfileBlogCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(CategoryData *)cData {
    if (!self.mTableView) {
        CGFloat fWidth, fHeight;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        fWidth = screenWidth - 15 * 2;
        fHeight = fWidth / 4.0f - 5;
        
        self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 40 + fHeight, fHeight, fWidth)];
        
        [self.mTableView.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
        [self.mTableView setTransform:CGAffineTransformMakeRotation(M_PI/-2)];
        
        [self.mTableView setFrame:CGRectMake(15, 40 + fHeight, fWidth, fHeight)];
        [self.mTableView setShowsVerticalScrollIndicator:NO];
        [self.mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [self.contentView addSubview:self.mTableView];
    }
    
    if (!cData) {
        return;
    }
    
    NSMutableString *strTitle = [NSMutableString stringWithString:@""];
    if (cData.parent) {
        // get parent category from category list
        CommonUtils *utils = [CommonUtils sharedObject];
        CategoryData *cParentData;

        for (CategoryData *ctData in utils.maryCategory) {
            if (!ctData.parent && [ctData.objectId isEqualToString:cData.parent.objectId]) {
                cParentData = ctData;
            }
        }
        
        if (cParentData) {
            [strTitle appendString:[NSString stringWithFormat:@"%@ - ", cParentData.name]];
        }
    }
    [strTitle appendString:cData.name];
    
    if (cData.mbShowedAll) {
        [self.mTableView setBounces:YES];
    }
    else {
        [self.mTableView setBounces:NO];
    }
    
    [self.mLblFavorite setText:strTitle];
}


@end
