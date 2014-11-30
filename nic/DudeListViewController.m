//
//  DudeListViewController.m
//  nic
//
//  Created by Heikki Junnila on 28.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "DudeEditorViewController.h"
#import "DudeListViewController.h"
#import "LoadingView.h"
#import "Entity.h"

@interface DudeListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* entityList;
@end

@implementation DudeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:NO];

    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onCreateDude:)];
    self.toolbarItems = [NSArray arrayWithObject:item];
    [self.navigationController setToolbarHidden:NO];
    
    [self listProducts];
}

- (void)listProducts
{
    [LoadingView show];

    IBMQuery *query = [Entity query];
    [[query find] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"Error while getting entities: %@", task.error);
            [self performSelectorOnMainThread:@selector(updateDataWithObjects:) withObject:nil waitUntilDone:YES];
        } else {
            NSArray *objects = (NSArray*) task.result;
            DLog(@"Got %lu entities", (unsigned long)objects.count);
    
            [self performSelectorOnMainThread:@selector(updateDataWithObjects:) withObject:objects waitUntilDone:YES];
        }
        return nil;
    }];
}

- (void) updateDataWithObjects:(NSArray*)objects
{
    DLog();

    [LoadingView dismiss];

    self.entityList = objects;
    [self.tableView reloadData];
}

- (IBAction) onCreateDude:(id)sender
{
    DLog();

    DudeEditorViewController* controller = [[DudeEditorViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark- UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entityList.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Entity* entity = [self entityForIndexPath:indexPath];
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[Entity dataClassName]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[Entity dataClassName]];
        [cell.textLabel setText:entity.name];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Entity* entity = [self entityForIndexPath:indexPath];
    DudeEditorViewController* controller = [[DudeEditorViewController alloc] init];
    [controller setEntity:entity];
    [self.navigationController pushViewController:controller animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (Entity*) entityForIndexPath:(NSIndexPath*)indexPath
{
    Entity* entity = [self.entityList objectAtIndex:indexPath.row];
    return entity;
}

@end
