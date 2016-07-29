//
//  BlogCommentContentCell.h
//  Funner
//
//  Created by highjump on 15-1-24.
//
//

#import <UIKit/UIKit.h>

@class NotificationData;

@interface BlogCommentContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblComment;

- (void)fillContent:(NotificationData *)data;

@end
