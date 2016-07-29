//
//  EffectItemView.h
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import <UIKit/UIKit.h>

@interface EffectItemView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *mImgBorder;
@property (weak, nonatomic) IBOutlet UIImageView *mImgSelected;
@property (weak, nonatomic) IBOutlet UIButton *mButEffect;
@property (weak, nonatomic) IBOutlet UILabel *mLblName;

+ (id)itemView;

@end
