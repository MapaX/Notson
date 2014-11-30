//
//  UIView+Extension.m
//  Notson
//
//  Created by Heikki Junnila on 9/4/12.
//  Copyright (c) 2012 Tieto. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+Extension.h"

#define FADE_DURATION 0.2
#define FADE_DELAY 0.15
#define MOVE_DURATION 0.25
#define ANIMATION_DURATION 0.3

@implementation UIView (Extension)
- (UIImage*) imageByRenderingView
{
    CGFloat oldAlpha = self.alpha;
    self.alpha = 1;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.alpha = oldAlpha;
	return image;
}

- (void)roundCorners:(UIRectCorner)corner withRadius:(CGSize)size
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:size];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    shape.path = rounded.CGPath;
    self.layer.mask = shape;
}

- (void)fadeInView:(UIView *)view
{
    view.alpha = 0.0;
    view.hidden = NO;
    [UIView animateWithDuration:FADE_DURATION delay:FADE_DELAY options:UIViewAnimationOptionCurveLinear animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {}];
}

- (void)fadeOutView:(UIView *)view
{
    view.alpha = 1.0;
    [UIView animateWithDuration:FADE_DURATION animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
    }];
}

- (void)moveView:(UIView*)view fromPosition:(CGPoint)from toPosition:(CGPoint)to
{
    CGRect fromRect = view.frame;
    fromRect.origin = from;
    view.frame = fromRect;
    [UIView animateWithDuration:MOVE_DURATION delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect toRect = view.frame;
        toRect.origin = to;
        view.frame = toRect;
    } completion:^(BOOL finished) {}];
}

- (CGRect)contentRectOfView:(UIView*)view
{
    CGRect contentRect = CGRectZero;
    if (view) {
        for (UIView *subview in view.subviews) {
            contentRect = CGRectUnion(contentRect, subview.frame);
        }
    }
    return contentRect;
}

- (void)showChildPage:(UIViewController*)controllerToShow onView:(UIViewController *)parentController
{
    // Set it outside the view and animate it to correct position.
    [parentController addChildViewController:controllerToShow];
    [parentController.view addSubview:controllerToShow.view];
    
    CGRect rect = controllerToShow.view.frame;
    rect.origin.x = -rect.size.width;
    controllerToShow.view.frame = rect;
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.2
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect rect = controllerToShow.view.frame;
                         rect.origin.x = -10; // 30 pixels of left margin is left out
                         controllerToShow.view.frame = rect;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

- (void)dismissChildPage:(UIViewController*)controllerToDismiss
{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect rect = controllerToDismiss.view.frame;
                         rect.origin.x = -rect.size.width;
                         controllerToDismiss.view.frame = rect;
                     }
                     completion:^(BOOL finished){
                         [controllerToDismiss.view removeFromSuperview];
                         [controllerToDismiss removeFromParentViewController];
                         
                     }
     ];
}


@end
