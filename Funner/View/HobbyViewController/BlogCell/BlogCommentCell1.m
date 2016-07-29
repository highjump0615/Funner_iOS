//
//  BlogCommentCell1.m
//  Funner
//
//  Created by highjump on 15-3-28.
//
//

#import "BlogCommentCell1.h"
#import "TTTAttributedLabel.h"
#import "BlogData.h"
#import "NotificationData.h"
#import "UserData.h"
#import "CommonUtils.h"

@interface BlogCommentCell1()

@property (weak, nonatomic) IBOutlet UIImageView *mImgIcon;

@end

@implementation BlogCommentCell1

- (void)awakeFromNib {
    // Initialization code
    UIColor *colorButton = [UIColor colorWithRed:0/255.0 green:89/255.0 blue:130/255.0 alpha:1.0];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setValue:(__bridge id)[colorButton CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.mLblContent.linkAttributes = mutableLinkAttributes;
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionaryWithDictionary:mutableLinkAttributes];
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor redColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.mLblContent.activeLinkAttributes = mutableActiveLinkAttributes;
    
    [self.mLblContent setFont:[UIFont systemFontOfSize:13]];
    
    self.mLblContent.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    self.mfHeight = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(BlogData *)data indexShow:(NSInteger)nIndexShow type:(int)commentType forHeight:(BOOL)bForHeight {
    
    NotificationData *notifyData;
    NSArray *aryComment;
    if (commentType == NOTIFICATION_COMMENT) {
        aryComment = data.maryCommentData;
        [self.mImgIcon setImage:[UIImage imageNamed:@"home_like_gray.png"]];
    }
    else if (commentType == NOTIFICATION_SUGGEST) {
        aryComment = data.marySuggestData;
        [self.mImgIcon setImage:[UIImage imageNamed:@"home_comment_gray.png"]];
    }
    
    if (!aryComment) {
        return;
    }
    
    NSInteger nDiff = MIN(MAX_SHOW_COMMENT_NUM, [aryComment count]);
    NSInteger nIndexReal = [aryComment count] - nDiff + nIndexShow;
    notifyData = [aryComment objectAtIndex:nIndexReal];
    
    if (nIndexShow > 0) {
        [self.mImgIcon setHidden:YES];
    }
    else {
        [self.mImgIcon setHidden:NO];
    }
    
    if (!notifyData) {
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    //
    // set comment text
    //
    NSString *strComment;
    NSMutableString *strCommentTotal = [NSMutableString stringWithString:@""];
    
    strComment = [NSString stringWithFormat:@"%@: ", [notifyData.user getUsernameToShow]];
    [strCommentTotal appendString:strComment];
    [strCommentTotal appendString:notifyData.comment];
    
    if (bForHeight) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat fLabelWidth = screenWidth - 83;
        
        CGSize constrainedSize = CGSizeMake(fLabelWidth, 9999);
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:13.0], NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:strCommentTotal attributes:attributesDictionary];
        
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        self.mfHeight = ceil(requiredHeight.size.height) + 6;
        
        
        
        if ([aryComment count] <= MAX_SHOW_COMMENT_NUM) {
            if (nIndexShow == [aryComment count] - 1) {
                self.mfHeight += 10;
            }
        }
    }
    else {
        //
        // set attributes
        //
        [self.mLblContent setText:strCommentTotal afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            return mutableAttributedString;
        }];
        
        //
        // set links
        //
        dict[@"user"] = notifyData.user;
        [self.mLblContent addLinkToTransitInformation:dict withRange:NSMakeRange(0, [strComment length])];
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
    self.mLblContent.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblContent.frame);
}


@end
