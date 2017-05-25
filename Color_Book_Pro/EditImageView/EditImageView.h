//
//  EditImageView.h
//  Color_Book_Pro
//
//  Created by TPS Technology on 21/04/15.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMobileAds;
#import "Gloabals.h"
#import "NEOColorPickerViewController.h"
#import "MyLineDrawingView.h"
#import "DrawingScrillView.h"
#import "AboutMenuUIViewController.h"
#import "MainMenuUIViewController.h"
#import "PaintToolDialog.h"
#import "MBProgressHUD.h"

@interface EditImageView : UIViewController<UIDocumentInteractionControllerDelegate, NEOColorPickerViewControllerDelegate, UIScrollViewDelegate,AboutMenuUIViewControllerDelegate,MainMenuUIViewControllerDelegate,PaintToolDialogDelegate,MBProgressHUDDelegate>
{
@private MBProgressHUD *progress;
    
    @public NSString *imgFinalImageName;
}

@property (assign) PaintTool paintTool;
@property(nonatomic,retain)IBOutlet UIImage *imgFinalImage;
@property(nonatomic,retain) UIDocumentInteractionController *documentationInteractionController;
@property(readwrite,assign)BOOL flag;
@property(nonatomic,retain)IBOutlet UILabel *lblTitle;
@property (strong, nonatomic)  UIColor *newcolor;
@property (weak, nonatomic) IBOutlet UIButton *help_overlay;

@property (weak, nonatomic) IBOutlet UIButton *btnCurrentTool;
@property (weak, nonatomic) IBOutlet UIView *recentColorView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIImageView *topBar;
@property (weak, nonatomic) IBOutlet UIView *center_row;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UIButton *delIt;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constBannerHeight;

@end

//NoButtonAlertView *alert;
//UIAlertController * alert;
NSMutableOrderedSet *_recentUsedColors;
MyLineDrawingView *drawScreen;
int drawingToolTempTag;
CGFloat tempBrushSize;
bool tempIsZoomOn;
double stepperPrevValue;
UIScrollView *myScrollView;

DrawingScrillView *scrollToZoom;
UIImageView *ivFinalImage;
UIImageView *transparentImgView;
UIView *scrollContainer;

// Handle multitouch problem during fill
NSDate *lastTouchTime;
UIView *tempView;
