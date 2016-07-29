//
//  MsgTextInTableViewCell.h
//  Funner
//
//  Created by highjump on 15-1-3.
//
//

#import "MsgTableViewCell.h"

@interface MsgTextInTableViewCell : MsgTableViewCell

- (void)fillContent:(NSDictionary *)dictMsg user:(UserData *)userData showTime:(BOOL)bShowTime;

@end
