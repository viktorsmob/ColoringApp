//
//  GalleryViewController.h
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 22/09/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GalleryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}
@property(nonatomic,retain)IBOutlet UICollectionView *clImgs;
@property(nonatomic,retain)NSMutableArray *marrImages;
@property (nonatomic, nonatomic) IBOutlet UIView *bottomMenu;
@property(nonatomic,retain)IBOutlet UIImageView *ivEmptyGallery;


@property(nonatomic,retain)NSIndexPath *selectedItemIndexPath;
@end

UIImage *selectedImage;