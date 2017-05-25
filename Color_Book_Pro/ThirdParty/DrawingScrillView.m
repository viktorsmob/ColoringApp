//
//  DrawingScrillView.m
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 29/10/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import "DrawingScrillView.h"

@implementation DrawingScrillView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if((unsigned long)[[event allTouches] count] > 1 && isZoomOn)
    {
         //[self setScrollEnabled:YES];
        [super touchesBegan: touches withEvent: event];
    }
    else
    {
        //self.panGestureRecognizer.enabled = NO;
         //[self setScrollEnabled:NO];
         [[self nextResponder] touchesBegan:touches withEvent:event];
    }
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if((unsigned long)[[event allTouches] count] > 1 && isZoomOn)
    {
        [super touchesMoved: touches withEvent: event];
    }
    else
    {
        [[self nextResponder] touchesMoved:touches withEvent:event];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if((unsigned long)[[event allTouches] count] > 1 && isZoomOn)
    {
        [super touchesEnded: touches withEvent: event];
    }
    else
    {
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
}

@end
