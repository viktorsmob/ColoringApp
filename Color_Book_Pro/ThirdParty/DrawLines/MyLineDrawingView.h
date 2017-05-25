//
//  MyLineDrawingView.h
//  DrawLines
//
//  Created by Reetu Raj on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

// Smooth Line
static const CGFloat kPointMinDistance = 5.0f;
static const CGFloat kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;

@interface MyLineDrawingView : UIView<MBProgressHUDDelegate> {
    
@public NSMutableArray *pathArray;
    NSMutableArray *bufferArray;
    UIBezierPath *myPath;
@public UIImage *realImage;
@public UIImageView* currentImageView;
@public UIColor *currentColor;
@public BOOL isActive;
@public CGFloat brushSize;
@public NSInteger paintTool;
@public float defaultAlpha;
@public BOOL dontDrawView;
@public int touchesMovedCount;
@private MBProgressHUD *progress;
    // Eraser
@private UIColor *eraserColor;
    
    // Smooth Line
@private CGMutablePathRef pathSmoothLine;
}

@property(nonatomic,assign) NSInteger undoSteps;
- (UIImage*)floodFillAtPoint:(CGPoint)fillCenter withImage:(UIImage*) image byColor:(UIColor*) fillColor;
-(void)undoButtonClicked;
-(void)redoButtonClicked;
-(UIImage*)mergeLinesOnImage :(UIImage *) sourceImage;
- (id)initWithFrame:(CGRect)frame imageForEraser:(UIImage*) image;
//MODIFIED BY Yaroslav Petrenko 1/28/16
- (void)initPathAndBufferArray;
//
-(void)toucheStart:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)toucheMoved:(NSSet *)touches withEvent:(UIEvent *)event;

// Smooth Line
@property (nonatomic,assign) CGPoint currentPoint;
@property (nonatomic,assign) CGPoint previousPoint;
@property (nonatomic,assign) CGPoint previousPreviousPoint;

@end
