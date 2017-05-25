//
//  UndoRedoCachay.h
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 06/10/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LineDrawingUndoRedoCacha : NSObject
{
    @public NSInteger paintTool;
    
    // Smooth Line
    @public CGMutablePathRef pathSmoothLine;
    @public CGFloat brushSize;
    
    // FloodFill
     @public CGPoint tpoint;
}
    @property(nonatomic,retain)IBOutlet UIColor *color;
    @property(nonatomic,retain)IBOutlet UIBezierPath *path;

@end