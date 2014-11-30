//
//  LoadingView.m
//  Notson
//
//  Created by Heikki Junnila on 29/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "ViewController.h"
#import "LoadingView.h"

#define ANIMATION_DURATION 0.0
#define kFixedSizeLoadingView @"FixedSizeLoadingView"

@interface LoadingView ()
@property (weak, nonatomic) IBOutlet UIView *mainView; // iPad only
@property (weak, nonatomic) IBOutlet UIButton* background;
@property (weak, nonatomic) IBOutlet UIImageView* logo;
@property (weak, nonatomic) IBOutlet UILabel* loadLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

static LoadingView *sharedVC = nil;

@implementation LoadingView

- (void) viewDidLoad
{
    DLog();

    [super viewDidLoad];
    [self.loadLabel setText:NSLocalizedString(@"Loading", nil)];
    [self.background setBackgroundColor:UIColorFromRGBWithAlpha(0x003366, 0.9)];
    [self.logo setImage:[UIImage imageNamed:@"Nordea_logo.png"]];
}

+ (LoadingView*)sharedView
{
    NSString* nibName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nibName = @"iPadLoadingView";
    } else {
        nibName = @"LoadingView";
    }

	if (sharedVC == nil) {
		sharedVC = [[LoadingView alloc] initWithNibName:nibName bundle:nil];
    }

	return sharedVC;
}

- (void) show
{
    DLog();

    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [sharedVC.view setFrame:window.rootViewController.view.frame];
    [window.rootViewController.view addSubview:sharedVC.view];


    sharedVC.view.alpha = 1; //immediately to 1 to prevent flashing
    [sharedVC.view needsUpdateConstraints];
    [sharedVC.view updateConstraintsIfNeeded];
    [sharedVC.view setNeedsLayout];
    [sharedVC.view layoutIfNeeded];
    [UIView animateWithDuration:ANIMATION_DURATION
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 sharedVC.view.alpha = 1;
					 }
					 completion:^(BOOL finished) {
                     }
     ];
}

- (void) dismiss
{
    DLog();

    [UIView animateWithDuration:ANIMATION_DURATION
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 sharedVC.view.alpha = 0;
					 }
					 completion:^(BOOL finished){
                         if (sharedVC.view.alpha == 0) {
                             [sharedVC.view removeFromSuperview];
                             sharedVC = nil;
                         }
                     }
     ];
}

+ (void) show
{
    [[LoadingView sharedView] show];
}

+ (void) dismiss
{
    [[LoadingView sharedView] dismiss];
}

/**
 * Use this method to create non blocking progress view on top of view
 * Example can be seen from MarketInformationSearchBaseViewController
 */
+ (void)showOnParentView:(UIView *)view
{
    [LoadingView dismiss];
    
    sharedVC = [[LoadingView alloc] initWithNibName:kFixedSizeLoadingView bundle:nil];
    
    CGRect frame = view.frame;
    frame.origin = CGPointMake(0, 0);
    sharedVC.view.frame = frame;
    
    [view addSubview:sharedVC.view];
    
    sharedVC.view.alpha = 0;
    sharedVC.activityIndicator.alpha = 0;
    sharedVC.loadLabel.alpha = 0;
    sharedVC.mainView.alpha = 0;
    
    [UIView animateWithDuration:0.2
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 sharedVC.view.alpha = 1;
                         sharedVC.activityIndicator.alpha = 1;
                         sharedVC.loadLabel.alpha = 1;
                         sharedVC.mainView.alpha = 0.10;
					 }
					 completion:^(BOOL finished) {
                     }
     ];
}

@end
