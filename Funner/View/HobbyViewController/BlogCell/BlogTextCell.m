//
//  BlogTextCell.m
//  Funner
//
//  Created by highjump on 15-3-29.
//
//

#import "BlogTextCell.h"
#import "BlogData.h"

@interface BlogTextCell()

@property (weak, nonatomic) IBOutlet UILabel *mLblText;

@end

@implementation BlogTextCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(BlogData *)data forHeight:(BOOL)bForHeight {
    //
    // set text
    //
    if (bForHeight) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat fLabelWidth = screenWidth - 50;
        
        CGSize constrainedSize = CGSizeMake(fLabelWidth, 9999);
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:data.text attributes:attributesDictionary];
        
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        self.mfHeight = 1;
        self.mfHeight += ceil(requiredHeight.size.height) + 20;
    }
    else {
        [self.mLblText setText:data.text];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    //    [self.contentView setNeedsLayout];
    //    [self.contentView layoutIfNeeded];
    
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.mLblText.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblText.frame);
}


@end
