//
//  UIView+Extension.h
//  Notson
//
//  Created by Heikki Junnila on 9/4/12.
//  Copyright (c) 2012 Tieto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
- (UIImage*) imageByRenderingView;
- (void)roundCorners:(UIRectCorner)corner withRadius:(CGSize)size;
- (void)fadeInView:(UIView *)view;
- (void)fadeOutView:(UIView *)view;
- (void)moveView:(UIView*)view fromPosition:(CGPoint)from toPosition:(CGPoint)to;
- (CGRect)contentRectOfView:(UIView*)view;
- (void)showChildPage:(UIViewController*)controllerToShow onView:(UIViewController *)parentController;
- (void)dismissChildPage:(UIViewController*)controllerToDismiss;
@end
