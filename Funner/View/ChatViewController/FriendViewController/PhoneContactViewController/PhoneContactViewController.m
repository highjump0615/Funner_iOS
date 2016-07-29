//
//  PhoneContactViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "PhoneContactViewController.h"
#import <MessageUI/MessageUI.h>
#import "ContactData.h"
#import "CommonUtils.h"
#import "UserData.h"
#import "BATableView.h"

#define kUserDefaultSentInviteContact   @"ArraySentContact"

@interface PhoneContactViewController () <MFMessageComposeViewControllerDelegate, BATableViewDelegate> {
    ContactData *mContactCurrent;
    NSMutableArray *marySentContact;
    NSMutableArray *maryContactShow;
    
    BOOL mbBATReady;
}

@property (weak, nonatomic) IBOutlet BATableView *mBaTableView;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation PhoneContactViewController

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
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    // load contact array from user default
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:kUserDefaultSentInviteContact] != nil) {
        NSArray *aryTemp= [userDefaults objectForKey:kUserDefaultSentInviteContact];
        marySentContact = [aryTemp mutableCopy];
        
        for (NSString *strPhoneNumber in aryTemp) {
            for (ContactData *cData in utils.maryContact) {
                if ([cData.maryPhone[0] isEqualToString:strPhoneNumber]) {
                    cData.mbSentInvite = YES;
                    break;
                }
            }
        }
    }
    else {
        marySentContact = [[NSMutableArray alloc] init];
    }
    
    mbBATReady = NO;
    
    maryContactShow = [[NSMutableArray alloc] init];
    UserData *currentUser = [UserData currentUser];
    
    for (ContactData *cData in utils.maryContact) {
        BOOL bExist = NO;
        
        for (NSString *strPhone in cData.maryPhone) {
            for (UserData *uData in [currentUser getFriendArray]) {
                if ([strPhone isEqualToString:uData.username]) {
                    bExist = YES;
                    break;
                }
            }
            
            if (bExist) {
                break;
            }
        }
        
        if (!bExist) {
            [self addToIndexDictionary:maryContactShow text:cData];
//            [maryContactShow addObject:cData];
        }
    }

    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (mbBATReady) {
        return;
    }
    
    self.mBaTableView.tableView = self.mTableView;
    self.mBaTableView.delegate = self;
    [self.mBaTableView prepare];
    
    [self.mBaTableView reloadData];
    
    mbBATReady = YES;
}

- (void)addToIndexDictionary:(NSMutableArray *)aryDict text:(ContactData *)cData {
    
    NSMutableString *strPinyin = [NSMutableString stringWithString:cData.mstrName];
    
    CFStringTransform((__bridge CFMutableStringRef)strPinyin, 0, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)strPinyin, 0, kCFStringTransformStripDiacritics, NO);
    
    NSString *strIndex = [[strPinyin substringToIndex:1] uppercaseString];
    
    NSMutableDictionary *dictContact;
    int i;
    
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([strIndex rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        // check whether # group is existing
        for (i = 0; i < [aryDict count]; i++) {
            dictContact = [aryDict objectAtIndex:i];
            if ([dictContact[@"indexTitle"] isEqualToString:@"#"]) {
//                [dictContact[@"data"] addObject:cData];
                break;
            }
        }
        
        if (i >= [aryDict count]) {
            dictContact = [[NSMutableDictionary alloc] init];
            dictContact[@"indexTitle"] = @"#";
            dictContact[@"data"] = [[NSMutableArray alloc] init];
//            [dictContact[@"data"] addObject:cData];
            
            [aryDict insertObject:dictContact atIndex:0];
//            [aryDict addObject:dictContact];
        }
    }
    else {
        for (i = 0; i < [aryDict count]; i++) {
            dictContact = [aryDict objectAtIndex:i];
            if ([dictContact[@"indexTitle"] isEqualToString:strIndex]) {
//                [dictContact[@"data"] addObject:cData];
                break;
            }
        }
        
        if (i >= [aryDict count]) {
            dictContact = [[NSMutableDictionary alloc] init];
            dictContact[@"indexTitle"] = strIndex;
            dictContact[@"data"] = [[NSMutableArray alloc] init];
//            [dictContact[@"data"] addObject:cData];
            
            // add with sorting
            NSInteger nLocation = 0;
            for (nLocation = 0; nLocation < [aryDict count]; nLocation++) {
                NSDictionary *dictTmp = [aryDict objectAtIndex:nLocation];
                NSString *strIndex = dictTmp[@"indexTitle"];
                NSString *strIndexToAdd = dictContact[@"indexTitle"];
                
                if ([strIndex compare:strIndexToAdd] == NSOrderedDescending) {
                    break;
                }
            }
            [aryDict insertObject:dictContact atIndex:nLocation];
            
//            [aryDict addObject:dictContact];
        }
    }
    
    if (dictContact) {
        // add with sorting
        NSInteger nLocation = 0;
        NSMutableArray *arydictContact = dictContact[@"data"];
        
        for (nLocation = 0; nLocation < [arydictContact count]; nLocation++) {
            ContactData *ctTmp = [arydictContact objectAtIndex:nLocation];
            
            if ([ctTmp.mstrName compare:cData.mstrName] == NSOrderedDescending) {
                break;
            }
        }
        
        [arydictContact insertObject:cData atIndex:nLocation];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - TableView

- (NSArray *)sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    NSMutableArray * indexTitles = [NSMutableArray array];
    for (NSDictionary * sectionDictionary in maryContactShow) {
        [indexTitles addObject:sectionDictionary[@"indexTitle"]];
    }
    return indexTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [maryContactShow count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [maryContactShow[section][@"data"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, -2, tableView.frame.size.width, 18)];
    [label setFont:[UIFont systemFontOfSize:11]];
    [label setText:maryContactShow[section][@"indexTitle"]];
    [label setTextColor:[UIColor whiteColor]];
    
    [view addSubview:label];
    
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneContactCellID"];
    
    NSDictionary *dict = [maryContactShow objectAtIndex:indexPath.section];
    ContactData *cData = [dict[@"data"] objectAtIndex:indexPath.row];
    
    //
    // name
    //
    UILabel *lblName = (UILabel *)[cell viewWithTag:100];
    [lblName setText:cData.mstrName];
    
    //
    // button
    //
    UIButton *butInvite = (UIButton *)[cell viewWithTag:101];
    [butInvite.layer setMasksToBounds:YES];
    [butInvite.layer setCornerRadius:3];
    
    if (cData.mbSentInvite) {
        [butInvite setHidden:YES];
    }
    else {
        [butInvite setHidden:NO];
    }
    [butInvite addTarget:self action:@selector(onButInvite:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)onButInvite:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.mTableView];
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    NSDictionary *dict = [maryContactShow objectAtIndex:indexPath.section];
    ContactData *cData = [dict[@"data"] objectAtIndex:indexPath.row];

    mContactCurrent = cData;
//    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [warningAlert show];
        
        return;
    }
    
    NSArray *recipents = @[cData.maryPhone[0]];
    NSString *message = [NSString stringWithFormat:@"我在“乐呀”和朋友一起玩，你也快来“乐呀”和我们玩吧！\nhttps://itunes.apple.com/cn/app/le-ya/id970836065"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                   message:@"Failed to send SMS!"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent: {
            // save tags to user default
            [marySentContact addObject:mContactCurrent.maryPhone[0]];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:marySentContact forKey:kUserDefaultSentInviteContact];
            
            mContactCurrent.mbSentInvite = YES;
            
            [self.mTableView reloadData];

            break;
        }
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
