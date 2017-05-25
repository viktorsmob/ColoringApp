//
//  AboutMenuUIViewController.h
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 07/12/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutMenuUIViewController;
@protocol AboutMenuUIViewControllerDelegate <NSObject>

@required
- (void) AboutMenuClosedWithTag:(id) sender;

@end

@interface AboutMenuUIViewController : UIViewController

@property (nonatomic, weak) id <AboutMenuUIViewControllerDelegate> delegate;

@end

typedef enum {
    
    ABOUT_SHARE = 1,
    ABOUT_LINK_RATE = 2,
    ABOUT_LINK_APPS = 3,
    ABOUT_LINK_3 = 4,
    ABOUT_ABOUT = 5,
    ABOUT_CANCEL = 6
} AboutMenuButtons;
