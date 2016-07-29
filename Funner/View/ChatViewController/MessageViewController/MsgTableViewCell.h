//
//  MsgTableViewCell.h
//  Funner
//
//  Created by highjump on 15-1-3.
//
//

#import <UIKit/UIKit.h>

@class UserData;

@interface MsgTableViewCell : UITableViewCell

- (void)fillContent:(NSDictionary *)dictMsg user:(UserData *)userData showTime:(BOOL)bShowTime;

@end
