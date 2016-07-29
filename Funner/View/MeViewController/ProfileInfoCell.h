//
//  ProfileInfoCell.h
//  Funner
//
//  Created by highjump on 15-4-3.
//
//

#import <UIKit/UIKit.h>

@class UserData;

@interface ProfileInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mLblPostNum;
@property (weak, nonatomic) IBOutlet UILabel *mLblChannelNum;

@property (weak, nonatomic) IBOutlet UIButton *mButEdit;

- (void)fillContent:(UserData *)user;

@end
