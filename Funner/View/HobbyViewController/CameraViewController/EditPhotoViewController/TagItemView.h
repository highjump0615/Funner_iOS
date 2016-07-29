//
//  TagItemView.h
//  Funner
//
//  Created by highjump on 14-11-26.
//
//

#import <UIKit/UIKit.h>

@class HashTagData;

@protocol TagItemViewDelegate <NSObject>

- (void)addHashTag:(HashTagData *)tagData;

@end


@interface TagItemView : UIView

@property (strong) id <TagItemViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *mButTag;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewCircle;

+ (id)itemView:(CGPoint)point Tag:(NSString *)strTag;
- (CGPoint)setPosition:(CGPoint)point difference:(CGSize)szDiff;
- (CGPoint)getCenterPos;

@end
