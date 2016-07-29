//
//  MsgImageInTableViewCell.h
//  Funner
//
//  Created by highjump on 15-1-7.
//
//

#import "MsgTableViewCell.h"

@class AVObject;

@interface MsgImageInTableViewCell : MsgTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;

- (void)fillContent:(NSDictionary *)dictMsg user:(UserData *)userData object:(AVObject *)object showTime:(BOOL)bShowTime;

@end
