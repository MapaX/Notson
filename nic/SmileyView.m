//
//  SmileyView.m
//  nic
//
//  Created by Miikka Pakkanen on 30/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "SmileyView.h"

@implementation SmileyView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 3.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    
    if (_smileFactor == 1.0)
    {
        CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height-3, self.frame.size.width/2 - 10, 225 * (M_PI / 180), 315 * (M_PI / 180), 0);
    }
    else
    {
        CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2 - 10, 135 * (M_PI / 180), 45 * (M_PI / 180), 1);
    }
    
    CGContextStrokePath(context);

}

@end
