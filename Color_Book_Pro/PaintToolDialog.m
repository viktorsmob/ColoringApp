//
//  PainToolDialog.m
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 08/12/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import "PaintToolDialog.h"
#import "UIViewController+MJPopupViewController.h"
#import "Gloabals.h"

@interface PaintToolDialog ()

@end

@implementation PaintToolDialog

@synthesize btn_dSettings_fill,btn_dSettings_pencil,btn_dSettings_dotStroke,btn_dSettings_eraser,
btn_dSettings_b1,btn_dSettings_b2,btn_dSettings_b3,btn_dSettings_zoom,
lbl_dSettings_brush_size,btn_dSettings_size1,btn_dSettings_size2,btn_dSettings_size3,btn_dSettings_size4,btn_dSettings_size5,
slider_brush_size;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    btnSelectedBorderWidth = 1.3f;
    [self drawingSettingOverlayToolBorderSettings:drawingToolTempTag];
    [self drawingSettingOverlayBrushSizeSettings:tempBrushSize];
    slider_brush_size.value = tempBrushSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okBtnClicked:(id)sender {
     [self.delegate PaintToolDialogOk:(int)drawingToolTempTag brushSize:tempBrushSize isZoomOn:tempIsZoomOn];
}

- (IBAction)cancelBtnClicked:(id)sender {
    [self.delegate PaintToolDialogCanceled];
}

- (IBAction)drawingSettingsChangeTool_click:(UIButton *)sender {
    if (sender.tag != Zoom)
    {
        drawingToolTempTag = (int)sender.tag;
    }
    else
    {
        tempIsZoomOn = !tempIsZoomOn;
    }
    [self drawingSettingOverlayToolBorderSettings:sender.tag];
}
- (IBAction)drawingSettingsDefaultBrushSize_click:(UIButton *)sender {
    if(sender.tag == 1)
    {
        tempBrushSize = 1;
    }
    else if(sender.tag == 2)
    {
        tempBrushSize = 10;
    }
    else if(sender.tag == 3)
    {
        tempBrushSize = 20;
    }
    else if(sender.tag == 4)
    {
        tempBrushSize = 30;
    }
    else if(sender.tag == 5)
    {
        tempBrushSize = 40;
    }
    
    slider_brush_size.value = tempBrushSize;
    [self drawingSettingOverlayBrushSizeSettings:tempBrushSize];
}
- (IBAction)drawingSettingsSlider_valueChanged:(id)sender {
    tempBrushSize = slider_brush_size.value;
    [self drawingSettingOverlayBrushSizeSettings:tempBrushSize];
}

-(void)drawingSettingOverlayToolBorderSettings :(NSInteger) currentToolTag
{
    // Remove border previous selected tool and assign to selected tool
    if (currentToolTag==FILL)
    {
        [self setBoarderOnBtn:btn_dSettings_fill borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        [self setBoarderOnBtn:btn_dSettings_fill borderWidth:0.0];
    }
    
    if (currentToolTag==PENCIL)
    {
        [self setBoarderOnBtn:btn_dSettings_pencil borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        [self setBoarderOnBtn:btn_dSettings_pencil borderWidth:0.0];
    }
    
    if (currentToolTag==DotStroke)
    {
        [self setBoarderOnBtn:btn_dSettings_dotStroke borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        [self setBoarderOnBtn:btn_dSettings_dotStroke borderWidth:0.0];
    }
    
    if (currentToolTag==Eraser)
    {
        [self setBoarderOnBtn:btn_dSettings_eraser borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        [self setBoarderOnBtn:btn_dSettings_eraser borderWidth:0.0];
    }
    
    if (currentToolTag==B1)
    {
        [self setBoarderOnBtn:btn_dSettings_b1 borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        [self setBoarderOnBtn:btn_dSettings_b1 borderWidth:0.0];
    }
    
    if (currentToolTag==B2)
    {
        [self setBoarderOnBtn:btn_dSettings_b2 borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        [self setBoarderOnBtn:btn_dSettings_b2 borderWidth:0.0];
    }
    
    if (currentToolTag==B3)
    {
        [self setBoarderOnBtn:btn_dSettings_b3 borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        [self setBoarderOnBtn:btn_dSettings_b3 borderWidth:0.0];
    }
    
    if (currentToolTag==Zoom)
    {
        if(tempIsZoomOn)
        {
            [self.btn_dSettings_zoom setBackgroundImage:[UIImage imageNamed:@"ds_zoom.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.btn_dSettings_zoom setBackgroundImage:[UIImage imageNamed:@"ds_zoom_off.png"] forState:UIControlStateNormal];
        }
        [self setBoarderOnBtn:btn_dSettings_zoom borderWidth:btnSelectedBorderWidth];
    }
    else
    {
        if(tempIsZoomOn)
        {
            [self.btn_dSettings_zoom setBackgroundImage:[UIImage imageNamed:@"ds_zoom.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.btn_dSettings_zoom setBackgroundImage:[UIImage imageNamed:@"ds_zoom_off.png"] forState:UIControlStateNormal];
        }
        [self setBoarderOnBtn:btn_dSettings_zoom borderWidth:0.0];
    }
}
-(void)drawingSettingOverlayBrushSizeSettings :(CGFloat) brushSize
{
    // brush icons
    lbl_dSettings_brush_size.text = [NSString stringWithFormat:@"%.02f", brushSize];
    
    [btn_dSettings_size1 setBackgroundImage:[UIImage imageNamed:@"ds_unselect_2.png"] forState:UIControlStateNormal];
    [btn_dSettings_size2 setBackgroundImage:[UIImage imageNamed:@"ds_unselect_5.png"] forState:UIControlStateNormal];
    [btn_dSettings_size3 setBackgroundImage:[UIImage imageNamed:@"ds_unselect_10.png"] forState:UIControlStateNormal];
    [btn_dSettings_size4 setBackgroundImage:[UIImage imageNamed:@"ds_unselect_20.png"] forState:UIControlStateNormal];
    [btn_dSettings_size5 setBackgroundImage:[UIImage imageNamed:@"ds_unselect_30.png"] forState:UIControlStateNormal];
    
    if(brushSize == 1)
    {
        [btn_dSettings_size1 setBackgroundImage:[UIImage imageNamed:@"ds_select_2.png"] forState:UIControlStateNormal];
    }
    else if(brushSize== 10)
    {
        [btn_dSettings_size2 setBackgroundImage:[UIImage imageNamed:@"ds_select_5.png"] forState:UIControlStateNormal];
    }
    else if(brushSize == 20)
    {
        [btn_dSettings_size3 setBackgroundImage:[UIImage imageNamed:@"ds_select_10.png"] forState:UIControlStateNormal];
    }
    else if(brushSize == 30)
    {
        [btn_dSettings_size4 setBackgroundImage:[UIImage imageNamed:@"ds_select_20.png"] forState:UIControlStateNormal];
    }
    else if(brushSize == 40)
    {
        [btn_dSettings_size5 setBackgroundImage:[UIImage imageNamed:@"ds_select_30.png"] forState:UIControlStateNormal];
    }
    
}
-(void)setBoarderOnBtn :(UIButton*)btn borderWidth:(float)width
{
    if (IS_IPAD)
    {
        btn.layer.cornerRadius = 10.0;
    }
    else
    {
        btn.layer.cornerRadius = 10.0;
    }

    btn.layer.borderColor = [[UIColor redColor] CGColor]; 
    btn.layer.borderWidth = width;
    btn.layer.masksToBounds = YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
