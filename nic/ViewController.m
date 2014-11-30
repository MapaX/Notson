//
//  ViewController.m
//  nic
//
//  Created by Heikki Junnila on 25.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>
#import "AppDelegate.h"
#import "DudeListViewController.h"
#import "ViewController.h"
#import "LoadingView.h"
#import "BIDViewController.h"
#import "AppDelegate.h"

#define ALERTVIEW_TAG_NO_TOUCH_ID  0
#define ALERTVIEW_TAG_LOGIN_FAILED 1

@interface ViewController () <UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *loginAsLabel;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;
@end

@implementation ViewController

- (void)viewDidLoad
{
    DLog();
    [super viewDidLoad];
    
    [self.loginButton setTitle:NSLocalizedString(@"Sign in", nil) forState:UIControlStateNormal];
}

- (void) viewDidAppear:(BOOL)animated
{
    DLog();
    
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(doLogin)];
    leftEdgeGesture.edges = UIRectEdgeBottom;
    leftEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:leftEdgeGesture];
    NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
    if (username) {
        [self.loginAsLabel setText:[NSString stringWithFormat:@"Login as %@", username]];
    }
    
}

- (void) doLogin
{
    DLog();
    
    [LoadingView show];
    
    LAContext* ctx = [[LAContext alloc] init];
    
    BOOL touchIdEnabled = [ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if (touchIdEnabled) {
        [ctx evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"Login", nil)
                      reply:^(BOOL success, NSError* error) {
                          if (success) {
                              DLog(@"Authentication successful.");
                              [self performSelectorOnMainThread:@selector(onLoginSuccess) withObject:nil waitUntilDone:NO];
                          } else {
                              DLog(@"Authentication failed.");
                              [self performSelectorOnMainThread:@selector(onLoginFailedWithError:) withObject:error waitUntilDone:NO];
                          }
                          
                      }
         ];
    } else {
        [self gatherLoginInfo:3];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Touch ID not enabled", nil)
                                                        message:NSLocalizedString(@"Shhh, I'm letting you in anyway...", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Wow, thanks!", nil)
                                              otherButtonTitles:nil];
        [alert setTag:ALERTVIEW_TAG_NO_TOUCH_ID];
        [alert show];
    }
    
}

- (void) onLoginFailedWithError:(NSError*)error
{
    NSString* msg = nil;
    switch (error.code) {
        case LAErrorAuthenticationFailed: {
            [self gatherLoginInfo:2];
            msg = NSLocalizedString(@"Authentication Failed", nil);
        } break;
            
        case LAErrorUserCancel: {
            [self gatherLoginInfo:4];
            msg = NSLocalizedString(@"User pressed Cancel button", nil);
        } break;
            
        case LAErrorUserFallback: {
            [self gatherLoginInfo:4];
            msg = NSLocalizedString(@"User pressed \"Enter Password\"", nil);
        } break;
            
        default: {
            [self gatherLoginInfo:4];
            msg = NSLocalizedString(@"Touch ID is not configured", nil);
        } break;
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login failed", nil)
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                          otherButtonTitles:NSLocalizedString(@"Try again", nil), nil];
    [alert setTag:ALERTVIEW_TAG_LOGIN_FAILED];
    [alert show];
}

- (void) onLoginSuccess
{
    DLog();
    
    //creepy
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
    
    if (username == nil) {
        username = @"Unidentified user";
    }
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"User"
                                                          action:@"User name"
                                                           label:username
                                                           value:0] build]];
    
    [self gatherLoginInfo:1];
    
    [LoadingView dismiss];
    
    UIViewController* vc = [[UIStoryboard storyboardWithName:@"MyEconomics" bundle:nil] instantiateViewControllerWithIdentifier:@"MyEconomicsViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI Button Actions

- (IBAction) onLoginButton:(id)sender
{
    DLog();
    [self doLogin];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog();
    
    [LoadingView dismiss];
    
    if (alertView.tag == ALERTVIEW_TAG_LOGIN_FAILED) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self doLogin];
        }
    } else if (alertView.tag == ALERTVIEW_TAG_NO_TOUCH_ID) {
        [self onLoginSuccess];
    }
}

-(void) gatherLoginInfo:(int) loginResult
{
    DLog();
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSString* prettyLoginOutput;
    
    switch (loginResult) {
        case 1:
            prettyLoginOutput = @"touchID Authentication Success";
            break;
        case 2:
            prettyLoginOutput = @"touchID Authentication Failed";
            break;
        case 3:
            prettyLoginOutput = @"HeikkiID Authentication Success";
            break;
        case 4:
            prettyLoginOutput = @"touchID User cancelled Authentication";
            break;
            
            
    };
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Authentication"     // Event category (required)
                                                          action:@"Login"  // Event action (required)
                                                           label:prettyLoginOutput          // Event label
                                                           value:[NSNumber numberWithInt:loginResult]] build]];
}

@end
