//
//  FriendTableViewCell.h
//  Funner
//
//  Created by highjump on 14-12-19.
//
//

#import <UIKit/UIKit.h>

@class UserData;

@protocol FriendCellDelegate
- (void)onShieldResult:(BOOL)bResult user:(UserData *)uData;
@end


@interface FriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButShield;

@property (strong) id <FriendCellDelegate> delegate;

- (void)fillContent:(UserData *)user;

@end
