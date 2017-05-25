//
//  ImagePickerView.m
//  Color_Book_Pro
//
//  Created by TPS Technology on 21/04/15.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import "ImagePickerView.h"
#import "ImgColCell.h"
#import "EditImageView.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Gloabals.h"

@interface ImagePickerView ()

@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ImagePickerView
{

}
@synthesize lblTitle,strTitle,clImgs,marrImages,ctag;

float ftotal=255.0f;
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#ifdef MULTI_CATEGORY
    self.strTitle=[self.strTitle stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.lblTitle.text=self.strTitle;
#else
    self.lblTitle.text = @"Images";
#endif
    
    
    self.marrImages=[[NSMutableArray alloc]init];
    [self getParts];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    if (IS_IPAD )
        self.lblTitle.font=[UIFont fontWithName:@"Istok-Bold" size:45];
    else
        self.lblTitle.font=[UIFont fontWithName:@"Istok-Bold" size:35];
    
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getParts
{
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
 
#ifdef MULTI_CATEGORY
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png' AND self BEGINSWITH[c] %@",self.strTitle];
#else
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png' AND (self BEGINSWITH[c] 'Baby') OR (self BEGINSWITH[c] 'Cat') OR (self BEGINSWITH[c] 'Butterfly') OR (self BEGINSWITH[c] 'Dinosaur') OR (self BEGINSWITH[c] 'Dog') OR (self BEGINSWITH[c] 'Dragon') OR (self BEGINSWITH[c] 'Fish') OR (self BEGINSWITH[c] 'Flower')"];
#endif
    
    NSArray *imgNames = [dirContents filteredArrayUsingPredicate:fltr];
    self.marrImages =[NSMutableArray arrayWithArray:imgNames];
}

- (void)viewDidLayoutSubviews
{
    
}

-(IBAction)btnBackClick:(id)sender
{
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
#ifdef MULTI_CATEGORY
    [self.navigationController popViewControllerAnimated:YES];
#else
    [self.navigationController popToRootViewControllerAnimated:YES];
#endif
}

- (void)installDidReceive {
    
}

- (void)installDidFail {
    
}


#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.marrImages count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgColCell *ccell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ccell" forIndexPath:indexPath];
    ccell.ivImages.image=[UIImage imageNamed:[self.marrImages objectAtIndex:indexPath.row]];
    
    if (IS_IPAD)
        ccell.ivImages.layer.cornerRadius = 20.0;
    else
        ccell.ivImages.layer.cornerRadius = 10.0;
    ccell.ivImages.layer.borderColor = [[UIColor colorWithRed:75/ftotal green:59/ftotal blue:167/ftotal alpha:1] CGColor];
    ccell.ivImages.layer.borderWidth = 2.0;
    ccell.ivImages.layer.masksToBounds = YES;
    return ccell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"editImage" sender:self.clImgs];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width=self.clImgs.frame.size.width/2-10;
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSArray *indexPaths=[self.clImgs indexPathsForSelectedItems];
    NSIndexPath *path=[indexPaths objectAtIndex:0];
    EditImageView *editIv=[segue destinationViewController];
    editIv.imgFinalImage=[UIImage imageNamed:[self.marrImages objectAtIndex:path.row]];
    editIv->imgFinalImageName = [self.marrImages objectAtIndex:path.row];
}


@end
