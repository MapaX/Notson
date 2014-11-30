//
//  DudeEditorViewController.m
//  nic
//
//  Created by Heikki Junnila on 28.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "DudeEditorViewController.h"
#import "LoadingView.h"
#import "Entity.h"

@interface DudeEditorViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField* textField;
@end

@implementation DudeEditorViewController

- (void)viewDidLoad
{
    DLog();

    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    DLog();

    [super viewDidAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:NO];

    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    self.toolbarItems = [NSArray arrayWithObject:item];
    [self.navigationController setToolbarHidden:NO];

    if (self.entity) {
        [self.textField setText:self.entity.name];
    }
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    DLog();
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    DLog();
    [self.textField resignFirstResponder];
    return YES;
}

- (IBAction) onDone:(id)sender
{
    DLog();
    
    [LoadingView show];

    if (!self.entity) {
        self.entity = [[Entity alloc] init];
    }
    
    self.entity.name = self.textField.text;
    [[self.entity save] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"createItem failed with error: %@", task.error);
            [self performSelectorOnMainThread:@selector(onError) withObject:nil waitUntilDone:NO];
        } else {
            Entity* another = (Entity*)task.result;
            DLog(@"Created/updated entity called: %@", another.name);
            [self performSelectorOnMainThread:@selector(onSuccess) withObject:nil waitUntilDone:NO];
        }
        return nil;
    }];
}

- (void) onError
{
    [LoadingView dismiss];
}

- (void) onSuccess
{
    [LoadingView dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
