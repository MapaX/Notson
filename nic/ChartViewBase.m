//
//  ChartViewBase.m
//  Notson
//
//  Created by Heikki Junnila on 25/03/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "ChartViewBase.h"

#define PLACEHOLDER_ALPHA 0.5
#define PLACEHOLDER_DELAY 0.5
#define PLACEHOLDER_DURATION 0.25

@implementation ChartViewBase

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) showWithoutAnimation
{
    // NOP
}

- (void) animateIntoViewAsPlaceholder:(BOOL)placeholder
{
    // NOP
}

- (void) dimAsPlaceholder
{
    DLog();

    self.alpha = 1.0;
    [UIView animateWithDuration:PLACEHOLDER_DURATION
                          delay:PLACEHOLDER_DELAY
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         self.alpha = PLACEHOLDER_ALPHA;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

@end
