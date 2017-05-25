//
//  GalleryViewController.m
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 22/09/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import "GalleryViewController.h"
#import "Gloabals.h"
#import "ImgColCell.h"
#import "EditImageView.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController
{
}
@synthesize marrImages, bottomMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.marrImages=[[NSMutableArray alloc]init];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    self.clImgs.hidden = YES;
    self.ivEmptyGallery.hidden = YES;
    
    [self fileListAtPath:Save_Folder_Name];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnBackClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)fileListAtPath:(NSString *)path
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* dirPath = [paths objectAtIndex:0];
    
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *paths1 = [sharedFM URLsForDirectory:NSLibraryDirectory
                                      inDomains:NSUserDomainMask];
    if ([paths count] > 0) {
        NSString *documentsPath = [paths1[0] path];
        NSDirectoryEnumerator *enumerator = [sharedFM enumeratorAtPath:documentsPath];
        NSString *path;
        NSMutableArray *temp = [[NSMutableArray alloc]init];
        while(path = [enumerator nextObject])
        {
             NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '_img.png' AND self BEGINSWITH[c] %@",@"img_"];
            if([fltr evaluateWithObject:path])
            {
                [temp addObject:[dirPath stringByAppendingPathComponent:path]];
            }
        }
        
        // reverse array
            NSEnumerator* myIterator = [temp reverseObjectEnumerator];
            while(path = [myIterator nextObject])
            {
                [self.marrImages addObject:path];
            }
    
    }
    
    if (self.marrImages.count == 0) {
        self.ivEmptyGallery.hidden = NO;
        self.clImgs.hidden = YES;
    }else{
        self.ivEmptyGallery.hidden = YES;
        self.clImgs.hidden = NO;
    }
}

- (IBAction)playBottomMenu:(id)sender {   
    
    selectedImage = [UIImage imageWithContentsOfFile:(self.marrImages)[self.selectedItemIndexPath.row]];
    [self performSegueWithIdentifier:@"play_bottom_menu" sender:self.clImgs];
    
    //[self hideBottomMenu];
}

- (IBAction)deleteBottomMenu:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Delete Image"
                          message: @"Are you sure?"
                          delegate: self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles: @"Delete", nil];
    alert.tag = 1;
    [alert show];
}
// Called when an alertview button is clicked
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
        {
            switch (buttonIndex) {
                case 0: // cancel
                {
                    [self hideBottomMenu];
                }
                    break;
                case 1: // delete
                {
                    NSString * path = [self.marrImages objectAtIndex:[self.selectedItemIndexPath row]];
                    if([[NSFileManager defaultManager] removeItemAtPath:path error:nil])
                    {
                        
                        [self.clImgs performBatchUpdates:^{
                            
                            [marrImages removeObjectAtIndex:[self.selectedItemIndexPath row]];
                            NSIndexPath *indexPath =[NSIndexPath indexPathForRow:[self.selectedItemIndexPath row] inSection:0];
                            [self.clImgs deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                            
                            
                        } completion:^(BOOL finished) {
                            [self hideBottomMenuWithoutLoad];
                            
                            
                            if (self.marrImages.count == 0) {
                                self.ivEmptyGallery.hidden = NO;
                                self.clImgs.hidden = YES;
                            }else{
                                self.ivEmptyGallery.hidden = YES;
                                self.clImgs.hidden = NO;
                            }
                        }];
                        
                    }
                    else
                    {
                    NSLog(@"can't remove");
                         [self hideBottomMenu];
                    }
                    
                    
                }
                    break;
            }
            break;
        default:
            {
            //
            }
        }
    }	
}

- (IBAction)shareBottomMenu:(id)sender {
    
    selectedImage = [UIImage imageWithContentsOfFile:(self.marrImages)[self.selectedItemIndexPath.row]];
    UIButton *imagePickerButton = (UIButton*)sender;
    NSArray *Items   = [NSArray arrayWithObjects:
                        selectedImage, nil];
    
    UIActivityViewController *ActivityView =
    [[UIActivityViewController alloc]
     initWithActivityItems:Items applicationActivities:nil];
    // Exclude following activities.
    NSArray *excludedActivities = @[
                                    UIActivityTypePrint,
                                    UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,UIActivityTypeAirDrop
                                    ];
    ActivityView.excludedActivityTypes = excludedActivities;
    ActivityView.popoverPresentationController.sourceView = imagePickerButton;
    [self presentViewController:ActivityView animated:YES completion:nil];
    
    [self hideBottomMenu];
}

-(void)hideBottomMenu
{
    // Hide bottom menu
    bottomMenu.hidden = true;
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:self.selectedItemIndexPath];
    self.selectedItemIndexPath = nil;
    [self.clImgs reloadItemsAtIndexPaths:indexPaths];
}
-(void)hideBottomMenuWithoutLoad
{
    // Hide bottom menu
    bottomMenu.hidden = true;
    self.selectedItemIndexPath = nil;
}

#pragma mark - CollectionView
float ftotal1=255.0f;

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.marrImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgColCell *ccell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ccell" forIndexPath:indexPath];
     ccell.ivImages.image = [UIImage imageWithContentsOfFile:(self.marrImages)[indexPath.row]];
    
    if (IS_IPAD)
        ccell.ivImages.layer.cornerRadius = 20.0;
    else
        ccell.ivImages.layer.cornerRadius = 10.0;
    
    if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame)
    {
     ccell.ivImages.layer.borderColor = [[UIColor colorWithRed:75/ftotal1 green:59/ftotal1 blue:167/ftotal1 alpha:1] CGColor];
    }
    else
    {
     ccell.ivImages.layer.borderColor = [[UIColor colorWithRed:0/ftotal1 green:0/ftotal1 blue:0/ftotal1 alpha:1] CGColor];
    }
    
    ccell.ivImages.layer.borderWidth = 2.0;
    ccell.ivImages.layer.masksToBounds = YES;
    return ccell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    
    if (self.selectedItemIndexPath)
    {
        if ([indexPath compare:self.selectedItemIndexPath] == NSOrderedSame)
        {
            self.selectedItemIndexPath = nil;
            bottomMenu.hidden = true;
        }
        else
        {
            [indexPaths addObject:self.selectedItemIndexPath];
            self.selectedItemIndexPath = indexPath;
            [self.view bringSubviewToFront:bottomMenu];
            bottomMenu.hidden = false;
        }
    }
    else
    {
        self.selectedItemIndexPath = indexPath;
        [self.view bringSubviewToFront:bottomMenu];
        bottomMenu.hidden = false;
    }
    [collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width=self.clImgs.frame.size.width/3-10;
    
    float height;
    if (IS_IPAD)
        height=400;
    else if (IS_IPHONE_6)
        height=200;
    else if (IS_IPHONE_6P)
        height=225;
    else
        height=175;
    return CGSizeMake(width,height);
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"play_bottom_menu"])
    {
        
        EditImageView *editIv=[segue destinationViewController];
        editIv.imgFinalImage = selectedImage;
        
        
        
         NSString* theFileName = [[(self.marrImages)[self.selectedItemIndexPath.row] lastPathComponent] stringByDeletingPathExtension];
        NSArray * array = [theFileName componentsSeparatedByString:@"-"];
        if(array.count > 1)
        {
            NSLog(@"pppppp %@", array[1]);
            editIv->imgFinalImageName =array[1];
        }
        else
        {
            editIv->imgFinalImageName = @"";
        }
    }
}


@end
