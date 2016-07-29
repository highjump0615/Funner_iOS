//
//  NotificationTableViewCell.h
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import <UIKit/UIKit.h>

@class NotificationData;

@interface NotificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mImgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;

@property (weak, nonatomic) IBOutlet UILabel *mLblDesc;
@property (weak, nonatomic) IBOutlet UIImageView *mImgLike;

@property (weak, nonatomic) IBOutlet UILabel *mLblTime;
@property (weak, nonatomic) IBOutlet UIImageView *mImgThumb;

- (void)fillContent:(NotificationData *)data;

@end
