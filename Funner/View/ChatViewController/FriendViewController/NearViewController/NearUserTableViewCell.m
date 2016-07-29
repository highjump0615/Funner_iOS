//
//  NearUserTableViewCell.m
//  Funner
//
//  Created by highjump on 14-12-16.
//
//

#import "NearUserTableViewCell.h"
#import "UserData.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UIImageView+WebCache.h"
#import "CategoryData.h"
#import "CommonUtils.h"
#import <CoreLocation/CoreLocation.h>

@interface NearUserTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *mLblDistance;

@end

@implementation NearUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(UserData *)data {
    
    [super fillContent:data];
    
    //
    // distance
    //
    CGFloat fDistance = [data getDistanceFromMe];
    [self.mLblDistance setText:[NSString stringWithFormat:@"距离: %.1fKm", fDistance]];
}


@end
