//
//  BlogTextCell.h
//  Funner
//
//  Created by highjump on 15-3-29.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@interface BlogTextCell : UITableViewCell

@property (nonatomic) CGFloat mfHeight;

- (void)fillContent:(BlogData *)data forHeight:(BOOL)bForHeight;

@end
