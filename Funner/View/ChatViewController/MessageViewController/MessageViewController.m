//
//  MessageViewController.m
//  Funner
//
//  Created by highjump on 14-11-11.
//
//

#import "MessageViewController.h"
#import "MsgTextInTableViewCell.h"
#import "MsgImageInTableViewCell.h"
#import "MsgTextOutTableViewCell.h"
#import "MsgImageOutTableViewCell.h"
#import "FullImageView.h"
#import "CommonUtils.h"
#import "MainTabbarController.h"

#import "CDSessionManager.h"
#import "UserData.h"
#import "CommonDefine.h"

#import "SDWebImageManager.h"
#import "UserData.h"
#import "BlogData.h"

#import "UIImageView+WebCache.h"

@interface MessageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL mbMoreOn;
    
    NSArray *maryMessages;
    NSMutableArray *maryObject;
    
    FullImageView *mFullImageView;
}

@property (weak, nonatomic) IBOutlet UIView *mViewChat;
@property (weak, nonatomic) IBOutlet UIView *mViewText;
@property (weak, nonatomic) IBOutlet UITextField *mTxtContent;
@property (weak, nonatomic) IBOutlet UIView *mViewMore;
@property (weak, nonatomic) IBOutlet UIButton *mButMorePic;
@property (weak, nonatomic) IBOutlet UIButton *mButMorePhoto;
@property (weak, nonatomic) IBOutlet UIButton *mButMoreLocation;
@property (weak, nonatomic) IBOutlet UIButton *mButMoreName;
@property (weak, nonatomic) IBOutlet UIButton *mButMoreSave;
@property (weak, nonatomic) IBOutlet UIButton *mButMoreVideo;
@property (weak, nonatomic) IBOutlet UIButton *mButMoreVoice;
@property (weak, nonatomic) IBOutlet UIButton *mButMoreReal;

@property (weak, nonatomic) IBOutlet UIButton *mButSend;
@property (weak, nonatomic) IBOutlet UIButton *mButMore;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mConstraintChatHeight;

@end

@implementation MessageViewController

CGFloat const kJSAvatarImageSize = 50.0f; //TCOTS

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
    
    [self setImgTextButton:self.mButMorePic];
    [self setImgTextButton:self.mButMorePhoto];
    [self setImgTextButton:self.mButMoreLocation];
    [self setImgTextButton:self.mButMoreName];
    [self setImgTextButton:self.mButMoreSave];
    [self setImgTextButton:self.mButMoreVideo];
    [self setImgTextButton:self.mButMoreVoice];
    [self setImgTextButton:self.mButMoreReal];

    mbMoreOn = NO;
    
    maryMessages = [[NSMutableArray alloc] init];
    
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

    self.mTableView.estimatedRowHeight = UITableViewAutomaticDimension;
    
    [self.navigationItem setTitle:[self.mUser getUsernameToShow]];
    
//    // add session
//    [[CDSessionManager sharedInstance] addChatWithPeerId:self.mUser.username];
//
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageUpdated:) name:NOTIFICATION_MESSAGE_UPDATED object:nil];
    
    [[CDSessionManager sharedInstance] setUnreadToReadForPeerId:self.mUser.objectId];
    
    // update the badge
    CommonUtils *utils = [CommonUtils sharedObject];
    MainTabbarController *tabbarController = (MainTabbarController *)utils.mTabbarController;
    [tabbarController messageUpdated:nil];
    
    maryObject = [[NSMutableArray alloc] init];
    
    // full image view
    mFullImageView = (FullImageView *)[FullImageView initView:self.view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self messageUpdated:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self scrollToBottomAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)messageUpdated:(NSNotification *)notification {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString *strBlog;
    if (self.mBlog) {
        strBlog = self.mBlog.objectId;
    }
    
    maryMessages = [[CDSessionManager sharedInstance] getMessagesForPeerId:self.mUser.objectId blogId:strBlog];
    [[CDSessionManager sharedInstance] setUnreadToReadForPeerId:self.mUser.objectId];
    
    // add image object
    for (NSDictionary *dictMsg in maryMessages) {
        
        NSString *objectId = [dictMsg objectForKey:@"object"];
        if (!objectId) {
            continue;
        }
        
        BOOL bExist = NO;
        for (AVObject *obj in maryObject) {
            if ([objectId isEqualToString:obj.objectId]) {
                bExist = YES;
                break;
            }
        }
        
        if (bExist) {
            continue;
        }
        
        AVObject *object = [AVObject objectWithoutDataWithClassName:@"Attachments" objectId:objectId];
        [maryObject addObject:object];
    }

//    [self refreshTimestampArray];
    [self.mTableView reloadData];
    [self scrollToBottomAnimated:YES];
}



- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.mTableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:animated];
    }
}

- (void)setImgTextButton:(UIButton *)button {
    // the space between the image and text
    CGFloat spacing = 3.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.frame.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = button.titleLabel.frame.size;
    button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

- (IBAction)onButImage:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [picker setDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)onButCamera:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [picker setDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
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

- (void)animationView:(CGFloat)yPos {
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
    { //phone
        
        CGSize sz = [[UIScreen mainScreen] bounds].size;
        if(yPos == sz.height - self.view.frame.size.height)
            return;
//        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect rt = self.view.frame;
                             rt.size.height = sz.height - yPos;
                             
//                             NSLog(@"animationview: %f", rt.size.height);
                             self.view.frame = rt;
                             
                             [self.view layoutIfNeeded];
                         }completion:^(BOOL finished) {
//                             self.view.userInteractionEnabled = YES;
                             [self scrollToBottomAnimated:YES];
                         }];
    }
}

#pragma mark - KeyBoard notifications
- (void)keyboardWillShow:(NSNotification*)notify {
	CGRect rtKeyBoard = [(NSValue*)[notify.userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    [self animationView:rtKeyBoard.size.height];
    
    [self hideMore];
}

- (void)keyboardWillHide:(NSNotification*)notify {
	[self animationView:0];
}

# pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self hideMore];
    [textField resignFirstResponder];
    
    [self onButSend:nil];
    
    return YES;
}

- (IBAction)onButSend:(id)sender {
    
    if (sender) {
        [self.view endEditing:YES];
    }
    
    if ([self.mTxtContent.text length] == 0) {
        return;
    }
    
    NSString *strBlogId = @"";
    if (self.mBlog) {
        strBlogId = self.mBlog.objectId;
    }
    
    [[CDSessionManager sharedInstance] sendMessage:self.mTxtContent.text toPeerId:self.mUser.objectId blogId:strBlogId];
    
    [self sendPushNotification:self.mTxtContent.text];
    
    [self.mTxtContent setText:@""];
}

- (void)sendPushNotification:(NSString *)strText {
    //
    // send notification to commented user
    //
    AVQuery *query = [AVInstallation query];
    [query whereKey:@"user" equalTo:self.mUser];
    
    [AVPush setProductionMode:YES];
    
    // Send the notification.
    AVPush *push = [[AVPush alloc] init];
    [push setQuery:query];
    
    UserData *currentUser = [UserData currentUser];
    NSString *strMsg = [NSString stringWithFormat:@"%@: %@", [currentUser getUsernameToShow], strText];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          strMsg, @"alert",
                          //                          @"comment", @"notifyType",
                          //                          self.mZappData.object.objectId, @"notifyZapp",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          nil];
    [push setData:data];
    [push sendPushInBackground];
}

- (void)hideMore {
    if (mbMoreOn) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self.mConstraintChatHeight setConstant:0];
                             [self.view layoutIfNeeded];
                         }completion:^(BOOL finished) {
                             //						 self.view.userInteractionEnabled = YES;
                         }];
        mbMoreOn = NO;
        [self.mButMore setImage:[UIImage imageNamed:@"chat_more.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)onButMore:(id)sender {
    
    if (mbMoreOn) {
        [self hideMore];
    }
    else {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self.mConstraintChatHeight setConstant:self.mViewMore.frame.size.height];
                             [self.view layoutIfNeeded];
                         }completion:^(BOOL finished) {
                         }];

        mbMoreOn = YES;
        [self.mButMore setImage:[UIImage imageNamed:@"chat_more_selected.png"] forState:UIControlStateNormal];
    }
    
    [self.view endEditing:YES];
}

- (void)didRecognizeSingleTap:(id)sender
{
    UITapGestureRecognizer *gestureRecognizer = (UITapGestureRecognizer*)sender;
    UIImageView *imgView = (UIImageView *)gestureRecognizer.view;
    
    NSInteger nRow = imgView.tag;
    NSIndexPath *path = [NSIndexPath indexPathForRow:nRow inSection:0];
    CGRect rtCell = [self.mTableView rectForRowAtIndexPath:path];
    rtCell.origin.y -= self.mTableView.contentOffset.y;
    rtCell.origin.y += 64;
    
    CGRect rtImgView = imgView.frame;
    CGRect rtBubbleView = imgView.superview.frame;
    rtImgView.origin.x += rtBubbleView.origin.x + rtCell.origin.x;
    rtImgView.origin.y += rtBubbleView.origin.y + rtCell.origin.y;
    
    // set image url
    NSDictionary *dictMsg = [maryMessages objectAtIndex:nRow];
    NSString *strObjectId = dictMsg[@"object"];
    AVObject *objAttach;
    
    for (AVObject *obj in maryObject) {
        if ([obj.objectId isEqualToString:strObjectId]) {
            objAttach = obj;
            break;
        }
    }
    
    if (objAttach) {
        AVFile *file = [objAttach objectForKey:@"image"];
        [mFullImageView showView:rtImgView url:file.url];
    }
}


#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger nCount = [maryMessages count];
    
    if (self.mBlog) {
        nCount++;
    }
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (self.mBlog && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BlogImgCellID"];
        
        UIImageView *imgviewBlog = (UIImageView *)[cell viewWithTag:100];
        
        [self.mBlog fetchIfNeededInBackgroundWithBlock:^(AVObject *object, NSError *error) {
            [imgviewBlog sd_setImageWithURL:[NSURL URLWithString:self.mBlog.image.url]
                           placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
        }];
    }
    else {
        cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath modifyCell:YES];
    }
    
    return cell;
}

- (UITableViewCell *)configureCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath modifyCell:(BOOL)bModify {
    UITableViewCell *cell;
    
    NSInteger nIndex = indexPath.row;
    
    if (self.mBlog) {
        nIndex--;
    }
    
    NSDictionary *dictMsg = [maryMessages objectAtIndex:nIndex];
    NSString *strFromId = dictMsg[@"fromid"];
    NSString *strType = dictMsg[@"type"];
    
    BOOL bNeedShowTime = YES;
    if (nIndex > 0) {
        NSDictionary *dictPrevMsg = [maryMessages objectAtIndex:nIndex - 1];
        
        NSDate *dateMsg = dictMsg[@"time"];
        NSDate *datePrevMsg = dictPrevMsg[@"time"];
        
        NSTimeInterval diff = [dateMsg timeIntervalSinceDate:datePrevMsg];
        if (diff <= 60) {
            bNeedShowTime = NO;
        }
    }
    
    if ([strFromId isEqualToString:self.mUser.objectId]) {
        if ([strType isEqualToString:@"text"]) {
            MsgTextInTableViewCell *msgTextInCell = [tableView dequeueReusableCellWithIdentifier:@"TextInCellID"];
            [msgTextInCell fillContent:dictMsg user:self.mUser showTime:bNeedShowTime];
            
            cell = msgTextInCell;
        }
        else if ([strType isEqualToString:@"image"]) {
            MsgImageInTableViewCell *msgImageInCell = [tableView dequeueReusableCellWithIdentifier:@"ImageInCellID"];
            
            NSString *strObjectId = dictMsg[@"object"];
            AVObject *objAttach;
            
            if (bModify) {
                for (AVObject *obj in maryObject) {
                    if ([obj.objectId isEqualToString:strObjectId]) {
                        objAttach = obj;
                        break;
                    }
                }
                
                // add tap guesture
                if ([msgImageInCell.mImgViewPhoto.gestureRecognizers count] == 0) {
                    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                                   initWithTarget:self action:@selector(didRecognizeSingleTap:)];
                    [singleTapRecognizer setNumberOfTapsRequired:1];
                    
                    [msgImageInCell.mImgViewPhoto addGestureRecognizer:singleTapRecognizer];
                    msgImageInCell.mImgViewPhoto.tag = nIndex;
                }
            }
            
            [msgImageInCell fillContent:dictMsg user:self.mUser object:objAttach showTime:bNeedShowTime];
            
            cell = msgImageInCell;
        }
    }
    else {
        if ([strType isEqualToString:@"text"]) {
            MsgTextOutTableViewCell *msgTextOutCell = [tableView dequeueReusableCellWithIdentifier:@"TextOutCellID"];
            [msgTextOutCell fillContent:dictMsg user:[UserData currentUser] showTime:bNeedShowTime];
            
            cell = msgTextOutCell;
        }
        else if ([strType isEqualToString:@"image"]) {
            MsgImageOutTableViewCell *msgImageOutCell = [tableView dequeueReusableCellWithIdentifier:@"ImageOutCellID"];
            
            NSString *strObjectId = dictMsg[@"object"];
            AVObject *objAttach;
            
            if (bModify) {
                for (AVObject *obj in maryObject) {
                    if ([obj.objectId isEqualToString:strObjectId]) {
                        objAttach = obj;
                        break;
                    }
                }
                
                // add tap guesture
                if ([msgImageOutCell.mImgViewPhoto.gestureRecognizers count] == 0) {
                    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                                   initWithTarget:self action:@selector(didRecognizeSingleTap:)];
                    
                    [singleTapRecognizer setNumberOfTapsRequired:1];
                    [msgImageOutCell.mImgViewPhoto addGestureRecognizer:singleTapRecognizer];
                    msgImageOutCell.mImgViewPhoto.tag = nIndex;
                }
            }
            
            [msgImageOutCell fillContent:dictMsg user:[UserData currentUser] object:objAttach showTime:bNeedShowTime];
            
            
            cell = msgImageOutCell;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    UITableViewCell *cell;
    
    if (self.mBlog && indexPath.row == 0) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        height = screenRect.size.width;
    }
    else {
        cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath modifyCell:NO];
        if (cell) {
            height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        }
    }
    
    return height;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
////    [self.view endEditing:YES];
//}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *imgMessage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIGraphicsEndImageContext();
    
    double dWidth = [image size].width;
    double dHeight = [image size].height;
    double dScale = 200.0 / (dWidth > dHeight ? dWidth : dHeight);
    dScale = dScale < 1.0 ? dScale : 1.0;
    dWidth = dWidth * dScale;
    dHeight = dHeight * dScale;
    
    NSData *data = UIImageJPEGRepresentation([self compressImage:imgMessage], 1.f);
    if (data) {
        AVFile *imageFile = [AVFile fileWithName:@"image.png" data:data];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                AVObject *object = [AVObject objectWithClassName:@"Attachments"];
                [object setObject:@"image" forKey:@"type"];
                [object setObject:imageFile forKey:@"image"];
                [object setObject:[NSNumber numberWithDouble:dWidth] forKey:@"width"];
                [object setObject:[NSNumber numberWithDouble:dHeight] forKey:@"height"];
                
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self sendAttachment:object width:dWidth height:dHeight];
                    }
                }];
                
                // save to sd web image
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageFile.url]];
                UIImage *imgPost = [UIImage imageWithData:data];
                [[SDImageCache sharedImageCache] storeImage:imgPost forKey:key toDisk:YES];
            }
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self hideMore];
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark -

- (void)sendAttachment:(AVObject *)object width:(double)dWidth height:(double)dHeight {
    NSString *strBlogId = @"";
    if (self.mBlog) {
        strBlogId = self.mBlog.objectId;
    }
    
    [[CDSessionManager sharedInstance] sendAttachment:object
                                             toPeerId:self.mUser.objectId
                                               blogId:strBlogId
                                                width:dWidth
                                               height:dHeight];
    
    [self sendPushNotification:@"[图片]"];
}

- (UIImage *)compressImage:(UIImage *)image
{
    float fMaxWidth = (float)((self.view.frame.size.width - kJSAvatarImageSize) * 0.8f);
    if(image.size.width > fMaxWidth)
    {
        float fScale = image.size.width / fMaxWidth;
        
        UIGraphicsBeginImageContext(CGSizeMake(floor(fMaxWidth), floor(image.size.height / fScale)));
        [image drawInRect:CGRectMake(0, 0, floor(fMaxWidth), floor(image.size.height / fScale))];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return smallImage;
    }
    else {
        return image;
    }
}


@end
