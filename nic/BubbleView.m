//
//  BubbleView.m
//  nic
//
//  Created by Miikka Pakkanen on 29/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "BubbleView.h"
#import "AppDelegate.h"

@interface BubbleView ()
{
    CGFloat red, green, blue, alpha;
}

@end
@implementation BubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setMainColor:(UIColor *)mainColor
{
    _mainColor = mainColor;
    
    [self.mainColor getRed:&red green:&green blue:&blue alpha:&alpha];
}
- (void)drawRect:(CGRect)rect
{
    
    // Filled circle
    CGRect borderRect = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.0);
    CGContextSetRGBFillColor(context, red, green, blue, 1.0);
    CGContextSetLineWidth(context, 0.0);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);

    // White circle
    CGRect subRect = CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeEllipseInRect(context, subRect);
    CGContextFillPath(context);

    // Normal circle
    CGContextSetLineWidth(context, 8.0);
//    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.3);
    CGContextSetRGBStrokeColor(context, red+((1.0-red)/2.0), green+((1.0-green)/2.0), blue+((1.0-blue)/2.0), 1.0);
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 4, 270 * (M_PI / 180), (270+360) * (M_PI / 180), 0);
    CGContextStrokePath(context);

    // Spending circle
    CGContextSetLineWidth(context, 6.0);
//    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, .3);
    CGContextSetRGBStrokeColor(context, red, green, blue, 1.0);
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 4, 270 * (M_PI / 180), (270 + (_spent * 360)) * (M_PI / 180), 0);
    CGContextStrokePath(context);
    
    // Second round spending circle, if spending is above 100%
    if (_spent > 1.0)
    {
        CGContextSetLineWidth(context, 6.0);
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGFloat secondRound = (270 + ((CGFloat)(_spent-(int)_spent) * 360));
        CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 4, 270 * (M_PI / 180), secondRound * (M_PI / 180), 0);
        CGContextStrokePath(context);
    }

    // Estimated spending.
    if (self.drawEstimate)
    {
        CGFloat estimatedSpending = _spent * kSimulatedEstimationFactor;
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBStrokeColor(context, estimatedSpending > 1.0 ? 1.0 : 0.0, estimatedSpending > 1.0 ? 0.0 : 1.0, 0.0, 1.0);
        CGFloat estimatedGaugeEndAngle = (270 + ((estimatedSpending-1.0) * 360));
        CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 10, 270 * (M_PI / 180), estimatedGaugeEndAngle * (M_PI / 180), estimatedSpending > 1.0 ? 0 : 1);
        CGContextStrokePath(context);
    }

}


@end
