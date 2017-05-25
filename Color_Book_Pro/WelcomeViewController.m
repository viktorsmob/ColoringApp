//
//  WelcomeViewController.m
//  Color_Book_Pro
//
//  Created by Atif Mahmood on 19/09/2015.
//  Copyright (c) 2015 TPS Technology. All rights reserved.
//

#import "WelcomeViewController.h"
#import "EditImageView.h"
#import "Gloabals.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ws_about_dialog"])
    {
        UIViewController *newVC = segue.destinationViewController;
        [WelcomeViewController setPresentationStyleForSelfController:self presentingController:newVC];
    }
    else if ([[segue identifier] isEqualToString:@"play_random_pic"])
    {
       // Get random category index
        NSArray *arrCategories = KARR_CATEGORIES;
        int min = 0;
        NSUInteger max = [arrCategories count] - 1;
        int randNum = rand() % (max - min) + min;
        
        
        // Get all pictures from above selected category
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png' AND self BEGINSWITH[c] %@",
                             [arrCategories objectAtIndex:randNum]
                             ];
        NSArray *imgNames = [dirContents filteredArrayUsingPredicate:fltr];
        NSMutableArray *marrImages=[[NSMutableArray alloc]init];
        marrImages =[NSMutableArray arrayWithArray:imgNames];
        
        
        // Assign random picture path to next screen
        min = 0;
        max = [marrImages count] - 1;
        randNum = rand() % (max - min) + min;
        EditImageView *editIv=[segue destinationViewController];
        editIv.imgFinalImage=[UIImage imageNamed:[marrImages objectAtIndex:randNum]];
        editIv->imgFinalImageName = [marrImages objectAtIndex:randNum];
    }
   
}

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}


- (IBAction)linkRateUrl:(id)sender {
   
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/calcfast/%@", APP_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
    
}

- (IBAction)linkAppUrl:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://google.com"]];
    
}

- (IBAction)linkUrl:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.example.com"]];
    
}

- (IBAction)onClickBrowse:(id)sender{
    
#ifdef MULTI_CATEGORY
    [self performSegueWithIdentifier:@"showCategory" sender:sender];
#else
    [self performSegueWithIdentifier:@"showImages" sender:sender];
#endif
}

@end
