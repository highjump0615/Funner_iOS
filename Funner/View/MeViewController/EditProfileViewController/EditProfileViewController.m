//
//  EditProfileViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "EditProfileViewController.h"
#import "CommonUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"
#import "UserData.h"
#import "AppDelegate.h"

#import "CustomActionSheetView.h"

@interface EditProfileViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomActionSheetDelegate> {
    UIImageView *mImgPhoto;
    CustomActionSheetView *mActionsheetView;
    
    UIImagePickerController *mImagePicker;
}

@end

@implementation EditProfileViewController

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
    
    mActionsheetView = (CustomActionSheetView *)[CustomActionSheetView initView:self.view
                                                                   ButtonTitle1:@""
                                                                   ButtonTitle2:@"拍照"
                                                                   ButtonTitle3:@"从手机相册选择"
                                                                 removeOnCancel:NO];
    mActionsheetView.delegate = self;
    
    if (!self.mbFromSignup) {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    else {
        [self.navigationItem setHidesBackButton:YES];
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

- (IBAction)onButOk:(id)sender {
//    [self performSegueWithIdentifier:@"EditProfile2Main" sender:nil];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setRootView];
}

#pragma mark - TableViewDeleage

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 3;
		default:
			break;
	}
	return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EditProfilePhotoCellID"];
        
        mImgPhoto = (UIImageView *)[cell viewWithTag:101];
        double dRadius = mImgPhoto.frame.size.height / 2;
        [mImgPhoto.layer setMasksToBounds:YES];
        [mImgPhoto.layer setCornerRadius:dRadius];
        
        //
        // user photo
        //
        UserData *currentUser = [UserData currentUser];
        AVFile *photoFile = currentUser.photo;
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [mImgPhoto setImage:[UIImage imageWithData:data]];
        }];
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EditProfileCellID"];
        
        switch (indexPath.row) {
            case 0:
                [cell.textLabel setText:@"昵称"];
                break;
                
            case 1:
                [cell.textLabel setText:@"简介"];
                break;
                
            case 2:
                [cell.textLabel setText:@"修改密码"];
                break;
                
            default:
                break;
        }
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	if (indexPath.section == 0) {
        [mActionsheetView showView];
	}
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"Edit2Username" sender:nil];
                break;
                
            case 1:
                [self performSegueWithIdentifier:@"Edit2Aboutme" sender:nil];
                break;
                
            case 2:
                [self performSegueWithIdentifier:@"Edit2Password" sender:nil];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - CustomActionSheetDelegate
- (void)onButSecond:(UIView *)view {
    [self shouldStartCameraController];
}

- (void)onButThird:(UIView *)view {
    [self shouldStartPhotoLibraryPickerController];
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.showsCameraControls = YES;
    mImagePicker.delegate = self;
    
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie, nil];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.delegate = self;
    
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [mImgPhoto setImage:[info objectForKey:UIImagePickerControllerEditedImage]];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // saving photo image
    UIImage* convertImage = [CommonUtils imageWithImage:mImgPhoto.image scaledToSize:CGSizeMake(70, 70)];
    
    NSData *imageData = UIImageJPEGRepresentation(convertImage, 1.f);
    
    AVFile *imageFile = [AVFile fileWithName:@"photo.jpg" data:imageData];
    UserData *currentUser = [UserData currentUser];
    
    if (currentUser.photo) {
        AVFile *oldImg = currentUser.photo;
        [oldImg deleteInBackground];
    }
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error) {
            // Create a PFObject around a PFFile and associate it with the current user
            currentUser.photo = imageFile;
            [currentUser saveInBackground];
        }
        else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    if (mImagePicker) {
        mImagePicker.navigationBar.barStyle = UIBarStyleBlack;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}



@end
