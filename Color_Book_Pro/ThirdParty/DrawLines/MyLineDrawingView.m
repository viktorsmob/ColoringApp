//
//  MyLineDrawingView.m
//  DrawLines
//
//  Created by Reetu Raj on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyLineDrawingView.h"
#import "LineDrawingUndoRedoCacha.h"
#import "Gloabals.h"
#import "FloodFill.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@implementation MyLineDrawingView
@synthesize undoSteps;
/*
 - (id)init
 {
 self = [super init];
 if (self) {
 // Initialization code
 [self initThisView];
 }
 return  self;
 }*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initThisView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imageForEraser:(UIImage*) image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        eraserColor = [[UIColor alloc]initWithPatternImage:image];
        [self initThisView];
    }
    return self;
}

-(void) initThisView
{
    pathArray=[[NSMutableArray alloc]init];
    bufferArray=[[NSMutableArray alloc]init];
    
    if(brushSize == 0.0f)
    {
        brushSize = 5;
    }
    paintTool = PENCIL;
    defaultAlpha = 0.9;
}

// MODIFIED BY Yaroslav Petrenko 1/28/16
- (void) initPathAndBufferArray
{
    [pathArray removeAllObjects];
    [bufferArray removeAllObjects];
}
//

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [progress removeFromSuperview];
    progress = nil;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(dontDrawView)
    {
        dontDrawView = false;
        return;
    }
    //for (LineDrawingUndoRedoCacha *obj in pathArray)
    LineDrawingUndoRedoCacha *obj = [pathArray lastObject];
    if(obj == nil)
    {
        return;
    }
    {
        /*
         if(obj->paintTool == PENCIL)
         {
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextAddPath(context, obj.path.CGPath);
         CGContextSetLineCap(context, kCGLineCapRound);// diff types
         CGContextSetLineWidth(context, obj.path.lineWidth);
         CGContextSetStrokeColorWithColor(context, obj.color.CGColor);
         CGContextSetAlpha(context, defaultAlpha);
         CGContextStrokePath(context);
         }
         else*/ if(obj->paintTool == B2 || obj->paintTool == PENCIL)
         {
             CGContextRef context = UIGraphicsGetCurrentContext();
             CGContextAddPath(context, obj->pathSmoothLine);
             CGContextSetLineCap(context, kCGLineCapRound);
             CGContextSetLineWidth(context, obj->brushSize);
             CGContextSetStrokeColorWithColor(context, obj.color.CGColor);
             CGContextSetAlpha(context, defaultAlpha);
             CGContextStrokePath(context);
         }
         else if(obj->paintTool == B3)
         {
             [obj.color setStroke];
             [obj.path strokeWithBlendMode:kCGBlendModeNormal alpha:0.4];
         }
         else if(obj->paintTool == B1 || obj->paintTool == DotStroke)
         {
             [obj.color setStroke];
             [obj.path strokeWithBlendMode:kCGBlendModeNormal alpha:defaultAlpha];//1.0];
         }
         else if(obj->paintTool == Eraser)
         {
             /*
              [eraserColor setStroke];
              [obj.path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
              */
             
             CGContextRef context = UIGraphicsGetCurrentContext();
             CGContextAddPath(context, obj.path.CGPath);
             CGContextSetLineCap(context, kCGLineCapRound);// diff types
             CGContextSetLineWidth(context, obj.path.lineWidth);
             CGContextSetStrokeColorWithColor(context, eraserColor.CGColor);
             CGContextSetAlpha(context, 1.0);
             CGContextStrokePath(context);
             
         }
    }
    
}

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self toucheStart:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self toucheMoved:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!isActive)
    {
        return;
    }
    // unable to undo when user just tap
    if(touchesMovedCount <= 1)
    {
        [pathArray removeLastObject];
    }
    touchesMovedCount = 0;
    
    LineDrawingUndoRedoCacha *obj = [pathArray lastObject];
    if(obj != nil)
    {
        currentImageView.image = [self mergeLineOnImage:[currentImageView image] withLine:obj];
    }
    dontDrawView = true;
    [bufferArray removeAllObjects];
    [self setNeedsDisplay];
}

-(void)toucheStart:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!isActive)
    {
        return;
    }
    
    // unable to undo when user just tap
    if(touchesMovedCount > 0)
    {
        [pathArray removeLastObject];
    }
    touchesMovedCount = 0;
    [self startBrush:touches withEvent:event];
}
-(void)startBrush:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(paintTool == B1 || paintTool == B3 || paintTool == Eraser || paintTool == DotStroke)
    {
        myPath=[[UIBezierPath alloc]init];
        myPath.lineWidth=brushSize;
        
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [myPath moveToPoint:[mytouch locationInView:self]];
        // MODIFIED BY Yaroslav Petrenko 1/28/16
        // Force pathArray length limit : 5
        // And save image to realImage so far
        int pathArrayLength = (int)[pathArray count];
        if(pathArrayLength >= 5)
        {
            UIImage *tmpImg = realImage;
            LineDrawingUndoRedoCacha *tmpObj = [pathArray objectAtIndex:0];
            
            if(tmpObj -> paintTool == FILL)
            {
                tmpImg = [self floodFillAtPoint:tmpObj->tpoint withImage:tmpImg byColor:tmpObj.color];
            }
            else
            {
                tmpImg = [self mergeLineOnImage:tmpImg withLine:tmpObj];
            }
            realImage = tmpImg;
            [pathArray removeObjectAtIndex:0];
        }
        //////////////////////////////////////////
        LineDrawingUndoRedoCacha *obj = [[LineDrawingUndoRedoCacha  alloc] init];
        obj.color = currentColor;
        obj.path = myPath;
        obj->paintTool = paintTool;
        [pathArray addObject:obj];
    }
    else if(paintTool == B2 || paintTool == PENCIL)
    {
        UITouch *touch = [touches anyObject];
        
        // initializes our point records to current location
        self.previousPoint = [touch previousLocationInView:self];
        self.previousPreviousPoint = [touch previousLocationInView:self];
        self.currentPoint = [touch locationInView:self];
        
        pathSmoothLine = CGPathCreateMutable();
        myPath=[[UIBezierPath alloc]init];
        myPath.lineWidth=brushSize;
        myPath.CGPath = pathSmoothLine;
        // MODIFIED BY Yaroslav Petrenko 1/28/16
        // Force pathArray length limit : 5
        // And save image to realImage so far
        int pathArrayLength = (int)[pathArray count];
        if(pathArrayLength >= 5)
        {
            UIImage *tmpImg = realImage;
            LineDrawingUndoRedoCacha *tmpObj = [pathArray objectAtIndex:0];
            
            if(tmpObj -> paintTool == FILL)
            {
                tmpImg = [self floodFillAtPoint:tmpObj->tpoint withImage:tmpImg byColor:tmpObj.color];
            }
            else
            {
                tmpImg = [self mergeLineOnImage:tmpImg withLine:tmpObj];
            }
            realImage = tmpImg;
            [pathArray removeObjectAtIndex:0];
        }
        ////////////////////////////////////////
        LineDrawingUndoRedoCacha *obj = [[LineDrawingUndoRedoCacha  alloc] init];
        obj.color = currentColor;
        obj.path = myPath;
        obj->pathSmoothLine = pathSmoothLine;
        obj->paintTool = paintTool;
        obj->brushSize = brushSize;
        [pathArray addObject:obj];
        
        // call touchesMoved:withEvent:, to possibly draw on zero movement
        [self touchesMoved:touches withEvent:event];
    }
}
-(void)toucheMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!isActive)
    {
        return;
    }
    
    // unable to undo when user just tap
    touchesMovedCount++;
    
    if(paintTool == B1 || paintTool == Eraser || paintTool == B3)
    {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        [myPath addLineToPoint:[mytouch locationInView:self]];
        
        CGRect bounds = CGPathGetBoundingBox(myPath.CGPath);
        CGRect drawBox = CGRectInset(bounds, -2.0 * brushSize, -2.0 * brushSize);
        [self setNeedsDisplayInRect:drawBox];
        
        //[self setNeedsDisplay];
    }
    else if(paintTool == B2 || paintTool == PENCIL)
    {
        UITouch *touch = [touches anyObject];
        
        CGPoint point = [touch locationInView:self];
        
        // if the finger has moved less than the min dist ...
        CGFloat dx = point.x - self.currentPoint.x;
        CGFloat dy = point.y - self.currentPoint.y;
        
        if ((dx * dx + dy * dy) < kPointMinDistanceSquared) {
            // ... then ignore this movement
            return;
        }
        
        // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
        self.previousPreviousPoint = self.previousPoint;
        self.previousPoint = [touch previousLocationInView:self];
        self.currentPoint = [touch locationInView:self];
        
        CGPoint mid1 = midPoint(self.previousPoint, self.previousPreviousPoint);
        CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint);
        
        // to represent the finger movement, create a new path segment,
        // a quadratic bezier path from mid1 to mid2, using previous as a control point
        CGMutablePathRef subpath = CGPathCreateMutable();
        CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
        CGPathAddQuadCurveToPoint(subpath, NULL,
                                  self.previousPoint.x, self.previousPoint.y,
                                  mid2.x, mid2.y);
        
        // compute the rect containing the new segment plus padding for drawn line
        CGRect bounds = CGPathGetBoundingBox(subpath);
        CGRect drawBox = CGRectInset(bounds, -2.0 * brushSize, -2.0 * brushSize);
        
        // append the quad curve to the accumulated path so far.
        CGPathAddPath(pathSmoothLine, NULL, subpath);
        CGPathRelease(subpath);
        
        [self setNeedsDisplayInRect:drawBox];
        //[self setNeedsDisplay];
        
    }
    else if(paintTool == DotStroke)
    {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self];
        currentPoint.y -=5;
        
        [self dotedCircles:currentPoint toPoint:currentPoint];
        
        CGRect bounds = CGPathGetBoundingBox(myPath.CGPath);
        CGRect drawBox = CGRectInset(bounds, -2.0 * brushSize, -2.0 * brushSize);
        [self setNeedsDisplayInRect:drawBox];
        //[self setNeedsDisplay];
    }
    
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if((point.x >= 0 && point.x <= self.frame.size.width) &&
       (point.y >= 0 && point.y <= self.frame.size.height)
       )
    {
        return  isActive;
    }
    return  NO;
}

// Smooth Line
CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

// Doted Circles
- (void)dotedCircles:(CGPoint)start toPoint:(CGPoint)end {
    
    CGFloat lineWidth=brushSize;
    if(brushSize / 2 > 1)
    {
        lineWidth=brushSize/2;
    }
    CGFloat dLineWidth = lineWidth * 2;
    //CGRect redrawRect = CGRectMake(end.x-lineWidth,end.y-lineWidth,dLineWidth,dLineWidth);
    //UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:redrawRect];
    NSInteger x=0, y=0;
    
    NSInteger modNumber =2*(int)lineWidth;
    
    x = end.x;
    y = (random() % modNumber)+end.y - dLineWidth;
    /*
     for (int i = 0; i < (lineWidth*lineWidth)/2; i++) {
     //do {
     x = (random() % modNumber)+end.x - dLineWidth;
     y = (random() % modNumber)+end.y - dLineWidth;
     //} while (![circle containsPoint:CGPointMake(x,y)]);
     }
     */
    [myPath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(x,y,0.5,0.5)]];
}

-(void)undoButtonClicked
{
    
//    progress = [[MBProgressHUD alloc] initWithView:self];
//    [self addSubview:progress];
//    progress.dimBackground = YES;
//    progress.delegate = self;
//    [progress show:YES];
//    //[progress hide:YES afterDelay:3];

    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        UIImage* img = [self undoDrawing];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            if(img!=nil)
            {
                currentImageView.image = img;
            }
            
            dontDrawView = true;
            [self setNeedsDisplay];

            AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
        
        });
    });
    
}
-(UIImage*)undoDrawing
{
    // unable to undo when user just tap
    if(touchesMovedCount > 0)
    {
        [pathArray removeLastObject];
    }
    touchesMovedCount = 0;
    
    if([pathArray count]>0){
        bool needToDisplay = true;
        LineDrawingUndoRedoCacha *obj= (LineDrawingUndoRedoCacha *)[pathArray lastObject];
        if(obj->paintTool == FILL)
        {
            needToDisplay = false;
        }
        [bufferArray addObject:obj];
        [pathArray removeLastObject];
       
        /*
         if(bufferArray.count >= 10)
         {
         [bufferArray removeObjectAtIndex:0];
         }
         */
        /*
         if(needToDisplay)
         {
         [self setNeedsDisplay];
         }
         */
        
        UIImage *tempImg = realImage;
    
    
              
        for (LineDrawingUndoRedoCacha *obj2 in pathArray)
        {
            if(obj2 -> paintTool == FILL)
            {
                tempImg = [self floodFillAtPoint:obj2->tpoint withImage:tempImg byColor:obj2.color];
            }
            else
            {
                tempImg = [self mergeLineOnImage:tempImg withLine:obj2];
            }
        }
        
        //currentImageView.image = tempImg;
        return tempImg;
    }
    return nil;
}

-(void)redoButtonClicked
{
//    progress = [[MBProgressHUD alloc] initWithView:self];
//    [self addSubview:progress];
//    progress.dimBackground = YES;
//    progress.delegate = self;
//    [progress show:YES];
    //[progress hide:YES afterDelay:3];
    
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        UIImage* img = [self redoDrawing];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            if(img!=nil)
            {
                currentImageView.image = img;
            }
            
            AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
//            [progress hide:YES];
        });
    });
    
    
}
-(UIImage*)redoDrawing
{
    // unable to undo when user just tap
    if(touchesMovedCount > 0)
    {
        [pathArray removeLastObject];
    }
    touchesMovedCount = 0;
    
    bool needToDisplay = true;
    if([bufferArray count]>0){
        LineDrawingUndoRedoCacha *obj= (LineDrawingUndoRedoCacha *)[bufferArray lastObject];
        if(obj->paintTool == FILL)
        {
            needToDisplay = false;
        }
        [pathArray addObject:obj];
        [bufferArray removeLastObject];
        
        /*
         if(needToDisplay)
         {
         [self setNeedsDisplay];
         }
         */
        
        UIImage *tempImg = realImage;
        for (LineDrawingUndoRedoCacha *obj2 in pathArray)
        {
            if(obj2 -> paintTool == FILL)
            {
                tempImg = [self floodFillAtPoint:obj2->tpoint withImage:tempImg byColor:obj2.color];
            }
            else
            {
                tempImg = [self mergeLineOnImage:tempImg withLine:obj2];
            }
        }
        
        //currentImageView.image = tempImg;
        return tempImg;
    }
    return nil;
}

-(UIImage*)mergeLinesOnImage :(UIImage *) sourceImage
{
    NSMutableArray *_pathArray = pathArray;
    UIImage *resultImage = nil;
    UIGraphicsBeginImageContext(sourceImage.size);
    //UIGraphicsBeginImageContextWithOptions(sourceImage.size, NO, [UIScreen mainScreen].scale);
    [sourceImage drawInRect:(CGRect){CGPointZero, sourceImage.size}];
    
    for (LineDrawingUndoRedoCacha *obj in _pathArray)
    {
        [self linesOnImage:obj];
    }
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext(); //taking the merged result from context, in a new Image. This is your required image.
    UIGraphicsEndImageContext();
    //self.ivFinalImage.image = resultImage;
    return resultImage;
}
-(UIImage*)mergeLineOnImage :(UIImage *) sourceImage withLine:(LineDrawingUndoRedoCacha *)obj
{
    UIImage *resultImage = nil;
    UIGraphicsBeginImageContext(sourceImage.size);
    //UIGraphicsBeginImageContextWithOptions(sourceImage.size, NO, [UIScreen mainScreen].scale);
    [sourceImage drawInRect:(CGRect){CGPointZero, sourceImage.size}];
    
    [self linesOnImage:obj];
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext(); //taking the merged result from context, in a new Image. This is your required image.
    
    UIGraphicsEndImageContext();
    
    //currentImageView.image = resultImage;
    return resultImage;
}
-(void)linesOnImage :(LineDrawingUndoRedoCacha *)obj
{
    if(obj->paintTool == B2 || obj->paintTool == PENCIL)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextAddPath(context, obj->pathSmoothLine);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, obj->brushSize);
        CGContextSetStrokeColorWithColor(context, obj.color.CGColor);
        CGContextSetAlpha(context, defaultAlpha);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextStrokePath(context);
    }
    else if(obj->paintTool == B3)
    {
        [obj.color setStroke];
        [obj.path strokeWithBlendMode:kCGBlendModeNormal alpha:0.4];
    }
    else if(obj->paintTool == Eraser)
    {
        //[eraserColor setStroke];
        //[obj.path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextAddPath(context, obj.path.CGPath);
        CGContextSetLineCap(context, kCGLineCapRound);// diff types
        CGContextSetLineWidth(context, obj.path.lineWidth);
        CGContextSetStrokeColorWithColor(context, eraserColor.CGColor);
        CGContextSetAlpha(context, 1.0);
        CGContextStrokePath(context);
        
    }
    else if(obj->paintTool == B1 || obj->paintTool == DotStroke)
    {
        [obj.color setStroke];
        [obj.path strokeWithBlendMode:kCGBlendModeNormal alpha:defaultAlpha];//1.0]; //Fill or Stroke path as you need.
        //[path fill];
    }
}


#pragma FloodFill Methods
- (UIImage*)floodFillAtPoint:(CGPoint)fillCenter withImage:(UIImage*) image byColor:(UIColor*) fillColor
{
    unsigned char *rawData = [self rawDataFromImage:image];
    
    color fromColor = [FloodFill getColorForX:fillCenter.x Y:fillCenter.y fromImage:rawData imageWidth:image.size.width];
    int fromColorInt = [self mkcolorI:fromColor.red G:fromColor.green B:fromColor.blue A:fromColor.alpha];
    
    CGFloat r, g, b, a;
    
    [fillColor getRed: &r green:&g blue:&b alpha:&a];
    
    CGFloat alpha = 255.0 * ((100.0 - 0.9) / 100.0);
    int toColorInt = [self mkcolorI:r*255 G:g*255 B:b*255 A:alpha];
    
    [FloodFill floodfillX:fillCenter.x Y:fillCenter.y image:rawData width:image.size.width height:image.size.height origIntColor:fromColorInt replacementIntColor:toColorInt];
    
    UIImage *filledImage = [self imageFromRawData:rawData withImage:image];
    free(rawData);
    return filledImage;
}
// creates color int from RGBA
- (int)mkcolorI:(int)red G:(int)green B:(int)blue A:(int)alpha {
    int x = 0;
    x |= (red & 0xff) << 24;
    x |= (green & 0xff) << 16;
    x |= (blue & 0xff) << 8;
    x |= (alpha & 0xff);
    return x;
}
- (unsigned char*)rawDataFromImage:(UIImage*)image
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}
- (UIImage*)imageFromRawData:(unsigned char*)rawData withImage:(UIImage*)image
{
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * image.size.width;
    CGImageRef imageRef = [image CGImage];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 image.size.width,
                                                 image.size.height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    imageRef = CGBitmapContextCreateImage (context);
    UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(context);
    
    CGImageRelease(imageRef);
    
    return rawImage;
}
#pragma End FloodFill Methods

@end
