//
//  PieChartView.m
//  Notson
//
//  Created by Heikki Junnila on 05/03/14
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PieChartView.h"

@interface PieChartView ()
@property (nonatomic, assign) CGFloat animPercent;
@property (nonatomic, assign) BOOL alreadyAnimated;
@end

@implementation PieChartView

- (void) showWithoutAnimation
{
    DLog();
    self.alreadyAnimated = YES;
    self.animPercent = 1.0;
    self.alpha = 1.0;
    [self setNeedsDisplay];
}

- (void) animateIntoViewAsPlaceholder:(BOOL)placeholder
{
    DLog();

    // Animate only once
    if (!self.alreadyAnimated) {
        self.alreadyAnimated = YES;
        if (!placeholder) {
            self.animPercent = 0.0;
            [self doAnimation];
            self.alpha = 1.0;
        } else {
            self.animPercent = 1.0;
            [self setNeedsDisplay];
            [super dimAsPlaceholder];
        }
    }
}

- (void) doAnimation
{
    // This could be made much smoother with CALayer things but let's look at that if this is not enough
    [self setNeedsDisplay];
    self.animPercent += 0.02;
    if (self.animPercent < 1.0) {
        [self performSelector:@selector(doAnimation) withObject:nil afterDelay:0.01];
    } else {
        self.animPercent = 1.0;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    NSAssert(self.values.count <= self.colors.count, @"Color & value array count mismatch");

    float sum = 0;
    for (NSInteger i = 0; i < self.values.count; i++) {
        sum += [[self.values objectAtIndex:i] floatValue];
    }

    float frac = (2.0 * M_PI) / sum;

    CGPoint center = CGPointMake(floor(rect.size.width / 2), floor(rect.size.height / 2));
    int radius = (center.x > center.y ? center.y : center.x);

    float startAngle;
    float endAngle = self.zeroAngle;
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSInteger i = 0; i < self.values.count; i++) {
        startAngle = endAngle;
        endAngle  += [[self.values objectAtIndex:i] floatValue] * (frac * self.animPercent);

        // If endAngle is too small nothing is drawn to the circle.
        // So we need to make the endAngle a little bit bigger.
        if ((endAngle - startAngle) < 0.01f ) {
            endAngle += 0.01f;
        }

        [[UIColor whiteColor] setStroke];
        [[self.colors objectAtIndex:i] setFill];
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);

        [[UIColor whiteColor] setStroke];
        [[UIColor whiteColor] setFill];
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddEllipseInRect(context, CGRectInset(self.bounds, 30, 30));
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

@end