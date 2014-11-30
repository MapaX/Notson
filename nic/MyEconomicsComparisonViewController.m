//
//  MyEconomicsComparisonViewController.m
//  nic
//
//  Created by Miikka Pakkanen on 30/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "DataManager.h"
#import "CategorySpending.h"
#import "AppDelegate.h"
#import "Entity.h"

#import "MyEconomicsComparisonViewController.h"

@interface MyEconomicsComparisonViewController () <DataManagerDelegate, EntityDelegate>
{
    CGFloat _comparisonSpending;
}
@end

@implementation MyEconomicsComparisonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [[[self navigationController] topViewController] setTitle:@"Comparison"];
    [[self navigationItem] setTitle:@"Comparison"];
    [_myBubble.bubbleView removeFromSuperview];
    _myBubble.bubbleView = nil;
    for (Bubble *bubble in _spendingBubbles)
    {
        [bubble.bubbleView removeFromSuperview];
        bubble.bubbleView = nil;
    }
    
    _spendingBubbles = nil;
    
    DataManager* dm = [DataManager instance];
    [dm setDelegate:self];
    [dm fetchEntities];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)randomColor
{
    return [UIColor colorWithRed:(arc4random()%256)/256.0 green:(arc4random()%256)/256.0 blue:(arc4random()%256)/256.0 alpha:1.0];
}

- (void)redrawBubbles
{
    [_myBubble.bubbleView removeFromSuperview];
    _myBubble.bubbleView = nil;
    for (Bubble *bubble in _spendingBubbles)
    {
        [bubble.bubbleView removeFromSuperview];
        bubble.bubbleView = nil;
    }
    
    // First draw my bubble.
    _myBubble = [[Bubble alloc] init];
    [_myBubble setBubbleSize:2];
    [_myBubble setBubbleColor:[UIColor blueColor]];
    [_myBubble setSpending:_mySpending];
    [_myBubble setSmileyFactor:_smileyFactor];
    UIImage* selfie = [(AppDelegate *) [UIApplication sharedApplication].delegate selfie];
    [_myBubble setImage:selfie];
    
    
    [_myBubble blobInView:self.view inPosition:CGPointMake(self.view.frame.size.width*.4, self.view.frame.size.height*.35)];
    [_myBubble.bubbleView addTarget:self action:@selector(onBubbleClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // Then draw all spending bubbles with random delays
    NSTimeInterval totalDelay = 0;
    for (Bubble *bubble in [_spendingBubbles sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"bubbleSize" ascending:NO]]])
    {
        [bubble setBubbleColor:[self randomColor]];
        NSTimeInterval delay = (arc4random()%500) / 1000.0;
        totalDelay += delay;
        [self performSelector:@selector(doBlobForBubble:) withObject:bubble afterDelay:totalDelay];
    }
}

- (void)doBlobForBubble:(Bubble *)bubble
{
    CGPoint point = [self getFreePointForRadius:bubble.bubbleSize * kBubbleMaxSize / 2];
    
    [bubble blobInView:self.view inPosition:point];
    [bubble.bubbleView addTarget:self action:@selector(onBubbleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bubble.bubbleView setName:bubble.bubbleTitle];
}

- (CGPoint)getFreePointForRadius:(NSUInteger)radius
{
    if (radius > 90)
        DLog(@"Big");
    CGPoint randomPoint;
    BOOL foundBubble;
    
    NSUInteger startHeight = radius;
    NSUInteger endHeight = 450-radius;
    NSUInteger startWidth = radius;
    NSUInteger endWidth = 320-radius;
    NSUInteger step = 10;
    NSUInteger index = 0;
    
    do {
        foundBubble = NO;
        NSUInteger randomColumn = (arc4random() % ((endWidth - startWidth)/step)) + (startWidth / step);
        NSUInteger randomRow = (arc4random() % ((endHeight - startHeight)/step)) + (startHeight / step);
        randomPoint = CGPointMake(randomColumn * step, (randomRow * step)+50);
        
        
        // Check my bubble.
        if (_myBubble.bubbleView)
        {
            CGPoint oldCenter = _myBubble.bubbleView.center;
            
            // Bubbles will intersect if the distance between centers is less than the sum of their radia.
            CGFloat xDist = (oldCenter.x - randomPoint.x);
            CGFloat yDist = (oldCenter.y - randomPoint.y);
            CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
            if (distance < (_myBubble.bubbleSize*kBubbleMaxSize/2) + radius)
            {
                foundBubble = YES;
            }
        }
        
        // Check other bubbles
        
        if (!foundBubble)
        {
            for (Bubble *bubble in _spendingBubbles)
            {
                if (bubble.bubbleView)
                {
                    CGPoint oldCenter = bubble.bubbleView.center;
                    
                    // Bubbles will intersect if the distance between centers is less than the sum of their radia.
                    CGFloat xDist = (oldCenter.x - randomPoint.x);
                    CGFloat yDist = (oldCenter.y - randomPoint.y);
                    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
                    if (distance < (bubble.bubbleSize*kBubbleMaxSize/2) + radius)
                    {
                        foundBubble = YES;
                        break;
                    }
                }
            }
        }
        if (index > 998)
            NSLog(@"Not finding");
    } while (foundBubble && index++ < 1000);
    
    return CGPointMake(randomPoint.x-radius, randomPoint.y-radius);
}


- (void) onBubbleClicked:(id)sender
{
    
}

- (void) dataManager:(DataManager *)dataManager finishedFetchingEntities:(NSArray *)entities
{
    
    DLog(@"%@", entities);
    for (Entity *e in entities)
    {
        [e setDelegate:self];
        [e fetchCategorySpending];
    }
    //_mySpending = e.incomeThisPeriod.floatValue / e.averagePeriodIncome.floatValue;
}

- (void) entity:(Entity *)entity finishedFetchingCategorySpending:(NSArray *)categorySpending
{
    NSMutableArray *bubbles = [NSMutableArray array];
    
    CGFloat total;
    CGFloat averageTotal;
    for (CategorySpending *cs in categorySpending)
    {
        total += [cs.amount floatValue];
        averageTotal += [cs.averageSpending floatValue];
    }
    
    if ([self entityIsJohn:entity])
    {
        _mySpending = total / averageTotal;
    }
    else
    {
        _comparisonSpending = total / averageTotal;
    }
    
    // Come up with estimate and color background accordingly
    CGFloat totalEstimate = _mySpending / _comparisonSpending;
    UIColor *bgColor;
    CGFloat totalEstimateDiff = (totalEstimate - 1.0) * 2;
    if (totalEstimate > 1.0 || [[self.view.layer sublayers] count] > 0)
    {
        bgColor = [UIColor colorWithRed:1.0 green:1.0 - totalEstimateDiff blue:1.0 - totalEstimateDiff alpha:1.0];
        _smileyFactor = 1.0;
        [_myBubble setSmileyFactor:_smileyFactor];
    }
    else
    {
        bgColor = [UIColor colorWithRed:1.0 + totalEstimateDiff green:1.0 blue:1.0 + totalEstimateDiff alpha:1.0];
        _smileyFactor = 1.0 + totalEstimateDiff;
        [_myBubble setSmileyFactor:_smileyFactor];
    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[bgColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    //    [self.view setBackgroundColor:bgColor];

    
    CGFloat average = total/categorySpending.count;

    if ([self entityIsJohn:entity])
    {
        for (CategorySpending *cs in categorySpending)
        {
            Bubble *bubble = [[Bubble alloc] init];
            [bubble setBubbleTitle:cs.category];
            [bubble setBubbleSize:[cs.amount intValue] / average];
            [bubble setBubbleColor:[self randomColor]];
            [bubble setSpending:[cs.amount floatValue] / [cs.averageSpending floatValue]];
            [bubbles addObject:bubble];
        }
        
        
        
        _spendingBubbles = bubbles;
        
        DLog(@"%@", categorySpending);
        
        [self redrawBubbles];
        
    }
}

-(BOOL)entityIsJohn:(Entity *)entity
{
    return [entity.name containsString:@"John Doewater"];
}
@end

