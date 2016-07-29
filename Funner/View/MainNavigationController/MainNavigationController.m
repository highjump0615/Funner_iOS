//
//  MainNavigationController.m
//  Funner
//
//  Created by highjump on 15-1-22.
//
//

#import "MainNavigationController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
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

+ (void)initialize
{
    // 设置导航栏主题
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 设置背景图片
    NSString *bgName = @"nav_background.png";
    
    [navBar setTintColor:[UIColor whiteColor]];
    
    [navBar setBackgroundImage:[UIImage imageNamed:bgName] forBarMetrics:UIBarMetricsDefault];
    
    // 设置标题文字颜色
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[UITextAttributeTextColor] = [UIColor whiteColor];
    attrs[UITextAttributeFont] = [UIFont boldSystemFontOfSize:19];
    
    [navBar setTitleTextAttributes:attrs];
    
    navBar.barStyle = UIBarStyleBlack;
}

/**
 *  ,拦截所有的push操作
 *
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}


@end
