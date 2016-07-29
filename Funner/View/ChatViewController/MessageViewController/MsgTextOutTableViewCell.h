//
//  MsgTextOutTableViewCell.h
//  Funner
//
//  Created by highjump on 15-1-4.
//
//

#import "MsgTableViewCell.h"

@class UserData;

@interface MsgTextOutTableViewCell : MsgTableViewCell

- (void)fillContent:(NSDictionary *)dictMsg user:(UserData *)userData showTime:(BOOL)bShowTime;

@end
