//
//  BubbleView.h
//  nic
//
//  Created by Miikka Pakkanen on 29/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BubbleView : UIButton
@property (nonatomic, strong) UIColor *mainColor;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) CGFloat spent;
@property (nonatomic, assign) BOOL drawEstimate;
@end
