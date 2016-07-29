//
//  GalleryViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "GalleryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "EditPhotoViewController.h"
#import "CommonUtils.h"

@interface GalleryViewController () {
    NSInteger mnSelectedIndex;
    
    NSMutableArray  *maryAllImage;
    NSMutableArray  *maryAllImageThumbnail;
    ALAssetsLibrary *mAssetLibrary;
}

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;
@property (weak, nonatomic) IBOutlet UICollectionView *mCollectionView;

@end

@implementation GalleryViewController

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
    
    mnSelectedIndex = 0;
    
    // load all images from device
    maryAllImage = [[NSMutableArray alloc] init];
    maryAllImageThumbnail = [[NSMutableArray alloc] init];
    
    mAssetLibrary = [[ALAssetsLibrary alloc] init];
    
    [mAssetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group)
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
             [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
              {
                  if (asset)
                  {
                      UIImage* thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
                      
                      NSURL *imageURL = [[asset defaultRepresentation] url];
                      
                      if (thumbnail != nil)
                      {
                          [maryAllImageThumbnail addObject:thumbnail];
                          [maryAllImage addObject:imageURL];
                      }
                  }
                  
                  if (index == [group numberOfAssets] - 1)
                  {
                      [self showImage];
                      [self.mCollectionView reloadData];
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                  }
              }];
         }
         else
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }
     }
                              failureBlock:^(NSError *error)
     {
         NSLog(@"error enumerating AssetLibrary groups %@\n", error);
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }
     ];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Gallery2EditPhoto"]) {
        EditPhotoViewController *viewController =  [segue destinationViewController];
        viewController.mImgPhoto = self.mImgViewPhoto.image;
        viewController.mImgThumbPhoto = [maryAllImageThumbnail objectAtIndex:mnSelectedIndex];
        viewController.delegate = self.mAddBlogDelegate;
    }
}


- (void)showImage {
    
    [mAssetLibrary assetForURL:[maryAllImage objectAtIndex:mnSelectedIndex]
        resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            CGImageRef iref = [rep fullResolutionImage];
            if (iref) {
                UIImage *largeimage = [UIImage imageWithCGImage:iref];
                UIImage *croppedImg = [CommonUtils squareImageFromImage:largeimage scaledToSize:320];
                
                [self.mImgViewPhoto setImage:croppedImg];
            }
        }
        failureBlock:^(NSError *error) {
            NSLog(@"Can't get image - %@", [error localizedDescription]);
        }
    ];
}


#pragma mark - Collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [maryAllImageThumbnail count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCollectionID" forIndexPath:indexPath];
    
    UIImageView *imgBorderSelected = (UIImageView *)[cell viewWithTag:102];
    UIImageView *imgPhoto = (UIImageView *)[cell viewWithTag:103];
    [imgPhoto setImage:[maryAllImageThumbnail objectAtIndex:indexPath.row]];
    
    if (indexPath.row == mnSelectedIndex) {
        [imgBorderSelected setHidden:NO];
    }
    else {
        [imgBorderSelected setHidden:YES];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    mnSelectedIndex = indexPath.row;
    [self showImage];
    [self.mCollectionView reloadData];
}



@end
