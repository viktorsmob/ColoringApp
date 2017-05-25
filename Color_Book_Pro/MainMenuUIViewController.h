//
//  MainMenuViewController.h
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 08/12/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainMenuUIViewController;
@protocol MainMenuUIViewControllerDelegate <NSObject>

@required
- (void) MainMenuClosedWithTag:(int) tag;

@end


@interface MainMenuUIViewController : UIViewController

@property (nonatomic, weak) id <MainMenuUIViewControllerDelegate> delegate;

@end

typedef enum {
    MAIN_MENU_RESTART_IMAGE = 1,
    MAIN_MENU_NEW_IMAGE = 2,
    MAIN_MENU_RANDOM_IMAGE = 3,
    MAIN_MENU_MY_GALLERY = 4,
    MAIN_MENU_EXIT = 5,
    MAIN_MENU_CANCEL = 6
} MainMenuButtons;
