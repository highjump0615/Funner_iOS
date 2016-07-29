//
//  StartupViewController.m
//  Funner
//
//  Created by highjump on 15-1-27.
//
//

#import "StartupViewController.h"
#import "CommonDefine.h"

@interface StartupViewController ()

@property (weak, nonatomic) IBOutlet UIPageControl *mPageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

//@property (weak, nonatomic) IBOutlet UILabel *mLblFirst1;
//@property (weak, nonatomic) IBOutlet UILabel *mLblSecond1;
//
//@property (weak, nonatomic) IBOutlet UILabel *mLblFirst2;
//@property (weak, nonatomic) IBOutlet UILabel *mLblSecond2;

@property (weak, nonatomic) IBOutlet UILabel *mLblFirst3;
//@property (weak, nonatomic) IBOutlet UILabel *mLblSecond3;
@property (weak, nonatomic) IBOutlet UIButton *mButEnter;

@property (weak, nonatomic) IBOutlet UIImageView *mImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView2;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView3;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView4;

@end

@implementation StartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIFont *smallFont = [UIFont fontWithName:@"MFLiHei_Noncommercial-Regular" size:40];
//    
//    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    [paragraphStyle setLineSpacing:17];
//    
//    NSDictionary *attributes = @{NSFontAttributeName:smallFont, NSParagraphStyleAttributeName:paragraphStyle};
    
    UIFont *largeFont = [UIFont fontWithName:@"MFLiHei_Noncommercial-Regular" size:40];
//    [self.mLblSecond1 setFont:largeFont];
//    [self.mLblSecond2 setFont:largeFont];
//    [self.mLblSecond3 setFont:largeFont];
    [self.mLblFirst3 setFont:largeFont];
    
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"发现朋友，\n有共同爱好" attributes:attributes];
//    [self.mLblFirst1 setAttributedText: attributedString];
//    
//    attributedString = [[NSAttributedString alloc] initWithString:@"发现朋友，\n牛b的爱好" attributes:attributes];
//    [self.mLblFirst2 setAttributedText: attributedString];
//    
//    attributedString = [[NSAttributedString alloc] initWithString:@"二度人脉，\n扩大爱好圈" attributes:attributes];
//    [self.mLblFirst3 setAttributedText: attributedString];
    
    [self.mButEnter.layer setMasksToBounds:YES];
    [self.mButEnter.layer setCornerRadius:10];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    if (screenHeight <= 480) {
        [self.mImgView1 setContentMode:UIViewContentModeTop];
        [self.mImgView2 setContentMode:UIViewContentModeTop];
        [self.mImgView3 setContentMode:UIViewContentModeTop];
        [self.mImgView4 setContentMode:UIViewContentModeTop];
    }
    else {
        [self.mImgView1 setContentMode:UIViewContentModeScaleAspectFill];
        [self.mImgView2 setContentMode:UIViewContentModeScaleAspectFill];
        [self.mImgView3 setContentMode:UIViewContentModeScaleAspectFill];
        [self.mImgView4 setContentMode:UIViewContentModeScaleAspectFill];
    }

    NSLog(@"height: %f", screenHeight);
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onButEnter:(id)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kUserDefaultTourPassed];
    
    [self performSegueWithIdentifier:@"Startup2Tabbar" sender:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.mScrollView.frame.size.width;
    NSInteger nPage = self.mScrollView.contentOffset.x / pageWidth;
    
    // Update the page control
    self.mPageControl.currentPage = nPage;
    
    // infinite scrolling
//    if (self.mScrollView.contentOffset.x == 0)
//    {
//        [self.mScrollView setContentOffset:CGPointMake(self.mScrollView.frame.size.width * 3, 0)];
//    }
//    else if (self.mScrollView.contentOffset.x == self.mScrollView.frame.size.width * 4)
//    {
//        [self.mScrollView setContentOffset:CGPointMake(self.mScrollView.frame.size.width * 1, 0)];
//    }
}


@end
