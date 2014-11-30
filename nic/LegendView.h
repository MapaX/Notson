//
//  LegendView.h
//  Notson
//
//  Created by Heikki Junnila on 07/03/14.
//  Copyright (c) 2014 Tieto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegendView : UIView
- (void) setupWithValue:(NSString*)value title:(NSString*)title color:(UIColor*)color darkenText:(BOOL)darkenText;
- (void) makeCompact;
+ (CGSize) defaultSize;
@end
