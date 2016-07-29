//
//  CategoryCellView.h
//  Funner
//
//  Created by highjump on 15-2-22.
//
//

#import <UIKit/UIKit.h>

@interface CategoryCellView : UIView

@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView2;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView3;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView4;
@property (weak, nonatomic) IBOutlet UILabel *mLblCount;

- (void)initView;

@end
