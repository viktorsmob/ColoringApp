//
//  ViewController.h
//  Color_Book_Pro
//
//  Created by TPS Technology on 21/04/15.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,retain)IBOutlet UICollectionView *cvCategory;
@property(nonatomic,retain)NSArray *arrCategories;
@property(nonatomic,retain)IBOutlet UILabel *lblMainTitle;

@end

