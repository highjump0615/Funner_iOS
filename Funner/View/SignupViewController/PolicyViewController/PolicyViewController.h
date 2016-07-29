//
//  PolicyViewController.h
//  Funner
//
//  Created by highjump on 14-12-10.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    CONTENT_POLICY,
    CONTENT_ABOUT
} PolicyType;

@interface PolicyViewController : UIViewController

@property (assign, nonatomic) PolicyType mnType;

@end
