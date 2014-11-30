//
//  LoadingView.h
//  Notson
//
//  Created by Heikki Junnila on 10/03/13.
//  Copyright (c) 2012 Tieto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIViewController
+ (void)show;
+ (void)dismiss;

// Loading symbol is animated on the top of given view.
// Only given view is blocked. Basically used in Market Data. 
+ (void)showOnParentView:(UIView *)view;
@end
