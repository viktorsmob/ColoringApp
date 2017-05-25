//
//  PainToolDialog.h
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 08/12/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaintToolDialog;
@protocol PaintToolDialogDelegate <NSObject>

@required
- (void) PaintToolDialogOk:(int) drawingToolTag brushSize:(CGFloat) brushSize isZoomOn:(BOOL) isZoomOn;
- (void) PaintToolDialogCanceled;

@end


@interface PaintToolDialog : UIViewController
{
@public int drawingToolTempTag;
@public CGFloat tempBrushSize;
@public bool tempIsZoomOn;
@public double stepperPrevValue;
@private float btnSelectedBorderWidth;
}

@property (nonatomic, weak) id <PaintToolDialogDelegate> delegate;

// Drawing settings
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_fill;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_pencil;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_dotStroke;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_eraser;
// Line 2 tools
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_b1;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_b2;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_b3;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_zoom;
// Brush size
@property (weak, nonatomic) IBOutlet UILabel *lbl_dSettings_brush_size;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_size1;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_size2;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_size3;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_size4;
@property (weak, nonatomic) IBOutlet UIButton *btn_dSettings_size5;
@property (weak, nonatomic) IBOutlet UISlider *slider_brush_size;

@end
