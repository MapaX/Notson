//
//  MotionWindow.m
//  nic
//
//  Created by Miikka Pakkanen on 29/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "MotionWindow.h"

@implementation MotionWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceShake" object:self];
    }
}



@end
