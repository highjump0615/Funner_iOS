//
//  ChatViewController.m
//  Funner
//
//  Created by highjump on 14-11-8.
//
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "CommonUtils.h"
#import "MessageViewController.h"
#import "CDSessionManager.h"

#import "UserData.h"

@interface ChatViewController () {
    UserData *mUserSelected;
    NSInteger mnCurIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation ChatViewController

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
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    UIEdgeInsets edgeTable = self.mTableView.contentInset;
    edgeTable.top = 64;
    edgeTable.bottom = utils.mTabbarController.tabBar.frame.size.height;
    [self.mTableView setContentInset:edgeTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTable {
    [self.mTableView reloadData];
    
    if ([self getHistoryCount] > 0) {
        [self.mTableView setHidden:NO];
    }
    else {
        [self.mTableView setHidden:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Chat2Message"]) {
        MessageViewController *viewController = [segue destinationViewController];
        viewController.mUser = mUserSelected;
    }
}


- (NSInteger)getHistoryCount {
    UserData *currentUser = [UserData currentUser];
    NSInteger nCount = 0;

    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation != USERRELATION_FRIEND) {
            continue;
        }
        
        if (uData.mMsgLatest) {
            nCount++;
        }
    }
    
    return nCount;
}

- (UserData *)getHistoryUser:(NSInteger)nIndex {
    UserData *currentUser = [UserData currentUser];
    NSInteger nCount = 0;
    UserData *uDataRes;
    
    for (UserData *uData in currentUser.maryFriend) {
        if (uData.mnRelation != USERRELATION_FRIEND) {
            continue;
        }
        
        if (uData.mMsgLatest) {
            if (nCount == nIndex) {
                uDataRes = uData;
                break;
            }
            nCount++;
        }
    }
    
    return uDataRes;
}


#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger nCount = 0;
    
    if ([self getHistoryCount] > 0) {
        nCount = 1;
    }
    
    return nCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	switch (section) {
		case 0:
            return [self getHistoryCount];
		default:
			break;
	}
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell;
    
    if (indexPath.section == 0) {
        UserData *uData = [self getHistoryUser:indexPath.row];
        
        ChatTableViewCell *chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatCellID"];
        [chatCell fillContent:uData];
        
        cell = chatCell;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (indexPath.section == 0) {
        mUserSelected = [self getHistoryUser:indexPath.row];
        [self performSegueWithIdentifier:@"Chat2Message" sender:nil];
	}
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        UIEdgeInsets edgeInset = UIEdgeInsetsZero;
        edgeInset.left = 58;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    int nHeight = 0;
    
    if (section == 0) {
        nHeight = 33;
    }
    
    return nHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 33)];
        /* Create custom view to display section header... */
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, tableView.frame.size.width, 18)];
        [label setFont:[UIFont systemFontOfSize:13]];
        [label setText:@"最近联系人"];
        [label setTextColor:[UIColor whiteColor]];
        
        [view addSubview:label];
        
        return view;
    }
    else {
        return nil;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        mnCurIndex = indexPath.row;
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您确定要删除这个记录吗？"
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"删除",nil];
        [alert show];
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UserData *uData = [self getHistoryUser:mnCurIndex];
        [[CDSessionManager sharedInstance] deleteMessagesForPeerId:uData.objectId];
        
        uData.mMsgLatest = nil;
        uData.mnUnreadCount = 0;
        
        [self reloadTable];
    }
}




@end
