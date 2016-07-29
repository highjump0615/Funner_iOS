//
//  FindViewController.m
//  Funner
//
//  Created by highjump on 14-11-4.
//
//

#import "FindViewController.h"
#import "HobbyViewController.h"

#import "CommonUtils.h"

#import "FindAdTableViewCell.h"
#import "FindHobbyTableViewCell.h"

#import "AdData.h"
#import "CategoryData.h"
#import "UserData.h"
#import "ContactData.h"

#import "UIButton+WebCache.h"
#import "MBProgressHUD.h"
#import "NoticeView.h"


@interface FindViewController () {
//    NSMutableArray *maryAd;
    CategoryData *mCategorySelected;
    
    UIColor *mBackColor;
}

@property (weak, nonatomic) IBOutlet UIView *mViewSignup;

@property (weak, nonatomic) IBOutlet NoticeView *mViewNotice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintNoticeTop;

@end

@implementation FindViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
//    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
//    mBackColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    
//    maryAd = [[NSMutableArray alloc] init];
//    
//    // get advertisement data
//    AVQuery *query = [AVQuery queryWithClassName:@"MainAd"];
//    [query includeKey:@"category"];
//    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            [maryAd removeAllObjects];
//
//            for (AdData *obj in objects) {
//                [maryAd addObject:obj];
//            }
//            
//            [self.mTableView reloadData];
//            
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
    
//    [CommonUtils makeBlurToolbar:self.mViewSignup color:nil];
    
//    [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    UIEdgeInsets edgeTable = self.mTableView.contentInset;
    edgeTable.top = 64;
//    edgeTable.bottom = self.tabBarController.tabBar.frame.size.height;
    [self.mTableView setContentInset:edgeTable];
    
    [self.mViewSignup setHidden:YES];
    
    [self.mViewNotice setAlpha:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    UserData *currentUser = [UserData currentUser];
//    if (currentUser) {
//        [self.tabBarController.tabBar setHidden:NO];
//        [self.mViewSignup setHidden:YES];
//
//        [self.navigationItem setTitle:@"发现"];
//    }
//    else {
//        [self.tabBarController.tabBar setHidden:YES];
//        [self.mViewSignup setHidden:NO];
//
//        [self.navigationItem setTitle:@"乐呀"];
//    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Find2Hobby"]) {
        HobbyViewController *viewController =  [segue destinationViewController];
        viewController.mCategory = mCategorySelected;
    }
}


- (CategoryData *)getParentCategory:(NSInteger)nIndex {
    // get the parent category
    int i = 0;
    CommonUtils *utils = [CommonUtils sharedObject];
    
    CategoryData *parentCat;
    for (CategoryData *cData in utils.maryCategory) {
        if (!cData.parent) {
            if (i == nIndex) {
                parentCat = cData;
                break;
            }
            i++;
        }
    }
    
    return parentCat;
}

- (CategoryData *)getCategory:(CategoryData *)parent Index:(NSInteger)nIndex {
    CategoryData *category;
    CommonUtils *utils = [CommonUtils sharedObject];
    
    // get category data
    int i = 0;
    for (CategoryData *cData in utils.maryCategory) {
        if ([cData.parent.objectId isEqualToString:parent.objectId]) {
            if (i == nIndex) {
                category = cData;
            }
            i++;
        }
    }
    
    return category;
}

- (void)onButAd:(id)sender {
//    int nIndex = (int)((UIButton*)sender).tag;
//
//    AdData *adData = [maryAd objectAtIndex:nIndex];
//    mCategorySelected = adData.category;
//    [self performSegueWithIdentifier:@"Find2Hobby" sender:nil];
}

- (void)showNotice {
    CGFloat fContsraint = -7;
    
    // show notice
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.mConstraintNoticeTop setConstant:fContsraint + self.mViewNotice.frame.size.height];
                         [self.mViewNotice setAlpha:1];
                         [self.view layoutIfNeeded];
                         
                     }completion:^(BOOL finished) {
                         [self performSelector:@selector(hideNotice) withObject:nil afterDelay:2.0];
                     }];
}

- (void)hideNotice {
    CGFloat fContsraint = -7;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.mConstraintNoticeTop setConstant:fContsraint];
                         [self.mViewNotice setAlpha:0];
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL finished) {
                     }];
}


- (IBAction)onButAddHobby:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.mTableView];
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    CategoryData *parentCat = [self getParentCategory:indexPath.section];
    CategoryData *category = [self getCategory:parentCat Index:indexPath.row];
    UserData *currentUser = [UserData currentUser];
    
    if ([currentUser hasCategory:category]) {
        // remove from db
        [currentUser removeObject:category forKey:@"category"];
        [currentUser.maryCategory removeObject:category];
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.mViewNotice setMessage:[NSString stringWithFormat:@"%@已从您的频道列表中删除", category.name]];
                [self showNotice];
                [self.mTableView reloadData];
            }
            else {
                NSLog(@"%@", error.localizedDescription);
                [self.mViewNotice setMessage:error.localizedDescription];
                [self showNotice];
            }
        }];
    }
    else {
        // add to db
        [currentUser addObject:category forKey:@"category"];
        [currentUser.maryCategory addObject:category];
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.mViewNotice setMessage:@"添加成功，请返回并查阅你感兴趣的频道列表"];
                [self showNotice];
                [self.mTableView reloadData];
            }
            else {
                NSLog(@"%@", error.localizedDescription);
                [self.mViewNotice setMessage:error.localizedDescription];
                [self showNotice];
            }
        }];
    }
}

#pragma mark - TableViewDeleage

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    NSInteger nCount = 0;
    for (CategoryData *cData in utils.maryCategory) {
        if (!cData.parent) {
            nCount++;
        }
    }
    
	return nCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger nCount = 0;
    
//    if (section == 0) {
//        nCount = 1;
//    }
//    else {
        CategoryData *parentCat = [self getParentCategory:section];
        CommonUtils *utils = [CommonUtils sharedObject];
        
        for (CategoryData *cData in utils.maryCategory) {
            if ([cData.parent.objectId isEqualToString:parentCat.objectId]) {
                nCount++;
            }
        }
//    }

    return nCount;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        UIEdgeInsets edgeInset = UIEdgeInsetsZero;
        edgeInset.left = 10;
        [cell setSeparatorInset:edgeInset];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;

//    if (indexPath.section == 0) {
//        FindAdTableViewCell *adCell = (FindAdTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HomeMainCellID"];
//
//        [adCell initView];
//        
//        if ([maryAd count] > 0) {
//            AdData *adData = [maryAd objectAtIndex:0];
//            [adCell.mButAd1 sd_setImageWithURL:[NSURL URLWithString:adData.image.url]
//                                      forState:UIControlStateNormal
//                              placeholderImage:[UIImage imageNamed:@"home_sample_pic.png"]];
//            [adCell.mButAd1 addTarget:self action:@selector(onButAd:) forControlEvents:UIControlEventTouchUpInside];
//            adCell.mButAd1.tag = 0;
//            
//            adData = [maryAd objectAtIndex:1];
//            [adCell.mButAd2 sd_setImageWithURL:[NSURL URLWithString:adData.image.url]
//                                      forState:UIControlStateNormal
//                              placeholderImage:[UIImage imageNamed:@"home_sample_pic.png"]];
//            [adCell.mButAd2 addTarget:self action:@selector(onButAd:) forControlEvents:UIControlEventTouchUpInside];
//            adCell.mButAd2.tag = 1;
//            
//            adData = [maryAd objectAtIndex:2];
//            [adCell.mButAd3 sd_setImageWithURL:[NSURL URLWithString:adData.image.url]
//                                      forState:UIControlStateNormal
//                              placeholderImage:[UIImage imageNamed:@"home_sample_pic.png"]];
//            [adCell.mButAd3 addTarget:self action:@selector(onButAd:) forControlEvents:UIControlEventTouchUpInside];
//            adCell.mButAd3.tag = 2;
//        }
//        
//        cell = adCell;
//    }
//    else {
        FindHobbyTableViewCell *hobbyCell = (FindHobbyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HomeHobbyCellID"];
        
        CategoryData *parentCat = [self getParentCategory:indexPath.section];
        CategoryData *category = [self getCategory:parentCat Index:indexPath.row];
        
//        if (indexPath.section > 0) {
            [hobbyCell showCategoryInfo:category];
            [hobbyCell.mButAdd addTarget:self action:@selector(onButAddHobby:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else {
//            [hobbyCell.mImageView setImage:[UIImage imageNamed:@"home_friends.png"]];
//            [hobbyCell.mLblTitle setText:@"朋友们的爱好"];
//            
//            // friend count
//            UserData *currentUser = [UserData currentUser];
//            if (!currentUser) {
//                currentUser = [CommonUtils getEmptyUser];
//            }
//            
//            NSInteger nCount = 0;
//            
//            for (UserData *uData in currentUser.maryFriend) {
//                if (uData.mnRelation == USERRELATION_FRIEND) {
//                    nCount++;
//                }
//            }
//            
//            if (nCount > 0) {
//                [hobbyCell.mLblDetail setText:[NSString stringWithFormat:@"%ld个朋友", (long)nCount]];
//            }
//            else {
//                [hobbyCell.mLblDetail setText:@""];
//            }
//        }
    
        cell = hobbyCell;
//    }
    
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
//    if (section > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        /* Create custom view to display section header... */
        
        CategoryData *parentCat = [self getParentCategory:section];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 35)];
        [label setFont:[UIFont systemFontOfSize:17]];
        [label setText:parentCat.name];
        [label setTextColor:[UIColor whiteColor]];
        
        [view addSubview:label];
        
        return view;
//    }
//    else {
//        return nil;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section > 0) {
//        return 47;
//    }
//    else {
        return 63;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    int nHeight = 0;
//
//    if (section > 0) {
        nHeight = 35;
//    }
    
    return nHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.section == 0) {
//        mCategorySelected = nil;
//        [self performSegueWithIdentifier:@"Find2Hobby" sender:nil];
//    }
//    else {
        CategoryData *parentCat = [self getParentCategory:indexPath.section ];
        CategoryData *category = [self getCategory:parentCat Index:indexPath.row];
        mCategorySelected = category;
        
        [self performSegueWithIdentifier:@"Find2Hobby" sender:nil];
//    }
}


@end
