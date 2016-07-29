//
//  EditPhotoViewController.m
//  Funner
//
//  Created by highjump on 14-11-10.
//
//

#import "EditPhotoViewController.h"
#import "EffectItemView.h"
#import "CommonUtils.h"
#import "PlaceholderTextView.h"
#import "GPUImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TagItemView.h"
#import "HashTagView.h"
#import "HashTagData.h"
#import "CategoryData.h"
#import "MBProgressHUD.h"
#import "PlaceholderTextView.h"
#import "HobbyViewController.h"
#import "BlogData.h"
#import "UserData.h"

#import "SDWebImageManager.h"

#define kEditFilterTab 0
#define kEditTagTab 1
#define kEditDescTab 2

#define kUserDefaultMyTag   @"ArrayMyTag"

typedef enum {
    GPUIMAGE_NONE = 0,
    GPUIMAGE_BLAZE,
    GPUIMAGE_CONTRAST,
    GPUIMAGE_SATURATION,
    GPUIMAGE_RGB,
    GPUIMAGE_ENVY,
    GPUIMAGE_ADAM,
    GPUIMAGE_BELLA,
    GPUIMAGE_INVERT,
    GPUIMAGE_TYNSET,
    GPUIMAGE_SENSO,
    GPUIMAGE_COWBOY,
    GPUIMAGE_AHA,
    GPUIMAGE_EMBOSS,
    GPUIMAGE_SKETCH,
    GPUIMAGE_DIRECTOR,
    GPUIMAGE_NUMFILTERS
} GPUImageShowcaseFilterType;


@interface EditPhotoViewController () <HashTagViewDelegate, UIGestureRecognizerDelegate> {
    NSInteger mnSelectedTab;
    NSInteger mnSelectedFitler;
    
    GPUImageShowcaseFilterType mnCurFilterType;
    
    NSMutableArray *maryEffectView;
    
    NSMutableArray *maryMyTag;
    
    MBProgressHUD *mHud;
    
    UIButton *mbutTagSelected;
    UIColor *mColorSelected;
}

@property (weak, nonatomic) IBOutlet UIButton *mButFilter;
@property (weak, nonatomic) IBOutlet UIButton *mButTag;
@property (weak, nonatomic) IBOutlet UIButton *mButDesc;

@property (weak, nonatomic) IBOutlet UIScrollView *mFilterScrollView;

@property (weak, nonatomic) IBOutlet UIView *mViewFilter;
@property (weak, nonatomic) IBOutlet UIView *mViewDesc;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *mTxtDesc;

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;
@property (weak, nonatomic) IBOutlet HashTagView *mViewTag;
@property (weak, nonatomic) IBOutlet UIView *mViewTagList;
@property (weak, nonatomic) IBOutlet UIScrollView *mTagScrollView;

@end

@implementation EditPhotoViewController

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
    
    mColorSelected = [UIColor colorWithRed:82/255.0 green:159/255.0 blue:205/255.0 alpha:1.0];
    
    mnSelectedFitler = 0;
    mnSelectedTab = kEditFilterTab;
    
    //
    // initialize text input
    //
    [self.mTxtDesc setPlaceholder:@"请输入你想说的话"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    //
    // init photo view
    //
    if (self.mImgPhoto) {
        [self.mImgViewPhoto setImage:self.mImgPhoto];
    }
    
    //
    // initialize filter
    //
    maryEffectView = [[NSMutableArray alloc] init];
    
    NSInteger nItemWidth = 0, nItemHeight;
    int i = 0;
    for (i = 0; i < GPUIMAGE_NUMFILTERS; i++) {
        EffectItemView *itemView = [EffectItemView itemView];
        nItemWidth = itemView.frame.size.width;
        nItemHeight = itemView.frame.size.height;
        
        [itemView.mButEffect addTarget:self action:@selector(onButEffect:) forControlEvents:UIControlEventTouchUpInside];
        itemView.mButEffect.tag = i;
        [itemView setFrame:CGRectMake(i * nItemWidth, 10, nItemWidth, nItemHeight)];
        
        NSDictionary *dic = [self filterFromType:(GPUImageShowcaseFilterType)i];
        
        [itemView.mButEffect setImage:self.mImgThumbPhoto forState:UIControlStateNormal];
        [itemView.mLblName setText:[dic objectForKey:@"FilterName"]];
        
        [maryEffectView addObject:itemView];
        [self.mFilterScrollView addSubview:itemView];
    }
    
    [self.mFilterScrollView setContentSize:CGSizeMake(nItemWidth * i, self.mFilterScrollView.frame.size.height)];
    
    // apply filter to thumbnails
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < GPUIMAGE_NUMFILTERS; i++) {
            EffectItemView *itemView = [maryEffectView objectAtIndex:i];
            
            NSDictionary *dic = [self filterFromType:(GPUImageShowcaseFilterType)i];
            GPUImageOutput <GPUImageInput> *filter = [dic objectForKeyedSubscript:@"Filter"];
            
            if (filter != nil)
            {
                UIImage *image = [filter imageByFilteringImage:self.mImgThumbPhoto];
                [itemView.mButEffect setImage:image forState:UIControlStateNormal];
            }
        }
    });
    
    //
    // initialize hash tag
    //
    [self.mViewTag initWithDelegate:self];
    
    // load tag array from user default
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:kUserDefaultMyTag] != nil) {
        NSArray *aryTemp= [userDefaults objectForKey:kUserDefaultMyTag];
        maryMyTag = [[NSMutableArray alloc] initWithArray:aryTemp];
    }
    else {
        maryMyTag = [[NSMutableArray alloc] init];
    }
}

- (void)viewDidLayoutSubviews {
//    if (!mbShowedTag) {
//        [self reloadTagScroll];
//        mbShowedTag = YES;
//    }
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateTabButtons];
    [self updateFilter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (IBAction)onButBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButPost:(id)sender {
    
    mHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mHud.labelText = @"正在上传...";
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
//    UIImage *resizedImage = [CommonUtils imageWithImage:self.mImgViewPhoto.image scaledToSize:CGSizeMake(320, 320)];
    UIImage *resizedImage = [CommonUtils imageWithImage:self.mImgViewPhoto.image scaledToWidth:utils.mfBlogImgSize / 2];
//    UIImage *thumbnailImage = [CommonUtils imageWithImage:self.mImgViewPhoto.image scaledToSize:CGSizeMake(58, 58)];
    UIImage *thumbnailImage = [CommonUtils imageWithImage:self.mImgViewPhoto.image scaledToWidth:91];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Invalid Image to Post"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    HobbyViewController *parentViewController = (HobbyViewController *)self.delegate;

    BlogData *blogObject = [BlogData object];
    blogObject.user = [UserData currentUser];
    blogObject.text = self.mTxtDesc.text;
    blogObject.username = [[UserData currentUser] getUsernameToShow];
    
    blogObject.image = [AVFile fileWithData:imageData];
    blogObject.thumbnail = [AVFile fileWithData:thumbnailImageData];
    blogObject.category = parentViewController.mCategory;
    
    // add hastag data
    for (HashTagData *tData in self.mViewTag.maryTag) {
        
        [tData convertPos];
        
        NSDictionary *dicTag = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:tData.mptPos.x], @"posX",
                                                                            [NSNumber numberWithDouble:tData.mptPos.y], @"posY",
                                                                            tData.mstrTag, @"string", nil];
        [blogObject addObject:dicTag forKey:@"hashtag"];
    }
    
    // save object to backend
    [blogObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [mHud removeFromSuperview];
        
        if (!error) {
            // save to sd web image
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:blogObject.image.url]];
            UIImage *imgPost = [UIImage imageWithData:imageData];
            [[SDImageCache sharedImageCache] storeImage:imgPost forKey:key toDisk:YES];
            
            [blogObject fillData];
            
            blogObject.mbGotComment = YES;
            blogObject.mbGotLike = YES;
            
            [self.delegate addBlog:blogObject];
            
            [self onButBack:nil];
        }
        else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)onButEffect:(id)sender {
    mnSelectedFitler = (int)((UIButton*)sender).tag;
    [self updateFilter];
}

- (void) updateFilter {
    for (NSUInteger i = 0; i < [maryEffectView count]; i++) {
        EffectItemView *itemView = [maryEffectView objectAtIndex:i];
        
        if (i == mnSelectedFitler) {
            [itemView.mImgSelected setHidden:NO];
            [itemView.mLblName setTextColor:mColorSelected];
            
            NSDictionary *dic = [self filterFromType:(GPUImageShowcaseFilterType)i];
            GPUImageOutput <GPUImageInput> *filter = [dic objectForKeyedSubscript:@"Filter"];
            
            if (filter != nil)
            {
                UIImage *image = [filter imageByFilteringImage:self.mImgPhoto];
                [self.mImgViewPhoto setImage:image];
            }
        }
        else {
            [itemView.mImgSelected setHidden:YES];
            [itemView.mLblName setTextColor:[UIColor whiteColor]];
        }
    }
}

- (void) updateTabButtons {
    
    
    [self.mButFilter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mButTag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mButDesc setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.mViewTag setUserInteractionEnabled:NO];
    
    [self.mViewFilter setHidden:YES];
    [self.mViewDesc setHidden:YES];
    [self.mViewTagList setHidden:YES];
    
    if (mnSelectedTab == kEditFilterTab) {
        [self.mButFilter setTitleColor:mColorSelected  forState:UIControlStateNormal];
        [self.mViewFilter setHidden:NO];
    }
    else if (mnSelectedTab == kEditTagTab) {
        [self.mButTag setTitleColor:mColorSelected  forState:UIControlStateNormal];
        [self reloadTagScroll];
        [self.mViewTag setUserInteractionEnabled:YES];
        [self.mViewTagList setHidden:NO];
    }
    else if (mnSelectedTab == kEditDescTab) {
        [self.mButDesc setTitleColor:mColorSelected  forState:UIControlStateNormal];
        [self.mViewDesc setHidden:NO];
    }
    
    [self.view endEditing:YES];
}

- (IBAction)onButFilter:(id)sender {
    mnSelectedTab = kEditFilterTab;
    [self updateTabButtons];
}

- (IBAction)onButTag:(id)sender {
    mnSelectedTab = kEditTagTab;
    [self updateTabButtons];
}

- (IBAction)onButDesc:(id)sender {
    mnSelectedTab = kEditDescTab;
    [self updateTabButtons];
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
                         }completion:^(BOOL finished) {
                             //                             self.view.userInteractionEnabled = YES;
                         }];
    }
}

#pragma mark - KeyBoard notifications
- (void)keyboardWillShow:(NSNotification*)notify {
	CGRect rtKeyBoard = [(NSValue*)[notify.userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    
    if (mnSelectedTab == 2) {
        [self animationView:rtKeyBoard.size.height];
    }
}

- (void)keyboardWillHide:(NSNotification*)notify {
	[self animationView:0];
}


#pragma mark - GPUImage Filter

- (NSDictionary*)filterFromType:(GPUImageShowcaseFilterType)type
{
    GPUImageOutput <GPUImageInput> *filter;
    NSString *strCaption;
    
    switch (type)
    {
        case GPUIMAGE_NONE:
        {
            strCaption = @"None";
            filter = [[GPUImageBrightnessFilter alloc] init];
            [((GPUImageBrightnessFilter*)filter) setBrightness:0];
        }; break;
        case GPUIMAGE_BLAZE:
        {
            strCaption = @"Blaze";
            filter = (GPUImageBrightnessFilter*)[[GPUImageBrightnessFilter alloc] init];
            [(GPUImageBrightnessFilter*)filter setBrightness:0.4];
        }; break;
        case GPUIMAGE_CONTRAST:
        {
            strCaption = @"Contrast";
            filter = [[GPUImageContrastFilter alloc] init];
            [(GPUImageContrastFilter*)filter setContrast:3.0];
        }; break;
        case GPUIMAGE_SATURATION:
        {
            strCaption = @"Saturation";
            filter = [[GPUImageSaturationFilter alloc] init];
            [(GPUImageSaturationFilter*)filter setSaturation:1.5];
        }; break;
        case GPUIMAGE_RGB:
        {
            strCaption = @"1970";
            filter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter*)filter setBlue:0.5];
        }; break;
        case GPUIMAGE_ENVY:
        {
            strCaption = @"Envy";
            filter = [[GPUImageHueFilter alloc] init];
        }; break;
        case GPUIMAGE_ADAM:
        {
            strCaption = @"Adam";
            filter = [[GPUImageAmatorkaFilter alloc] init];
        }; break;
        case GPUIMAGE_BELLA:
        {
            strCaption = @"Bella";
            filter = [[GPUImageMissEtikateFilter alloc] init];
        }; break;
        case GPUIMAGE_INVERT:
        {
            strCaption = @"Invert";
            filter = [[GPUImageColorInvertFilter alloc] init];
        }; break;
        case GPUIMAGE_TYNSET:
        {
            strCaption = @"Tynset";
            filter = [[GPUImageGrayscaleFilter alloc] init];
        }; break;
        case GPUIMAGE_SENSO:
        {
            strCaption = @"Senso";
            filter = [[GPUImageMonochromeFilter alloc] init];
        }; break;
        case GPUIMAGE_COWBOY:
        {
            strCaption = @"Cowboy";
            filter = [[GPUImageSepiaFilter alloc] init];
        }; break;
        case GPUIMAGE_AHA:
        {
            strCaption = @"Aha";
            filter = [[GPUImageToonFilter alloc] init];
        }; break;
        case GPUIMAGE_EMBOSS:
        {
            strCaption = @"Emboss";
            filter = [[GPUImageEmbossFilter alloc] init];
        }; break;
        case GPUIMAGE_SKETCH:
        {
            strCaption = @"Sketch";
            filter = [[GPUImageSketchFilter alloc] init];
        }; break;
        case GPUIMAGE_DIRECTOR:
        {
            strCaption = @"Director";
            filter = [[GPUImageVignetteFilter alloc] init];
        }; break;
        default:
            break;
    }
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:strCaption, @"FilterName", filter, @"Filter", nil];
    return dic;
}

#pragma mark - HashTagViewDelegate
- (void)addHashTag:(HashTagData *)tagData {

    BOOL bExisting = NO;
    for (NSString *strTag in maryMyTag) {
        if ([tagData.mstrTag isEqualToString:strTag]) {
            bExisting = YES;
        }
    }
    
    if (bExisting) {
        return;
    }
    
    // add to my tag list and update scroll view
    [maryMyTag addObject:tagData.mstrTag];
    [self reloadTagScroll];
    
    [self saveTagToUserDefault];
}

#pragma mark -

- (void)saveTagToUserDefault {
    // save tags to user default
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:maryMyTag forKey:kUserDefaultMyTag];
}

- (void)reloadTagScroll {
    
    int nItemMargin = 10, nBottomMargin = 10;
    
    // remove all subobjects
    for (UIView *subview in [self.mTagScrollView subviews]) {
        if ([subview isKindOfClass:[TagItemView class]]) {
            TagItemView *tagView = (TagItemView*)subview;
            for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                [subview removeGestureRecognizer:gesture];
            }
            
            [tagView.mButTag removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        }
        [subview removeFromSuperview];
    }
    
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    
    int i = 0;
    
    for (NSString *strTag in maryMyTag) {
        TagItemView *tagitemView = [TagItemView itemView:CGPointZero Tag:strTag];
        
        CGRect newRect = tagitemView.frame;
        
        if (gotPreviousFrame) {
            if (previousFrame.origin.x + previousFrame.size.width + tagitemView.frame.size.width + nItemMargin > self.mTagScrollView.frame.size.width) {
                newRect.origin = CGPointMake(0, previousFrame.origin.y + tagitemView.frame.size.height + nBottomMargin);
            }
            else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + nItemMargin, previousFrame.origin.y);
            }
            newRect.size = tagitemView.frame.size;
        }
        else {
            newRect.origin.y += nBottomMargin;
        }
        
        [tagitemView setFrame:newRect];
        
        previousFrame = tagitemView.frame;
        gotPreviousFrame = YES;
        
        [tagitemView.mImgViewCircle setHidden:YES];
        [tagitemView.mButTag setHidden:NO];
        [tagitemView.mButTag addTarget:self action:@selector(onTag:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [tagitemView.mButTag addGestureRecognizer:longPress];
        
        [tagitemView.mButTag setTag:i];
        i++;
        
        [self.mTagScrollView addSubview:tagitemView];
    }
    
    CGSize sizeFit = CGSizeMake(self.mTagScrollView.frame.size.width, previousFrame.origin.y + previousFrame.size.height + nBottomMargin + 1.0f);
    self.mTagScrollView.contentSize = sizeFit;
}

- (void)onTag:(id)sender {
    UIButton *butTag = (UIButton *)sender;
    
    for (UIView *subview in [self.mTagScrollView subviews]) {
        if ([subview isKindOfClass:[TagItemView class]]) {
            TagItemView *tagView = (TagItemView*)subview;
            if ([tagView.mButTag isEqual:butTag]) {
                NSInteger nTagIndex = [butTag tag];
                NSString *strTag = [maryMyTag objectAtIndex:nTagIndex];
                CGPoint ptPos = CGPointMake(self.mViewTag.frame.size.width / 2, self.mViewTag.frame.size.height / 2);
                
                TagItemView *newTagView = [self.mViewTag addNewTag:strTag point:ptPos];
                
                if (!newTagView) {
                    break;
                }
                
                [newTagView.mButTag setHidden:NO];

                // add to current tag list
                HashTagData *tagData = [[HashTagData alloc] init];
                tagData.mptPos = [newTagView getCenterPos];
                tagData.mstrTag = strTag;
                tagData.mviewTag = newTagView;
                [self.mViewTag.maryTag addObject:tagData];
                
                break;
            }
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"您确定要删除这个标签吗？"
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"删除",nil];
        [alert show];
        
        mbutTagSelected = (UIButton *)gesture.view;
    }
}

#pragma mark - Alert Delegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        for (UIView *subview in [self.mTagScrollView subviews]) {
            if ([subview isKindOfClass:[TagItemView class]]) {
                TagItemView *tagView = (TagItemView*)subview;
                if ([tagView.mButTag isEqual:mbutTagSelected]) {
                    NSInteger nTagIndex = [mbutTagSelected tag];
                    NSString *strTag = [maryMyTag objectAtIndex:nTagIndex];
                    
                    [maryMyTag removeObject:strTag];
                    
                    [self reloadTagScroll];
                    [self saveTagToUserDefault];
                    
                    break;
                }
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    if ([touch.view isKindOfClass:[ClassThatYouWantTouchesBlocked class]])
//    {
//        return NO;
//    }
//    else
//    {
        return NO;
//    }
}

#pragma mark - Text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
}



@end
