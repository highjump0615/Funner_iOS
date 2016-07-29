//
//  BlogOperationCell.h
//  Funner
//
//  Created by highjump on 15-3-29.
//
//

#import <UIKit/UIKit.h>

@class BlogData;

@interface BlogOperationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButComment;
@property (weak, nonatomic) IBOutlet UIButton *mButSuggest;
@property (weak, nonatomic) IBOutlet UIButton *mButChat;


- (void)fillContent:(BlogData *)data;

@end
