//
//  DetailViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "DetailViewController.h"
#import "CommentTableViewCell.h"
#import "BlogData.h"

#import "BlogCell.h"

#import "BlogTextCell.h"
#import "BlogOperationCell.h"
#import "DetailSegementCell.h"

#import "CommonUtils.h"
#import "NotificationData.h"

#import "TTTAttributedLabel.h"
#import "NoticeView.h"

#import "MeViewController.h"
#import "MessageViewController.h"

#import "UserData.h"

#import "CustomActionSheetView.h"
#import "InputCommentView.h"


@interface DetailViewController () </*BlogRelationCellDelegate, */CustomActionSheetDelegate, BlogCellDelegate, InputCommentViewDelegate, BlogContentDelegate> {
    UserData *mUserSelected;
    UIColor *mColorNormal;
    UIColor *mColorDisable;
    
    CustomActionSheetView *mActionsheetViewDelete;
//    CustomActionSheetView *mActionsheetViewReport;
    
    BOOL mbKeyboardOn;
    BOOL mbShoudScroll;
}

//@property (weak, nonatomic) IBOutlet UIView *mViewText;
//@property (weak, nonatomic) IBOutlet UITextField *mTxtComment;
//@property (weak, nonatomic) IBOutlet UIButton *mButSend;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (weak, nonatomic) IBOutlet NoticeView *mViewNotice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintNoticeTop;

@property (weak, nonatomic) IBOutlet InputCommentView *mViewComment;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.mnCommentType = NOTIFICATION_COMMENT;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.mViewText.layer setMasksToBounds:YES];
//    [self.mViewText.layer setCornerRadius:5];
//    
//    self.mViewText.layer.borderColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1].CGColor;
//    self.mViewText.layer.borderWidth = 1.0f;
//    
//    [self.mButSend.layer setMasksToBounds:YES];
//    [self.mButSend.layer setCornerRadius:5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
    
//    self.mTableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
//    mColorNormal = [UIColor colorWithRed:36/255.0 green:185/255.0 blue:191/255.0 alpha:1];
//    mColorDisable = [UIColor grayColor];
//    
//    [self.mButSend setBackgroundColor:mColorNormal];
    
    if (!self.mBlogData.user) { // not fetched
        [self.mBlogData fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            [self getLikeComment];
        }];
    }
    else {
        [self getLikeComment];
    }
    
    
//
//    mActionsheetViewReport = (CustomActionSheetView *)[CustomActionSheetView initView:self.view
//                                                                         ButtonTitle1:@""
//                                                                         ButtonTitle2:@""
//                                                                         ButtonTitle3:@"举报这张图片"];
//    mActionsheetViewReport.delegate = self;
    
//    // Center horizontally
//    [mActionsheetViewReport addConstraint:[NSLayoutConstraint constraintWithItem:mActionsheetViewReport
//                                                     attribute:NSLayoutAttributeBottom
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.view
//                                                     attribute:NSLayoutAttributeBottom
//                                                    multiplier:1.0
//                                                      constant:0.0]];
//    
//    [mActionsheetViewReport addConstraint:[NSLayoutConstraint constraintWithItem:mActionsheetViewReport
//                                                     attribute:NSLayoutAttributeLeading
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.view
//                                                     attribute:NSLayoutAttributeLeading
//                                                    multiplier:1.0
//                                                      constant:0.0]];
//    
//    [mActionsheetViewReport addConstraint:[NSLayoutConstraint constraintWithItem:mActionsheetViewReport
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.view
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1.0
//                                                      constant:0.0]];

    
    [self.mViewNotice setAlpha:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    mbKeyboardOn = NO;
    
//    mActionsheetViewDelete = (CustomActionSheetView *)[CustomActionSheetView initView:self.view
//                                                                         ButtonTitle1:@""
//                                                                         ButtonTitle2:@""
//                                                                         ButtonTitle3:@"删除图片"
//                                                                       removeOnCancel:NO];
//    mActionsheetViewDelete.delegate = self;
    
    UIEdgeInsets edgeTable = self.mTableView.contentInset;
//    edgeTable.top = 64;
    edgeTable.bottom = self.mViewComment.frame.size.height;
    [self.mTableView setContentInset:edgeTable];
    
    self.mViewComment.mBlogData = self.mBlogData;
    self.mViewComment.mnCommentType = self.mnCommentType;
    [self.mViewComment setDelegate:self];
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}


-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)getLikeComment {
    UIBarButtonItem *rightButton = nil;
    
//    if ([self.mBlogData.user.objectId isEqualToString:[UserData currentUser].objectId]) {
        rightButton = [[UIBarButtonItem alloc] initWithTitle:@"更多"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(onButRightItem:)];
        [self.navigationItem setRightBarButtonItem:rightButton];
//    }
    
    if (self.mBlogData.mbGotLike && self.mBlogData.mbGotComment) {
        [self performSelector:@selector(scrollToComment) withObject:nil afterDelay:0.1];
    }
    else {
        [self.mBlogData fillBlogData:NO afterSuccess:^(){
            if (self.mBlogData.mbGotLike && self.mBlogData.mbGotComment) {
                [self.mTableView reloadData];
                [self performSelector:@selector(scrollToComment) withObject:nil afterDelay:0.1];
            }
        }];
    }
}

- (void)scrollToComment {
//    if (!self.mNotificationData) {
//        return;
//    }
//    
//    if (self.mNotificationData.type == NOTIFICATION_COMMENT) {
//        // get comment index
//        NSInteger nIndex = 0;
//        for (nIndex = 0; nIndex < [self.mBlogData.maryCommentData count]; nIndex++) {
//            NotificationData *nData = [self.mBlogData.maryCommentData objectAtIndex:nIndex];
//            if ([nData.objectId isEqualToString:self.mNotificationData.objectId]) {
//                break;
//            }
//        }
//        
//        nIndex += 1;
//        
//        if ([self.mBlogData.maryLikeData count] > 0) {
//            nIndex++;
//        }
//        
//        nIndex = MIN(nIndex, [self.mTableView numberOfRowsInSection:0] - 1);
//        
//        [self.mBlogData.maryCommentData indexOfObject:self.mNotificationData];
//        
//        [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:nIndex inSection:0]
//                               atScrollPosition:UITableViewScrollPositionBottom
//                                       animated:YES];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Detail2Me"]) {
        MeViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
    }
    else if ([[segue identifier] isEqualToString:@"Detail2Message"]) {
        MessageViewController *viewController = [segue destinationViewController];
        viewController.mBlog = self.mBlogData;
        viewController.mUser = self.mBlogData.user;
    }
}


- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onButRightItem:(id)sender {
    
    if (mbKeyboardOn) {
        return;
    }
    
//    if (!mActionsheetViewDelete) {
        mActionsheetViewDelete = (CustomActionSheetView *)[CustomActionSheetView initView:self.view
                                                                             ButtonTitle1:@""
                                                                             ButtonTitle2:@""
                                                                             ButtonTitle3:@"删除图片"
                                                                           removeOnCancel:YES];
        mActionsheetViewDelete.delegate = self;
//    }
    
    if ([self.mBlogData.user.objectId isEqualToString:[UserData currentUser].objectId]) {
        [mActionsheetViewDelete setThirdTitle:@"删除图片"];
    }
    else {
        [mActionsheetViewDelete setThirdTitle:@"举报这张图片"];
    }
    
    [mActionsheetViewDelete showView];
}

#pragma mark - CustomActionSheetDelegate

- (void)onButThird:(UIView *)view {
    if ([self.mBlogData.user.objectId isEqualToString:[UserData currentUser].objectId]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您确定要删除这个图片吗？"
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"删除",nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"举报成功"
                                                        message:@""
                                                        delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

#pragma mark - Alert Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // delete blog object
        [self.mBlogData deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                for (NotificationData *notifyData in self.mBlogData.maryLikeData) {
                    [notifyData deleteInBackground];
                }
                for (NotificationData *notifyData in self.mBlogData.maryCommentData) {
                    [notifyData deleteInBackground];
                }
                
                if (self.delegate) {
                    [self.delegate deleteBlog:self.mBlogData];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                // show notice
                [self showNotice];
            }
        }];
    }
}

- (NSInteger)getRowCount {
    NSInteger nCount = 3;
    
    if ([self.mBlogData.text length] > 0) {
        nCount++;
    }
    
    if (self.mnCommentType == NOTIFICATION_COMMENT) {
        nCount += [self.mBlogData.maryCommentData count];
    }
    else if (self.mnCommentType == NOTIFICATION_SUGGEST) {
        nCount += [self.mBlogData.marySuggestData count];
    }
    
    return nCount;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getRowCount];
}

- (UITableViewCell *)configureCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forHeight:(BOOL)bForHeight {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        BlogCell *blogCell = (BlogCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCellID"];
        [blogCell fillContent:self.mBlogData forHeight:bForHeight];
        
        if (!bForHeight) {
            [blogCell.mButPhoto addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
            [blogCell.mButName addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
            
            blogCell.mContentDelegate = self;
        }
    
        cell = blogCell;
        
        return cell;
    }
    
    NSInteger nIndex = indexPath.row;
    
    if ([self.mBlogData.text length] > 0) {
        if (nIndex == 1) {
            BlogTextCell *textCell = (BlogTextCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailTextCellID"];
            [textCell fillContent:self.mBlogData forHeight:bForHeight];
            cell = textCell;
            
            return cell;
        }
        
        nIndex--;
    }
    
    switch (nIndex) {
        case 1: {
            BlogOperationCell *opCell = [tableView dequeueReusableCellWithIdentifier:@"DetailOperationCellID"];
            [opCell fillContent:self.mBlogData];
            
            [opCell.mButChat addTarget:self action:@selector(onButChat:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = opCell;
            
            break;
        }
            
        case 2: {
            DetailSegementCell *segmentCell = [tableView dequeueReusableCellWithIdentifier:@"DetailSegmentCellID"];
            [segmentCell fillContent:self.mBlogData type:self.mnCommentType];
            [segmentCell.mButComment addTarget:self action:@selector(onButSegment:) forControlEvents:UIControlEventTouchUpInside];
            segmentCell.mButComment.tag = NOTIFICATION_COMMENT;
            [segmentCell.mButSuggest addTarget:self action:@selector(onButSegment:) forControlEvents:UIControlEventTouchUpInside];
            segmentCell.mButSuggest.tag = NOTIFICATION_SUGGEST;
            
            cell = segmentCell;
            break;
        }
            
        default:
            cell = [self configureCommentCell:tableView index:nIndex - 3 forHeight:bForHeight];
            break;
    }

    return cell;
}


- (CommentTableViewCell *)configureCommentCell:(UITableView *)tableView index:(NSInteger)nIndex forHeight:(BOOL)bForHeight {
    CommentTableViewCell *commentCell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCommentCellID"];
    NotificationData *notifyData;
    
    if (self.mnCommentType == NOTIFICATION_COMMENT) {
        notifyData = [self.mBlogData.maryCommentData objectAtIndex:nIndex];
    }
    else if (self.mnCommentType == NOTIFICATION_SUGGEST) {
        notifyData = [self.mBlogData.marySuggestData objectAtIndex:nIndex];
    }
    
    [commentCell fillContent:notifyData forHeight:bForHeight];
    
    return commentCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    if (indexPath.row == 0) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        height = screenWidth + 56;
        
        return height;
    }
    
    NSInteger nIndex = indexPath.row;
    
    if ([self.mBlogData.text length] > 0) {
        if (nIndex == 1) {
            BlogTextCell *textCell = (BlogTextCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailTextCellID"];
            [textCell fillContent:self.mBlogData forHeight:YES];
            
            return textCell.mfHeight;
        }
        
        nIndex--;
    }
    
    switch (nIndex) {
        case 1: {
            return 38;
        }
            
        case 2: {
            return 46;
        }
            
        default: {
            CommentTableViewCell *cell = [self configureCommentCell:tableView index:nIndex - 3 forHeight:YES];
            height = cell.mfHeight;
            break;
        }
    }
    
    return height;
}

#pragma mark -

- (void)onButSegment:(id)sender {
    self.mnCommentType = (int)((UIButton*)sender).tag;
    self.mViewComment.mnCommentType = self.mnCommentType;
    [self.mTableView reloadData];
}

- (void)onButChat:(id)sender {
    [self performSegueWithIdentifier:@"Detail2Message" sender:nil];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


- (void)animationView:(CGFloat)yPos {
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
    { //phone
        
        CGSize sz = [[UIScreen mainScreen] bounds].size;
        if(yPos == sz.height - self.view.frame.size.height)
            return;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rt = self.view.frame;
                             rt.size.height = sz.height - yPos;
//                             NSLog(@"animationview: %f", rt.size.height);
                             self.view.frame = rt;
                             
                             [self.view layoutIfNeeded];
                         }completion:^(BOOL finished) {
                             if (mbShoudScroll) {
                                 NSInteger rows = [self.mTableView numberOfRowsInSection:0];
                                 
                                 if(rows > 0) {
                                     [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                                            atScrollPosition:UITableViewScrollPositionBottom
                                                                    animated:YES];
                                 }
                                 
                                 mbShoudScroll = NO;
                             }
                         }];
    }
}

#pragma mark - KeyBoard notifications
- (void)keyboardWillShow:(NSNotification*)notify {
	CGRect rtKeyBoard = [(NSValue*)[notify.userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [self animationView:rtKeyBoard.size.width];
    }
    else {
        [self animationView:rtKeyBoard.size.height];
    }
    
    mbKeyboardOn = YES;
}

- (void)keyboardWillHide:(NSNotification*)notify {
	[self animationView:0];
    
    mbKeyboardOn = NO;
}

# pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self onButSend:nil];
    
    return YES;
}


- (IBAction)onButSend:(id)sender {
    
//    if (sender) {
//        [self.view endEditing:YES];
//    }
//    
//    if ([self.mTxtComment.text length] == 0) {
//        return;
//    }
//    
//    NSString *strComment = [self.mTxtComment.text substringToIndex:MIN(self.mTxtComment.text.length, 100)];
//    
//    //
//    // save to notification database
//    //
//    NotificationData *notifyObj = [NotificationData object];
//    notifyObj.blog = self.mBlogData;
//    notifyObj.user = [UserData currentUser];
//    notifyObj.username = [[UserData currentUser] getUsernameToShow];
//    notifyObj[@"targetuser"] = self.mBlogData.user;
//    notifyObj.thumbnail = self.mBlogData.image;
//    notifyObj.type = NOTIFICATION_COMMENT;
//    notifyObj.comment = strComment;
//    notifyObj.isnew = [NSNumber numberWithBool:YES];
//    notifyObj[@"isread"] = @(NO);
//    
//    [notifyObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
////        [self.mButSend setBackgroundColor:mColorNormal];
//        
//        if (succeeded) {
//            //
//            // add comment object
//            //
//            [self.mBlogData.maryCommentData addObject:notifyObj];
//            AVRelation *relation = self.mBlogData.commentobject;
//            [relation addObject:notifyObj];
//            
//            // set popularity
//            [self.mBlogData incrementKey:@"likecomment"];
//            [self.mBlogData calculatePopularity];
//            
//            [self.mBlogData saveInBackground];
//            
//            [self.mTableView reloadData];
//            
//            [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mBlogData.maryCommentData.count inSection:0]
//                                   atScrollPosition:UITableViewScrollPositionTop
//                                           animated:YES];
//            
//            [self.mButSend setEnabled:YES];
//        }
//        else {
//            [self showNotice];
//        }
//    }];
//    
////    [self.mButSend setBackgroundColor:mColorDisable];
//    
//    [self.mTxtComment setText:@""];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.mTableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:animated];
    }
}

- (void)onButUser:(id)sender {
    mUserSelected = self.mBlogData.user;
    [self gotoMeView];
}

- (void)gotoMeView {
    if ([mUserSelected.objectId isEqualToString:[UserData currentUser].objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Detail2Me" sender:nil];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    mUserSelected = components[@"user"];
    [self gotoMeView];
}

#pragma mark - BlogRelationCellDelegate
- (void)onLikeResult:(BOOL)bResult {
    if (bResult) {
        [self.mTableView reloadData];
    }
    else {
        [self showNotice];
    }
}

#pragma mark - BlogContentDelegate
- (void)touchedTagView {
    [self dismissKeyboard:nil];
}

#pragma mark - InputCommentViewDelegate
- (void)onSentComment:(BOOL)bSucceed {
    if (bSucceed) {
        [self.mTableView reloadData];
        mbShoudScroll = YES;
    }
    else {
        [self showNotice];
    }
    
    [self dismissKeyboard:nil];
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
                         //						 self.view.userInteractionEnabled = YES;
                     }];
}


@end
