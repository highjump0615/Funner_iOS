//
//  HashTagView.m
//  Funner
//
//  Created by highjump on 14-11-26.
//
//

#import "HashTagView.h"
#import "TagItemView.h"
#import "HashTagData.h"

@interface HashTagView() <TagItemViewDelegate> {
    CGSize mszDragPtDiff;
    BOOL mbMoved;
    
    UIButton *mbutSelected;
}

@end

@implementation HashTagView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initWithDelegate:(id<HashTagViewDelegate>)delegate {
    
    [self setDelegate:delegate];
    
    self.maryTag = [[NSMutableArray alloc] init];
    
    [self loadTouchGestureRecognizers];
    
}

- (void)loadTouchGestureRecognizers
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(didRecognizeSingleTap:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapRecognizer];
    
    
//    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
//                                                initWithTarget:self
//                                                action:@selector(didRecognizeDoubleTap:)];
//    [doubleTapGesture setNumberOfTapsRequired:2];
//    [self addGestureRecognizer:doubleTapGesture];
//    
//    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
//                                                      initWithTarget:self
//                                                      action:@selector(didRecognizeLongPress:)];
//    [self addGestureRecognizer:longPressGesture];
//    
//    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapGesture];
}

- (TagItemView *)addNewTag:(NSString *)strTag point:(CGPoint)touchPoint {
    TagItemView *tagitemView = [TagItemView itemView:touchPoint Tag:strTag];
    [tagitemView setDelegate:self];
    
    //
    // check whether this view overlaps other tag views
    //
    // get the tag item
    if ([strTag length] > 0) {
        BOOL bOverlap;
        CGRect rtFrame;
        
        do {
            bOverlap = NO;
            rtFrame = tagitemView.frame;
            for (HashTagData *tData in self.maryTag) {
                TagItemView *tView = tData.mviewTag;
                
                if (CGRectIntersectsRect(tagitemView.frame, tView.frame)) {
                    rtFrame.origin.y += tagitemView.frame.size.height + 3;
                    [tagitemView setFrame:rtFrame];
                    bOverlap = YES;
                    break;
                }
            }
            
        } while (bOverlap);

        if (!CGRectContainsRect(self.frame, rtFrame)) {
            return nil;
        }
    }
    
    // drag drop init
    [tagitemView.mButTag addTarget:self action:@selector(tagTouch:withEvent:) forControlEvents:UIControlEventTouchDown];
    [tagitemView.mButTag addTarget:self action:@selector(tagMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [tagitemView.mButTag addTarget:self action:@selector(tagUp:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:tagitemView];
    
    return tagitemView;
}

#pragma mark - Event Hooks

- (void)didRecognizeSingleTap:(id)sender
{
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"Expected notification from a single tap gesture");
    
    UITapGestureRecognizer *tapGesture = sender;
    
    CGPoint touchPoint = [tapGesture locationInView:self];
    CGPoint normalizedPoint = [self normalizedPositionForPoint:touchPoint
                                                            inFrame:[self frame]];
    
    if ([self canTagPhotoAtNormalizedPoint:normalizedPoint]) {
        [self addNewTag:@"" point:touchPoint];
    }
}

- (void)tagTouch:(id)sender withEvent:(UIEvent *)event {
    UIButton *butTag = (UIButton *)sender;
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    
    // get the tag item
    for (HashTagData *tData in self.maryTag) {
        TagItemView *tagItemView = tData.mviewTag;
        if ([tagItemView.mButTag isEqual:butTag]) {
            CGPoint ptCorner = tagItemView.frame.origin;
            mszDragPtDiff = CGSizeMake(point.x - ptCorner.x, point.y - ptCorner.y);
            break;
        }
    }
    
    mbMoved = NO;
}

- (void)tagMoved:(id)sender withEvent:(UIEvent *)event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    
    UIButton *butTag = (UIButton *)sender;

    // get the tag item
    for (HashTagData *tData in self.maryTag) {
        TagItemView *tagItemView = tData.mviewTag;
        if ([tagItemView.mButTag isEqual:butTag]) {
            
            CGPoint normalizedPoint = [self normalizedPositionForPoint:point
                                                               inFrame:[self frame]];
            
            if ([self canTagPhotoAtNormalizedPoint:normalizedPoint]) {
                CGPoint ptNew = [tagItemView setPosition:point difference:mszDragPtDiff];
                tData.mptPos = ptNew;
            }
            break;
        }
    }
    
    mbMoved = YES;
}

- (void)tagUp:(id)sender withEvent:(UIEvent *)event {
    if (mbMoved) {
        return;
    }
    
    mbutSelected = (UIButton *)sender;
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您确定要删除这个标签吗？"
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"删除",nil];
    [alert show];
}

#pragma mark - Alert Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // get the tag item
        for (HashTagData *tData in self.maryTag) {
            TagItemView *tagItemView = tData.mviewTag;
            if ([tagItemView.mButTag isEqual:mbutSelected]) {
                [tagItemView removeFromSuperview];
                [self.maryTag removeObject:tData];
                
                break;
            }
        }
    }
}



#pragma mark -

- (CGPoint)normalizedPositionForPoint:(CGPoint)point inFrame:(CGRect)frame
{
    point.x -= (frame.origin.x - self.frame.origin.x);
    point.y -= (frame.origin.y - self.frame.origin.y);
    
    CGPoint normalizedPoint = CGPointMake(point.x / frame.size.width,
                                          point.y / frame.size.height);
    
    return normalizedPoint;
}

- (BOOL)canTagPhotoAtNormalizedPoint:(CGPoint)normalizedPoint
{
    if((normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0) &&
       (normalizedPoint.y >= 0.0 && normalizedPoint.y <= 1.0)){
        return YES;
    }
    return NO;
}


#pragma mark - TagItemViewDelegate

- (void)addHashTag:(HashTagData *)tagData {
    [self.maryTag addObject:tagData];
    
    if (self.delegate) {
        [self.delegate addHashTag:tagData];
    }
}


@end
