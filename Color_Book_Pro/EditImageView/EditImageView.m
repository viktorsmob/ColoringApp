//
//  EditImageView.m
//  Color_Book_Pro
//
//  Created by TPS Technology on 21/04/15.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

@import GoogleMobileAds;
#import "EditImageView.h"
#import "UIViewController+MJPopupViewController.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Gloabals.h"
#import <CoreGraphics/CoreGraphics.h>
#import "FloodFill.h"
#import "LineDrawingUndoRedoCacha.h"
#import "DrawingScrillView.h"
#import "iToast.h"
#import "AboutViewController.h"
#import "AboutMenuUIViewController.h"
#import "MainMenuUIViewController.h"
#import "PaintToolDialog.h"
#import "MBProgressHUD.h"

@implementation EditImageView
@synthesize lblTitle,imgFinalImage;
@synthesize flag,documentationInteractionController;
@synthesize newcolor;
@synthesize help_overlay;
@synthesize bannerView;


float total=255.0f;
int recentColorLimit = 5;
//bool tflag=true;

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tempIsZoomOn = TRUE;
    self.flag=true;
    self.newcolor = [UIColor redColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    if (IS_IPAD)
    {
        self.lblTitle.font=[UIFont fontWithName:@"Istok-Bold" size:45];
    }
    else
    {
        self.lblTitle.font=[UIFont fontWithName:@"Istok-Bold" size:35];
    }
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        bannerView.adSize = kGADAdSizeLeaderboard;
        _constBannerHeight.constant = 90;
        
    }
    else
    {
        bannerView.adSize = kGADAdSizeSmartBannerPortrait;
        _constBannerHeight.constant = 50;
        
    }

    lastTouchTime = [[NSDate date] init];
    
    
    NSMutableArray *VCs = [self.navigationController.viewControllers mutableCopy];
    NSLog(@"vviieewwss: %lu",(unsigned long)[VCs count]);
    while (1 < [VCs count] - 1) {
        
        NSLog(@"removeView");
        [VCs removeObjectAtIndex:1];
        self.navigationController.viewControllers = VCs;
        
    }
    
    [self performSelector:@selector(callAfterSomeTime) withObject:nil afterDelay:0.5f];
}

-(void) callAfterSomeTime
{
    [self initDrawing];
    
    [self loadRecentUsedColors];
    self.newcolor = [_recentUsedColors objectAtIndex:0];
    [self initBottomBarRecentColors];
    
    [self admobBanner];
}

-(void) initDrawing
{
    CGFloat top = 0;//self.center_row.frame.origin.y;
    CGFloat width = self.center_row.frame.size.width;
    CGFloat height = self.center_row.frame.size.height;// - 10;
    CGRect rect = CGRectMake(0, top, width, height);
    
    // remove subViews
    [[self.center_row subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    scrollToZoom = nil;
    scrollContainer = nil;
    ivFinalImage = nil;

    scrollToZoom = [[DrawingScrillView alloc] initWithFrame:rect];
    scrollContainer = [[UIView alloc] initWithFrame:rect];
    ivFinalImage = [[UIImageView alloc] initWithFrame:rect];
    
    [scrollContainer addSubview:ivFinalImage];
    [self.center_row addSubview:scrollToZoom];
    [scrollToZoom addSubview:scrollContainer];
    
    scrollContainer.tag = 50;
    
    UIImage *fimage=[self imageWithImage:self.imgFinalImage convertToSize:CGSizeMake(width, height)];
    ivFinalImage.image=fimage;
    self.imgFinalImage=fimage;
    
  
    // DrawLine
    if(!drawScreen)
    {
        [self initDrawScreen:rect];
    }
    else
    {
        MyLineDrawingView *tempDrawScreen = drawScreen;
        
        [self initDrawScreen:rect];
        //drawScreen->isActive = true;
        drawScreen->currentColor = tempDrawScreen->currentColor;
        drawScreen->paintTool = tempDrawScreen->paintTool;//FILL;
        drawScreen.tag = self.btnCurrentTool.tag;
        drawScreen->realImage = self.imgFinalImage;
        drawScreen->currentImageView = ivFinalImage;
        if(self.btnCurrentTool.tag == FILL)
        {
            drawScreen->isActive = false;//tempDrawScreen->isActive;
        }
        else
        {
            drawScreen->isActive = true;
        }
        drawScreen->brushSize = tempDrawScreen->brushSize;
        
    }
    [self updateDrawingSettings:self.btnCurrentTool.tag];
    
    
    
    
    
    transparentImgView = [[UIImageView alloc] initWithFrame:rect];
    transparentImgView.image = [UIImage imageNamed:
                                 [NSString stringWithFormat:@"T_%@", imgFinalImageName]
                                ];
    [scrollContainer addSubview:transparentImgView];
    
    
    scrollToZoom->isZoomOn = tempIsZoomOn;
    scrollToZoom.contentSize = ivFinalImage.image.size;
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = scrollToZoom.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / scrollToZoom.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / scrollToZoom.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    
    [scrollToZoom setScrollEnabled:NO];
    scrollToZoom.minimumZoomScale = minScale;
    scrollToZoom.maximumZoomScale = 4.0f;
    scrollToZoom.zoomScale = minScale;
    scrollToZoom.delegate= self;
    //scrollToZoom.userInteractionEnabled = false;
    
}

-(void)initDrawScreen:(CGRect)rect{
    drawScreen = [[MyLineDrawingView alloc] initWithFrame:rect  imageForEraser:self.imgFinalImage];
    [drawScreen setBackgroundColor:[UIColor clearColor]];
    drawScreen->currentColor = self.newcolor;
    drawScreen->paintTool = FILL;//self.btnCurrentTool.tag;//FILL;
    drawScreen.tag = 3;
    drawScreen->realImage = self.imgFinalImage;
    drawScreen->currentImageView = ivFinalImage;
    [scrollContainer addSubview:drawScreen];
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    
    // unable to undo when user just tap
    if(drawScreen->touchesMovedCount > 0)
    {
        drawScreen->dontDrawView = true;
        [drawScreen setNeedsDisplay];
    }
    
    if(scrollToZoom -> isZoomOn)
    {
        return scrollContainer;
    }
    else
    {
        
        return nil;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) admobBanner
{
    bannerView.adUnitID = ADMOB_BANNER_ID;
    bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    //if (KADMOB_TESTING)
    //   request.testDevices =@[KADMOB_TESTING_DEVICE_ID];
    [bannerView loadRequest:request];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Drawing Settings overlay

-(void)updateDrawingSettings :(NSInteger)tag
{
    if (tag==FILL) {
        
        drawScreen->isActive = false;
        self.btnCurrentTool.tag = FILL;
        //self.btnCurrentTool.imageView.image  = [UIImage imageNamed:@"ds_btn_fill.png"];
    [self.btnCurrentTool setBackgroundImage:[UIImage imageNamed:@"ds_btn_fill.png"] forState:UIControlStateNormal];
    }
    else if (tag==PENCIL) {
        
        drawScreen->isActive = true;
        self.btnCurrentTool.tag = PENCIL;
        //self.btnCurrentTool.imageView.image  = [UIImage imageNamed:@"ds_pencil.png"];
        [self.btnCurrentTool setBackgroundImage:[UIImage imageNamed:@"ds_pencil.png"] forState:UIControlStateNormal];
    }
    else if (tag==DotStroke) {
        
        drawScreen->isActive = true;
        self.btnCurrentTool.tag = DotStroke;
        //self.btnCurrentTool.imageView.image  = [UIImage imageNamed:@"ds_brush.png"];
        [self.btnCurrentTool setBackgroundImage:[UIImage imageNamed:@"ds_brush.png"] forState:UIControlStateNormal];
    }
    else if (tag==Eraser) {
        
        drawScreen->isActive = true;
        self.btnCurrentTool.tag = Eraser;
        //self.btnCurrentTool.imageView.image  = [UIImage imageNamed:@"ds_eraser.png"];
        [self.btnCurrentTool setBackgroundImage:[UIImage imageNamed:@"ds_eraser.png"] forState:UIControlStateNormal];
        
        [self initBottomBarRecentColors];
    }
    
    else if (tag==B1) {
        
        drawScreen->isActive = true;
        self.btnCurrentTool.tag = B1;
        //self.btnCurrentTool.imageView.image  = [UIImage imageNamed:@"ds_am.png"];
        [self.btnCurrentTool setBackgroundImage:[UIImage imageNamed:@"ds_am.png"] forState:UIControlStateNormal];
    }
    else if (tag==B2) {
        
        drawScreen->isActive = true;
        self.btnCurrentTool.tag = B2;
        //self.btnCurrentTool.imageView.image  = [UIImage imageNamed:@"ds_am2.png"];
        [self.btnCurrentTool setBackgroundImage:[UIImage imageNamed:@"ds_am2.png"] forState:UIControlStateNormal];
    }
    else if (tag==B3) {
        
        drawScreen->isActive = true;
        self.btnCurrentTool.tag = B3;
        //self.btnCurrentTool.imageView.image  = [UIImage imageNamed:@"ds_wm.png"];
        [self.btnCurrentTool setBackgroundImage:[UIImage imageNamed:@"ds_wm.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)btnSetTap:(UIButton *)sender
{
    UIButton *btnSelect=(UIButton *)sender;
    
    if (btnSelect.tag==1) {
        [self saveImage:sender];
    }
    else if (btnSelect.tag==2)
    {
        [self btnShareClick:btnSelect];
    }
    else if (btnSelect.tag==3)
    {
        [self btnPickColorClick:btnSelect];
    }
    else if (btnSelect.tag==4)
    {
        // reset image
        [ivFinalImage setImage:self.imgFinalImage];
    }
    else if (btnSelect.tag==5)
    {
        [self btnTopHelpClick:btnSelect];
    }
    else if (btnSelect.tag==20)
    {
        //undo
        [drawScreen undoButtonClicked];
        // end undo
    }
    else if (btnSelect.tag==21)
    {
        //redo
        [drawScreen redoButtonClicked];
        // end redo
    }
    else if (btnSelect.tag==FILL
             || btnSelect.tag==PENCIL
             || btnSelect.tag==DotStroke
             || btnSelect.tag==Eraser
             || btnSelect.tag==B1
             || btnSelect.tag==B2
             || btnSelect.tag==B3
             || btnSelect.tag==Zoom
             )
    {

        PaintToolDialog *controller = [[PaintToolDialog alloc] init];
        controller.delegate = self;
        controller->tempIsZoomOn = scrollToZoom->isZoomOn;
        controller->tempBrushSize = drawScreen->brushSize;
        controller->drawingToolTempTag = (int)self.btnCurrentTool.tag;
        
        [self presentPopupViewController:controller animationType:MJPopupViewAnimationFade];
    }
    else if(btnSelect.tag==10 /* Settings */)
    {
        AboutMenuUIViewController *controller = [[AboutMenuUIViewController alloc] init];
        controller.delegate = self;
        [self presentPopupViewController:controller animationType:MJPopupViewAnimationFade];
    }
    
    btnSelect.transform = CGAffineTransformMakeScale(2,2);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        btnSelect.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        
    }];
}

- (void) PaintToolDialogOk:(int) drawingToolTag brushSize:(CGFloat) brushSize isZoomOn:(BOOL) isZoomOn
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    [self updateDrawingSettings:drawingToolTag];
    drawScreen->brushSize = brushSize;
    drawScreen->paintTool = drawingToolTag;
    scrollToZoom->isZoomOn = isZoomOn;
}

- (void) PaintToolDialogCanceled
{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (void) AboutMenuClosedWithTag:(id) sender
{
    //2016-01-30 add ABOUT_SHARE by Billy
    UIButton *btnSender = (UIButton*)sender;

    if (btnSender.tag == ABOUT_SHARE) {
        NSLog(@"Share");
        
        [self btnShareClick:btnSender];
    }
    else if(btnSender.tag == ABOUT_LINK_RATE)
    {
        // link rate
        NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/calcfast/%@", APP_ID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
    }
    else if(btnSender.tag == ABOUT_LINK_APPS)
    {
        // link apps
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://google.com"]];
    }
    else if(btnSender.tag == ABOUT_LINK_3)
    {
        // link 3
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.example.com"]];
    }
    else if(btnSender.tag == ABOUT_ABOUT)
    {
         [self performSegueWithIdentifier:@"about_dialog" sender:self];
    }
    else if(btnSender.tag == ABOUT_CANCEL)
    {
        [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    }
    
}

-(IBAction)btnShareClick:(id)sender
{
    
    UIGraphicsBeginImageContextWithOptions(ivFinalImage.bounds.size, NO, 0);
    [ivFinalImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    //[self.imgFinalImage.layer renderInContext:UIGraphicsGetCurrentContext()];
    [transparentImgView.image drawInRect:(CGRect){CGPointZero, self.imgFinalImage.size}];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *finalImage = viewImage;

    
    //UIImage *finalImage = [ivFinalImage image];//[drawScreen mergeLinesOnImage:[ivFinalImage image]];
    UIButton *imagePickerButton = (UIButton*)sender;
    NSArray *Items   = [NSArray arrayWithObjects:
                        finalImage, nil];
    
    UIActivityViewController *ActivityView =
    [[UIActivityViewController alloc]
     initWithActivityItems:Items applicationActivities:nil];
    // Exclude following activities.
    NSArray *excludedActivities = @[
                                    UIActivityTypePrint,
                                    UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAirDrop
                                    ];
    ActivityView.excludedActivityTypes = excludedActivities;
    ActivityView.popoverPresentationController.sourceView = imagePickerButton;
    
    [self presentViewController:ActivityView animated:YES completion:nil];
}

-(void)saveAlert
{
    UIAlertController *alert =  [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"Image Saved Successfully"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:1.5];
    
}

-(void)dismissAlert:(UIAlertController *)_alert
{
    [_alert dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)saveImage:(id)sender
{
        UIGraphicsBeginImageContextWithOptions(ivFinalImage.bounds.size, NO, 0);
        [ivFinalImage.layer renderInContext:UIGraphicsGetCurrentContext()];
        //[self.imgFinalImage.layer renderInContext:UIGraphicsGetCurrentContext()];
     [transparentImgView.image drawInRect:(CGRect){CGPointZero, self.imgFinalImage.size}];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImage *finalImage = viewImage;
    
    
    //UIImage *finalImage = [ivFinalImage image];//[drawScreen mergeLinesOnImage:[ivFinalImage image]];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"img_%f-%@-_img.png", timeInterval, imgFinalImageName]];
    NSLog(@"%@",fullPath);
    
    NSData* data = UIImagePNGRepresentation(finalImage);
    BOOL isWritten = [data writeToFile:fullPath atomically:YES];
    if(isWritten)
    {
        [self saveAlert];
    }
    else
    {
        NSLog(@"Error failed to save image.");
    }
    
}


-(IBAction)btnBackClick:(id)sender
{
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    MainMenuUIViewController *controller = [[MainMenuUIViewController alloc] init];
    controller.delegate = self;
    [self presentPopupViewController:controller animationType:MJPopupViewAnimationFade];
}

- (void) MainMenuClosedWithTag:(int) tag
{
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    if (tag == MAIN_MENU_CANCEL)
    {
        return;
    }
    else if(tag == MAIN_MENU_RESTART_IMAGE)
    {
        [ivFinalImage setImage:self.imgFinalImage];
        
    }
    else if(tag == MAIN_MENU_NEW_IMAGE)
    {
        [self performSegueWithIdentifier:@"img_cat" sender:self];
    }
    else if(tag == MAIN_MENU_RANDOM_IMAGE)
    {
        // Get random category index
        NSArray *arrCategories = KARR_CATEGORIES;
        int min = 0;
        NSUInteger max = [arrCategories count] - 1;
        int randNum = rand() % (max - min) + min;
        
        
        // Get all pictures from above selected category
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png' AND self BEGINSWITH[c] %@",
                             [arrCategories objectAtIndex:randNum]
                             ];
        NSArray *imgNames = [dirContents filteredArrayUsingPredicate:fltr];
        NSMutableArray *marrImages=[[NSMutableArray alloc]init];
        marrImages =[NSMutableArray arrayWithArray:imgNames];
        
        
        // Assign random picture path to next screen
        min = 0;
        max = [marrImages count] - 1;
        randNum = rand() % (max - min) + min;
        imgFinalImage=[UIImage imageNamed:[marrImages objectAtIndex:randNum]];
        imgFinalImageName = [marrImages objectAtIndex:randNum];
        
        
        
        [ivFinalImage setImage:self.imgFinalImage];
        [self initDrawing];
    }
    else if(tag == MAIN_MENU_MY_GALLERY)
    {
        [self performSegueWithIdentifier:@"my_gallery" sender:self];
    }
    else if(tag == MAIN_MENU_EXIT)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    // MODIFIED BY Yaroslav Petrenko 1/28/16
    
    [drawScreen initPathAndBufferArray];
    drawScreen->realImage = self.imgFinalImage;
    //
}

- (IBAction)btnTopHelpClick:(id)sender {
    [self.view bringSubviewToFront:help_overlay];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [help_overlay.layer addAnimation:animation forKey:nil];
    
    help_overlay.hidden = false;
}
- (IBAction)helpOverlayClick:(id)sender {
   
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [help_overlay.layer addAnimation:animation forKey:nil];
    
    help_overlay.hidden = true;
    
}

-(IBAction)btnPickColorClick:(id)sender
{
    NEOColorPickerViewController *controller = [[NEOColorPickerViewController alloc] init];
    controller.delegate = self;
    controller.selectedColor = self.newcolor;
    controller.title = @"Color Palette";
    [self presentPopupViewController:controller animationType:MJPopupViewAnimationFade];
}
- (void)colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color {
    
    [self selectedColorByColorPickerView:color];
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
   
}
-(void) colorPickerViewDismissedByOutSideClick:(UIColor *)color
{
    [self selectedColorByColorPickerView:color];
}
-(void) selectedColorByColorPickerView:(UIColor *)color
{
    self.newcolor = color;
    //drawScreen->curentColor = self.newcolor;
    
    [_recentUsedColors removeObject:color];
    if(_recentUsedColors.count == recentColorLimit)
    {
        [_recentUsedColors removeObjectAtIndex:[_recentUsedColors count]-1];
    }
    [_recentUsedColors insertObject:color atIndex:0];
    [self saveRecentUsedColors];
    [self initBottomBarRecentColors];
}

- (void)colorPickerViewControllerDidCancel:(NEOColorPickerBaseViewController *)controller {
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [drawScreen toucheStart:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [drawScreen toucheMoved:touches withEvent:event];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
   
    if([self.btnCurrentTool tag] == FILL)
    {
        if ([touches count] == 1)
        {
            if ([[touch view] tag]==50)// scrollContainer = 50
            {
                /*
                NSDate *currentTouchTime = [[NSDate date] init];
                CGFloat diff = [currentTouchTime timeIntervalSinceDate:lastTouchTime];
                NSLog(@"%f ,,%d",diff,[[touch view] tag]);
                if(diff < 1.0f)
                {
                    lastTouchTime = [[NSDate date] init];
                    NSLog(@"waittt");
                    return;
                }
                lastTouchTime = [[NSDate date] init];
                 NSLog(@"do it");
                */
                
                scrollContainer.userInteractionEnabled = false;
                
                if(progress == nil)
                {
                    progress = [[MBProgressHUD alloc] initWithView:self.view];
                }
                [self.view addSubview:progress];
                progress.dimBackground = YES;
                progress.delegate = self;
                [progress show:YES];
                
                CGPoint tpoint = [[[event allTouches] anyObject] locationInView:ivFinalImage];

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    UIImage *filledImage = [drawScreen floodFillAtPoint:tpoint withImage:ivFinalImage.image byColor:self.newcolor];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        ivFinalImage.image = filledImage;
                        
                        LineDrawingUndoRedoCacha *obj = [[LineDrawingUndoRedoCacha  alloc] init];
                        obj.color = self.newcolor;
                        obj->tpoint = tpoint;
                        obj->paintTool = FILL;
                        [drawScreen->pathArray addObject:obj];
                        
                        //[progress hide:YES];
                        [self performSelector:@selector(endFill) withObject:nil afterDelay:0.1f];
                    });
                });
                
            }
           
        }
    }
    
}

-(void)endFill
{
    scrollContainer.userInteractionEnabled = true;
[progress hide:YES];
}

-(void)loadRecentUsedColors
{
    NSFileManager *fs = [NSFileManager defaultManager];
    NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"recentColors.data"];
    if ([fs isReadableFileAtPath:filename]) {
        _recentUsedColors = [[NSMutableOrderedSet alloc] initWithOrderedSet:[NSKeyedUnarchiver unarchiveObjectWithFile:filename]];
    } else {
        _recentUsedColors = [[NSMutableOrderedSet alloc] init];
        
        for (int i = 0; i < recentColorLimit; i++) {
            UIColor *color = [UIColor colorWithHue:i / (float)recentColorLimit saturation:1.0 brightness:1.0 alpha:1.0];
            [_recentUsedColors addObject:color];
        }
        [self saveRecentUsedColors];
    }
    
}
-(void)saveRecentUsedColors
{    
    NSString *filename = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"recentColors.data"];
    
    [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_recentUsedColors];
    [data writeToFile:filename atomically:YES];
}

-(void)initBottomBarRecentColors
{
    // remove subViews
    [[self.recentColorView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // remove subLayers
    [self.recentColorView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat parentWidth = self.recentColorView.frame.size.width;
    CGFloat parentHeight = self.recentColorView.frame.size.height - 10;
    int frameWidth = ((int)parentWidth / (int)recentColorLimit);
    CGRect rect;
    
    CGFloat offset = (parentWidth - parentHeight * recentColorLimit) / (recentColorLimit - 1);
    
    for (int i = 0; i < recentColorLimit && i < _recentUsedColors.count; i++) {
        int column = i;
        if(parentWidth > 500)
        {
            rect = CGRectMake((column * frameWidth) + parentHeight, 0, parentHeight, parentHeight);
        }
        else
        {
            rect = CGRectMake((column * parentHeight) + column * offset, 0, parentHeight, parentHeight);
        }
        
        CALayer *layer = [CALayer layer];
        layer.cornerRadius = parentHeight/2;
        UIColor *color = [_recentUsedColors objectAtIndex:i];
        layer.backgroundColor = color.CGColor;
        //[layer setMasksToBounds:YES];
        layer.frame = rect;
        //[layer setBounds:CGRectMake(0.0f, 0.0f, radius *2 radius *2)];
        
        [self setupShadow:layer];
        [self.recentColorView.layer addSublayer:layer];
        
        if([self.newcolor isEqual:color])
        {
            if (self.btnCurrentTool.tag != Eraser) {
                int min = 1;
                int max = 6;
                int randNum = rand() % (max - min) + min;
                NSString *imgName = [NSString stringWithFormat:@"ds_face_0%i.png", randNum];
                
                UIImageView *imgView = [[UIImageView alloc] init];
                imgView.frame = rect;
                imgView.image = [UIImage imageNamed:imgName];
                [self.recentColorView addSubview: imgView];
            }
            
            if(drawScreen!=nil)
            {
                drawScreen->currentColor = self.newcolor;
            }
        }
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomRecentColorTaped:)];
    [self.recentColorView addGestureRecognizer:recognizer];
}
- (void) setupShadow:(CALayer *)layer {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    layer.shadowOffset = CGSizeMake(0, 2);
    CGRect rect = layer.frame;
    rect.origin = CGPointZero;
    layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:layer.cornerRadius].CGPath;
}

- (void) bottomRecentColorTaped:(UITapGestureRecognizer *)recognizer {
    
    
    CGFloat parentWidth = self.recentColorView.frame.size.width;
    int frameWidth = (int)parentWidth / (int)recentColorLimit;
    
    CGPoint point = [recognizer locationInView:self.recentColorView];
    int row = (int)((point.y) / frameWidth);
    int column = (int)((point.x - 8) / frameWidth);
    int index = row * 1 + column;
    
    if (index < _recentUsedColors.count) {
        
        if(self.btnCurrentTool.tag == Eraser){
            
            drawScreen->paintTool = PENCIL;
            [self updateDrawingSettings:PENCIL];

        }
        
        self.newcolor = [_recentUsedColors objectAtIndex:index];
        //drawScreen->curentColor = self.newcolor;
        [self initBottomBarRecentColors];
    }
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     /*
 if ([[segue identifier] isEqualToString:@"about_dialog"])
 {
     
 }
     */
     
     UIViewController *newVC = segue.destinationViewController;
     [EditImageView setPresentationStyleForSelfController:self presentingController:newVC];
     
 }

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}
 

@end
