//
//  InviteViewController.m
//  Funner
//
//  Created by highjump on 14-11-9.
//
//

#import "InviteViewController.h"
#import "WXApi.h"

#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface InviteViewController ()/* <TencentSessionDelegate>*/

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation InviteViewController

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InviteCellID"];
    
    UIImageView *imgMenu = (UIImageView *)[cell viewWithTag:101];
    UILabel *lblTitle = (UILabel *)[cell viewWithTag:102];
    
    switch (indexPath.row) {
        case 0:
            [imgMenu setImage:[UIImage imageNamed:@"invite_wechat.png"]];
            [lblTitle setText:@"微信联系人"];
            break;
            
        case 1:
            [imgMenu setImage:[UIImage imageNamed:@"invite_phone.png"]];
            [lblTitle setText:@"手机联系人"];
            break;
            
        case 2:
            [imgMenu setImage:[UIImage imageNamed:@"invite_qq.png"]];
            [lblTitle setText:@"QQ好友"];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self sendWechatFriend];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"Invite2PhoneContact" sender:nil];
            break;
            
        case 2:
            [self sendQQFriend];
            break;
            
        default:
            break;
    }
}

- (void)sendWechatFriend {
    // 发送内容给微信
//    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//    req.text = @"我在“乐呀”跟朋友一起玩爱好，你也一起来吧！\n点击加入“乐呀”：http://www.cnmtoc.com";
//    req.bText = YES;
//    req.scene = WXSceneSession;
//    
//    if (![WXApi sendReq:req]) {
//        NSLog(@"asdfasdf");
//    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"乐呀";
    message.description = @"我在“乐呀”和朋友一起玩，你也快来“乐呀”和我们玩吧！";
    [message setThumbImage:[UIImage imageNamed:@"icon60.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = @"https://itunes.apple.com/cn/app/le-ya/id970836065";
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

- (void)sendQQFriend {
//    TencentOAuth *auth = [[TencentOAuth alloc] initWithAppId:@"1103822085" andDelegate:self];
//    QQApiTextObject *txtObj = [QQApiTextObject objectWithText:@"邀请内容"];
    
    UIImage *imgLogo = [UIImage imageNamed:@"icon60.png"];
    NSData *imageData = UIImageJPEGRepresentation(imgLogo, 1.f);
    
    QQApiNewsObject *newsObj = [QQApiNewsObject  objectWithURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/le-ya/id970836065"]
                                                         title:@"乐呀"
                                                   description:@"我在“乐呀”和朋友一起玩，你也快来“乐呀”和我们玩吧！"
                                              previewImageData:imageData];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    //将内容分享到qq
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯文本分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯图片分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}


@end
