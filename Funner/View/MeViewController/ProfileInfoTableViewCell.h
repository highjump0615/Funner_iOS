//
//  ProfileInfoTableViewCell.h
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import <UIKit/UIKit.h>

@class AVUser;
@class UserData;


@interface ProfileInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblPostNum;
@property (weak, nonatomic) IBOutlet UILabel *mLblChannelNum;
@property (weak, nonatomic) IBOutlet UILabel *mLblFriendNum;

@property (weak, nonatomic) IBOutlet UILabel *mLblAbout;

@property (weak, nonatomic) IBOutlet UIButton *mButEdit;

@property (weak, nonatomic) IBOutlet UIButton *mButGrid;
@property (weak, nonatomic) IBOutlet UIButton *mButList;
@property (weak, nonatomic) IBOutlet UIButton *mButFavourite;
@property (weak, nonatomic) IBOutlet UIButton *mButFriend;

- (void)fillContent:(UserData *)user;

@end
