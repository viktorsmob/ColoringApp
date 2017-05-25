//
//  Gloabals.h
//  Color_Book_Pro
//
//  Created by TPS Technology on 21/04/15.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#ifndef Color_Book_Pro_Gloabals_h
#define Color_Book_Pro_Gloabals_h



#endif

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define APP_ID @"APP_ID_FROM_APP_STORE"

#define KARR_CATEGORIES arrCategories=[[NSArray alloc]initWithObjects:@"Baby",@"Butterfly",@"Cat",@"Dog",@"Dragon",@"Dinosaur",@"Fish",@"Flower", nil];

#define Save_Folder_Name @"Color Book Pro"

#define KBANNERHEIGHT_IPAD_PORTRAIT 90

#define ADMOB_BANNER_ID  @"ca-app-pub-3940256099942544/2934735716"

#define KADMOB_TESTING_DEVICE_ID @"12dffc83f9575sgdggfa1dd74c71a71425f"

#define KADMOB_TESTING YES

//#define MULTI_CATEGORY YES

typedef enum {
    FILL = 6,
    PENCIL = 7,
    DotStroke = 8,
    Eraser = 9,
    B1 = 12,
    B2 = 13,
    B3 = 14,
    Zoom = 15
    
} PaintTool;
