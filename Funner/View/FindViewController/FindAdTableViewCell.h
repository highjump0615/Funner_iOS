//
//  FindAdTableViewCell.h
//  Funner
//
//  Created by highjump on 14-11-22.
//
//

#import <UIKit/UIKit.h>

@interface FindAdTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UIButton *mButAd1;
@property (weak, nonatomic) IBOutlet UIButton *mButAd2;
@property (weak, nonatomic) IBOutlet UIButton *mButAd3;
@property (weak, nonatomic) IBOutlet UIPageControl *mPageControl;

- (void)initView;

@end
