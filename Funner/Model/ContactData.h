//
//  ContactData.h
//  Funner
//
//  Created by highjump on 14-12-17.
//
//

#import <Foundation/Foundation.h>

@class UserData;

@interface ContactData : NSObject

@property (strong) NSString *mstrName;
@property (strong) NSMutableArray *maryPhone;
@property (nonatomic) BOOL mbSentInvite;

@end
