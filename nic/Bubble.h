//
//  Bubble.h
//  nic
//
//  Created by Miikka Pakkanen on 29/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BubbleView.h"

@interface Bubble : NSObject

@property (nonatomic, strong) NSString *bubbleTitle;
// Bubble size is a float indicating a factor of max bubble size (defined by kMaxBubbleSize)
@property (nonatomic, assign) CGFloat bubbleSize;
@property (nonatomic, strong) BubbleView *bubbleView;
@property (nonatomic, strong) UIColor *bubbleColor;
@property (nonatomic, assign) CGFloat spending;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
- (void)blobInView:(UIView *)view inPosition:(CGPoint)position;
@property (nonatomic, assign) CGFloat smileyFactor;
@end
