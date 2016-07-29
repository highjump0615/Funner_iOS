//
//  ProfileBlogGridCell.m
//  Funner
//
//  Created by highjump on 15-4-3.
//
//

#import "ProfileBlogGridCell.h"

#import "BlogData.h"

#import "UIImageView+WebCache.h"


@implementation ProfileBlogGridCell

- (void)awakeFromNib {
    // Initialization code
    
    self.contentView.transform = CGAffineTransformMakeRotation(M_PI/2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(BlogData *)bData totalCount:(NSInteger)nTotalCount {
//    if (!self.mImgBlog) {
//        self.mImgBlog = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, self.frame.size.width, self.frame.size.width)];
//        [self.mImgBlog setClipsToBounds:YES];
//        [self.mImgBlog setContentMode:UIViewContentModeScaleAspectFit];
//        [self.mImgBlog setImage:[UIImage imageNamed:@"photo_sample.png"]];
//        
//        self.mButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, self.frame.size.width, self.frame.size.width)];
//        
//        [self.contentView addSubview:self.mImgBlog];
//        [self.contentView addSubview:self.mButton];
//    }

    [self.mImgBlog sd_setImageWithURL:[NSURL URLWithString:bData.thumbnail.url]
                     placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
    
    if (nTotalCount > 0) {
        [self.mButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [self.mButton setTitle:[NSString stringWithFormat:@"共%ld张", (long)nTotalCount] forState:UIControlStateNormal];
    }
    else {
        [self.mButton setBackgroundColor:[UIColor clearColor]];
        [self.mButton setTitle:@"" forState:UIControlStateNormal];
    }
}



@end
