//
//  HashTagView.h
//  Funner
//
//  Created by highjump on 14-11-26.
//
//

#import <UIKit/UIKit.h>

@class HashTagData;
@class TagItemView;

@protocol HashTagViewDelegate <NSObject>

- (void)addHashTag:(HashTagData *)tagData;

@end


@interface HashTagView : UIView

@property (strong) NSMutableArray *maryTag;
@property (strong) id <HashTagViewDelegate> delegate;

- (void)initWithDelegate:(id<HashTagViewDelegate>)delegate;
- (TagItemView *)addNewTag:(NSString *)strTag point:(CGPoint)touchPoint;

@end
