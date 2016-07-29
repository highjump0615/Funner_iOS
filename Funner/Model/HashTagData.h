//
//  HashTagData.h
//  Funner
//
//  Created by highjump on 14-11-27.
//
//

#import <Foundation/Foundation.h>

@class TagItemView;

@interface HashTagData : NSObject

@property (nonatomic, assign) CGPoint mptPos;
@property (nonatomic, strong) NSString *mstrTag;
@property (nonatomic, strong) TagItemView *mviewTag;

- (void)convertPos;
- (void)revertPos;


@end