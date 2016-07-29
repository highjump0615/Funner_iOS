//
//  CameraViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "CameraViewController.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EditPhotoViewController.h"
#import "GalleryViewController.h"
#import "CommonUtils.h"

@interface CameraViewController () {
    GPUImageStillCamera *mStillCamera;
    GPUImageCropFilter *mCropFilter;
    NSURL *mURLPhoto;
    UIImage *mImgPhoto;
    UIImage *mImgThumbPhoto;
}

@property (weak, nonatomic) IBOutlet UIView *mViewNet;
@property (weak, nonatomic) IBOutlet GPUImageView *mViewCamera;
@property (weak, nonatomic) IBOutlet UIButton *mButGallery;

@end

@implementation CameraViewController

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
    
    [self initCamera];
    [self updateLastThumbnail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButNet:(id)sender {
    BOOL bVisible = self.mViewNet.hidden;
    [self.mViewNet setHidden:!bVisible];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Camera2Edit"]) {
        EditPhotoViewController *viewController = [segue destinationViewController];
        viewController.delegate = self.mAddBlogDelegate;
        viewController.mImgPhoto = mImgPhoto;
        viewController.mImgThumbPhoto = mImgThumbPhoto;
    }
    else if ([[segue identifier] isEqualToString:@"Camera2Gallery"]) {
        GalleryViewController *viewController = [segue destinationViewController];
        viewController.mAddBlogDelegate = self.mAddBlogDelegate;
    }
}


- (void)initCamera
{
    mStillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    
    mStillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
//    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    mCropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.f, 0.0f, 1.f, .75f)];
    [mCropFilter addTarget:self.mViewCamera];
    
    [mStillCamera addTarget:mCropFilter];
    [mStillCamera startCameraCapture];
}

- (IBAction)onButSwitchCamera:(id)sender {
    [mStillCamera rotateCamera];
}

- (IBAction)onButShutter:(id)sender {
    [mStillCamera capturePhotoAsJPEGProcessedUpToFilter:mCropFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error){

        mImgPhoto = [UIImage imageWithData:processedJPEG];
        mImgThumbPhoto = [CommonUtils imageWithImage:mImgPhoto scaledToSize:CGSizeMake(58, 57)];
        [self performSegueWithIdentifier:@"Camera2Edit" sender:nil];
        
//        // Save to assets library
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        
//        [library writeImageDataToSavedPhotosAlbum:processedJPEG metadata:mStillCamera.currentCaptureMetadata completionBlock:^(NSURL *assetURL, NSError *error2)
//         {
//             if (error2) {
//                 NSLog(@"ERROR: the image failed to be written");
//             }
//             else {
//                 mURLPhoto = assetURL;
//                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
//                 
//                 [self performSegueWithIdentifier:@"Camera2Edit" sender:nil];
//             }
//			 
////             runOnMainQueueWithoutDeadlocking(^{
////                 [photoCaptureButton setEnabled:YES];
////             });
//         }];
    }];
}

- (void)updateLastThumbnail
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                UIImage *thumbNail = [UIImage imageWithCGImage:[alAsset thumbnail]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                if (thumbNail != nil)
                {
                    // Do something interesting with the AV asset.
                    [self.mButGallery setImage:thumbNail forState:UIControlStateNormal];
                }
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
}


@end
