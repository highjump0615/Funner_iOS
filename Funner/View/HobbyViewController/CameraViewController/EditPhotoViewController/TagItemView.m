//
//  TagItemView.m
//  Funner
//
//  Created by highjump on 14-11-26.
//
//

#import "TagItemView.h"
#import "HashTagData.h"

#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

@interface TagItemView() <UITextFieldDelegate> {
    float mfQuoWidth;
    float mfTagMargin;
    UITextField *mTxtTag;
    
    float fMinimumTextFieldSize;
    NSString *mstrOldText;
    
    CGPoint mptFrame;
    NSInteger mnMaximumTextLength;
}

@end

@implementation TagItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initialize:(CGPoint)point Tag:(NSString *)strTag {
    //
    // init data
    //
    mfQuoWidth = 5;
    mfTagMargin = 7;
    fMinimumTextFieldSize = 20;
    mstrOldText = @"";
    mptFrame = point;
    mnMaximumTextLength = 10;
    
    //
    // init view
    //
    NSString *placeholderText = NSLocalizedString(@"标签名称",
                                                  @"Tag");
    
    UIFont *textFieldFont = [UIFont systemFontOfSize:13];
    CGSize tagSize;
    if ([strTag length] > 0) {
        tagSize = [strTag sizeWithAttributes:@{NSFontAttributeName:textFieldFont}];
    }
    else {
        tagSize = [placeholderText sizeWithAttributes:@{NSFontAttributeName:textFieldFont}];
    }
    
    CGRect rtFrame = CGRectMake(self.mImgViewCircle.frame.size.width + mfQuoWidth + mfTagMargin,
                                0,
                                tagSize.width + 7,
                                self.frame.size.height);
    mTxtTag = [[UITextField alloc] initWithFrame:rtFrame];
    [mTxtTag setPlaceholder:placeholderText];
    [mTxtTag setTextColor:[UIColor whiteColor]];
    [mTxtTag setReturnKeyType:UIReturnKeyDone];
    [mTxtTag setAutocorrectionType:UITextAutocorrectionTypeNo];
    [mTxtTag setFont:textFieldFont];
    [mTxtTag setDelegate:self];
    
    if ([strTag length] > 0) {
        [mTxtTag setText:strTag];
        [mTxtTag setUserInteractionEnabled:NO];
    }
    
    UIColor *color = [UIColor colorWithWhite:0.7 alpha:1];
    NSAttributedString *strPlaceholder = [[NSAttributedString alloc] initWithString:@"标签名称"
                                                                         attributes:@{NSForegroundColorAttributeName: color,
                                                                                      NSFontAttributeName: textFieldFont}];
    mTxtTag.attributedPlaceholder = strPlaceholder;
    
    [self addSubview:mTxtTag];
    [mTxtTag becomeFirstResponder];
    
    [self updateFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tagTextFieldDidChangeWithNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)stopObservations
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self stopObservations];
}

- (void)updateFrame {
    CGRect rtFrame = self.frame;
    
    if (!CGPointEqualToPoint(mptFrame, CGPointZero)) {
        rtFrame.origin.x = mptFrame.x - self.mImgViewCircle.frame.size.width / 2;
        rtFrame.origin.y = mptFrame.y - rtFrame.size.height / 2;
    }
    rtFrame.size.width = self.mImgViewCircle.frame.size.width + mfQuoWidth + mfTagMargin + mTxtTag.frame.size.width + mfTagMargin - 7;
    
    [self setFrame:rtFrame];
    
    [self setNeedsDisplay];
}

- (void)tagTextFieldDidChangeWithNotification:(NSNotification *)aNotification
{
    //resize, reposition
    if(aNotification.object == mTxtTag){
        [self resizeTextField];
    }
}

+ (id)itemView:(CGPoint)point Tag:(NSString *)strTag {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TagItem" owner:nil options:nil];
    TagItemView *view = [[TagItemView alloc] init];
    view = (TagItemView *)[nib objectAtIndex:0];
    [view initialize:point Tag:strTag];
    
    return view;
}

- (CGPoint)setPosition:(CGPoint)point difference:(CGSize)szDiff {
    mptFrame = CGPointMake(point.x - szDiff.width, point.y - szDiff.height);
    mptFrame = [self getCorrectPos:mptFrame];
    [self updateFrame];
    
    return mptFrame;
}

- (CGPoint)getCorrectPos:(CGPoint)point {
    point.x += self.mImgViewCircle.frame.size.width / 2;
    point.y += self.frame.size.height / 2;
    
    return point;
}

- (CGPoint)getCenterPos {
    return [self getCorrectPos:self.frame.origin];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    float height = rect.size.height;
    float width = rect.size.width;
    
    float tagLength = self.mImgViewCircle.frame.size.width + mfQuoWidth;
    float radius = 3;
    
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    [aPath moveToPoint:(CGPoint){width, height / 2}];
    [aPath addLineToPoint:CGPointMake(width, radius)];
    [aPath addArcWithCenter:(CGPoint){width - radius, radius} radius:radius startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(270) clockwise:NO];
    [aPath addLineToPoint:(CGPoint){tagLength + radius, 0.0}];
    [aPath addArcWithCenter:(CGPoint){tagLength + radius, radius} radius:radius startAngle:DEGREES_TO_RADIANS(270) endAngle:DEGREES_TO_RADIANS(180) clockwise:NO];
    [aPath addLineToPoint:(CGPoint){tagLength, height / 2 - mfQuoWidth}];
    [aPath addLineToPoint:(CGPoint){tagLength - mfQuoWidth, height / 2}];
    
    UIBezierPath *p2 = [UIBezierPath bezierPathWithCGPath:aPath.CGPath];
    [p2 applyTransform:CGAffineTransformMakeScale(1, -1)];
    [p2 applyTransform:CGAffineTransformMakeTranslation(0, height)];
    [aPath appendPath:p2];
    
    // Set the render colors.
    [fillColor setFill];
    [aPath fill];
}

- (void)resizeTextField
{
    CGSize newTagSize = CGSizeZero;
    if (mTxtTag.text && ![mTxtTag.text isEqualToString:@""]){
        newTagSize = [mTxtTag.text sizeWithAttributes:@{NSFontAttributeName: mTxtTag.font}];
        
    } else if (mTxtTag.placeholder && ![mTxtTag.placeholder isEqualToString:@""]){
        newTagSize = [mTxtTag.placeholder sizeWithAttributes:@{NSFontAttributeName: mTxtTag.font}];
    }

    if (mTxtTag.isFirstResponder){
        //This gives some extra room for the cursor.
        newTagSize.width += 10;
    }
    
    CGRect newTextFieldFrame = mTxtTag.frame;
    
    newTextFieldFrame.size.width = MAX(newTagSize.width, fMinimumTextFieldSize);
    [mTxtTag setFrame:newTextFieldFrame];
    
    [self updateFrame];
    
    mstrOldText = mTxtTag.text;
}


#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    BOOL result = NO;
    
    if (textField == mTxtTag){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if((!mnMaximumTextLength) || (newLength <= mnMaximumTextLength)){
            result = YES;
        }
    }
    
    return result;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == mTxtTag){
        [mTxtTag setUserInteractionEnabled:NO];
        
        [self.mButTag setHidden:NO];
        
        if ([textField.text length] > 0) {
            if (self.delegate) {
                HashTagData *tagData = [[HashTagData alloc] init];
                tagData.mptPos = [self getCorrectPos:mptFrame];
                tagData.mstrTag = textField.text;
                tagData.mviewTag = self;
                [self.delegate addHashTag:tagData];
            }
        }
        else {
            [self removeFromSuperview];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == mTxtTag){
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)isFirstResponder
{
    return mTxtTag.isFirstResponder;
}


@end
