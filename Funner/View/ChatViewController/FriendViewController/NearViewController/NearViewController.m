//
//  NearViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "NearViewController.h"
#import "CommonUtils.h"
#import "UserData.h"
#import "NearUserTableViewCell.h"
#import "MeViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface NearViewController () {
    UserData *mUserSelected;
    UIRefreshControl *mRefreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation NearViewController

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
    
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl setTintColor:[UIColor whiteColor]];
    [mRefreshControl addTarget:self action:@selector(getNearInfo:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:mRefreshControl];
    
    [mRefreshControl beginRefreshing];
    [self getNearInfo:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)getNearInfo:(UIRefreshControl *)sender {
    UserData *currentUser = [UserData currentUser];
    
    [currentUser getNearUserWithSuccess:^{
        [self updateTable];
    }];
}

- (void)updateTable {
    UserData *currentUser = [UserData currentUser];
    
    if ([mRefreshControl isRefreshing]) {
        [mRefreshControl endRefreshing];
    }
    
    [currentUser checkDuplicate];
    [self.mTableView reloadData];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Near2Me"]) {
        MeViewController *viewController = [segue destinationViewController];
        viewController.mUser = mUserSelected;
    }
}

- (NSInteger)getNearCount {
    UserData *currentUser = [UserData currentUser];
    NSInteger nCount = 0;
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation == USERRELATION_NEAR) {
            nCount++;
        }
    }
    
    return nCount;
}

- (UserData *)getNearWithIndex:(NSInteger)nIndex {
    UserData *currentUser = [UserData currentUser];
    NSInteger nCount = 0;
    UserData *uDataRes;
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation == USERRELATION_NEAR) {
            if (nCount == nIndex) {
                uDataRes = uData;
                break;
            }
            nCount++;
        }
    }
    
    return uDataRes;
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getNearCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserData *uData = [self getNearWithIndex:indexPath.row];
    NearUserTableViewCell *cell = (NearUserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NearCellID"];
    [cell fillContent:uData];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    mUserSelected = [self getNearWithIndex:indexPath.row];
    [self performSegueWithIdentifier:@"Near2Me" sender:nil];
}


@end
