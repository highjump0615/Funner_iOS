//
//  ChatTableViewCell.h
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import <UIKit/UIKit.h>

@class UserData;

@interface ChatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;
@property (weak, nonatomic) IBOutlet UILabel *mLblDesc;
@property (weak, nonatomic) IBOutlet UILabel *mLblBadge;
@property (weak, nonatomic) IBOutlet UILabel *mLblTime;

- (void)fillContent:(UserData *)data;

@end
