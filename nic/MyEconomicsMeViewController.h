//
//  MyEconomicsMeViewController.h
//  nic
//
//  Created by Miikka Pakkanen on 29/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bubble.h"

#define kBubbleMaxSize 84

@interface MyEconomicsMeViewController : UIViewController
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


@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@end
