//
//  ChartViewBase.h
//  Notson
//
//  Created by Heikki Junnila on 25/03/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartViewBase : UIView
@property (nonatomic, strong) NSArray* values;
@property (nonatomic, strong) NSArray* colors;
- (void) showWithoutAnimation;
- (void) animateIntoViewAsPlaceholder:(BOOL)placeholder;
- (void) dimAsPlaceholder;
@end
