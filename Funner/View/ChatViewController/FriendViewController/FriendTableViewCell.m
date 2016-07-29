//
//  FriendTableViewCell.m
//  Funner
//
//  Created by highjump on 14-12-19.
//
//

#import "FriendTableViewCell.h"
#import "UserData.h"
#import "UIImageView+WebCache.h"
#import "CommonUtils.h"

@interface FriendTableViewCell() {
    UserData *mUser;
}

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblName;
@property (weak, nonatomic) IBOutlet UILabel *mLblFavourite;


@end

@implementation FriendTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(UserData *)user {
    
    mUser = user;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mButShield.layer setMasksToBounds:YES];
    [self.mButShield.layer setCornerRadius:5];
    
    [self.mButShield.layer setBorderColor:utils.mColorGray.CGColor];
    
    double dRadius = self.mImgViewPhoto.frame.size.height / 2;
    [self.mImgViewPhoto.layer setMasksToBounds:YES];
    [self.mImgViewPhoto.layer setCornerRadius:dRadius];
    
    [self.mImgViewPhoto sd_setImageWithURL:[NSURL URLWithString:user.photo.url]
                          placeholderImage:[UIImage imageNamed:@"avatar_sample.png"]];
    
    [self.mLblName setText:[user getUsernameToShow]];
    [self.mLblFavourite setText:[user getCategoryString]];
    
    
    // button
    UserData *currentUser = [UserData currentUser];
    
    if ([currentUser isBlockUserToMe:mUser]) {
        [self setShieldEnabled:NO];
    }
    else {
        [self setShieldEnabled:YES];
    }
}

- (void)setShieldEnabled:(BOOL)enabled {
    CommonUtils *utils = [CommonUtils sharedObject];
    
//    [self.mButShield setEnabled:enabled];
    
    if (enabled) {
        [self.mButShield setTitle:@"屏蔽" forState:UIControlStateNormal];
        [self.mButShield setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
        [self.mButShield.layer setBorderWidth:1.0f];
    }
    else {
        [self.mButShield setTitle:@"已屏蔽" forState:UIControlStateNormal];
        [self.mButShield setTitleColor:utils.mColorGray forState:UIControlStateNormal];
        [self.mButShield.layer setBorderWidth:0.0f];
    }
}

- (IBAction)onButShield:(id)sender {
    
    UserData *currentUser = [UserData currentUser];
    
    if ([currentUser isBlockUserToMe:mUser]) {
        [currentUser removeObject:mUser forKey:@"blockuser"];
        [currentUser removeBlockUser:mUser];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
//                [mActionsheetView setFirstTitle:@"不看他发布的内容"];
//                [self showAlert:@"操作成功"];
                [self setShieldEnabled:YES];
                if (self.delegate) {
                    [self.delegate onShieldResult:YES user:mUser];
                }
            }
        }];
    }
    else {
        [currentUser addObject:mUser forKey:@"blockuser"];
        [currentUser addBlockUser:mUser];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
//                [mActionsheetView setFirstTitle:@"看他发布的内容"];
//                [self showAlert:@"操作成功"];
                [self setShieldEnabled:NO];
                if (self.delegate) {
                    [self.delegate onShieldResult:NO user:mUser];
                }
            }
        }];
    }
}


@end
