//
//  ImagePickerView.h
//  Color_Book_Pro
//
//  Created by TPS Technology on 21/04/15.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ImagePickerView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,MBProgressHUDDelegate>
{
     MBProgressHUD *HUD;
}
@property(nonatomic,retain)IBOutlet UICollectionView *clImgs;
@property(nonatomic,retain)IBOutlet UILabel *lblTitle;
@property(nonatomic,retain)NSString *strTitle;
@property(nonatomic,retain)NSMutableArray *marrImages;
@property(readwrite,assign)int ctag;
@end
