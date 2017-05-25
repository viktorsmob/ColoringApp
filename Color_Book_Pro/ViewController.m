//
//  ViewController.m
//  Color_Book_Pro
//
//  Created by TPS Technology on 21/04/15.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import "ViewController.h"
#import "CCatCell.h"
#import "Gloabals.h"
#import "ImagePickerView.h"


@interface ViewController ()
    
@end

@implementation ViewController
@synthesize cvCategory,arrCategories,lblMainTitle;

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view, typically from a nib.

    if (IS_IPAD )
        self.lblMainTitle.font=[UIFont fontWithName:@"Istok-Bold" size:45];
    else
        self.lblMainTitle.font=[UIFont fontWithName:@"Istok-Bold" size:28];
    
    self.arrCategories=KARR_CATEGORIES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arrCategories count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCatCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"category" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    cell.btnCategory.tag=indexPath.row;
    [cell.btnCategory setTitle:[self.arrCategories objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    if (IS_IPAD)
        cell.btnCategory.titleLabel.font=[UIFont fontWithName:@"Istok-Regular" size:35];
    else
        cell.btnCategory.titleLabel.font=[UIFont fontWithName:@"Istok-Regular" size:20];
    
    [cell.btnCategory addTarget:self action:@selector(btnCategoryClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectedBackgroundView.backgroundColor=[UIColor clearColor];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width=self.cvCategory.frame.size.width-20;
    float height;
    if (IS_IPAD)
        height=130;
    else
        height=70;
    
    return CGSizeMake(width,height);
}

-(IBAction)btnCategoryClick:(id)sender
{
    [self performSegueWithIdentifier:@"imgPick" sender:sender];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *btn=(UIButton*)sender;
    ImagePickerView *imgPicker=[segue destinationViewController];
    imgPicker.strTitle=[self.arrCategories objectAtIndex:btn.tag];
    imgPicker.ctag=(int)btn.tag;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackClick:(id)sender {
    
            [self.navigationController popToRootViewControllerAnimated:YES];
     
}


@end
