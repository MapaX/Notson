//
//  MyEconomicsComparisonViewController.h
//  nic
//
//  Created by Miikka Pakkanen on 30/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "MyEconomicsMeViewController.h"
#import "Bubble.h"

@interface MyEconomicsComparisonViewController : UIViewController
{
    Bubble *_myBubble;
    NSArray *_spendingBubbles;
    NSUInteger _score;
    CGFloat _mySpending;
    CGFloat _smileyFactor;
}

- (CGPoint)getFreePointForRadius:(NSUInteger)radius;
- (void)redrawBubbles;

- (UIColor *)randomColor;

@end
